CLIENT_BOOL = 1
CLIENT_INT = 2
CLIENT_FLOAT = 3
CLIENT_STRING = 4

GameClient =
{
	objects = {},
	localAck = 0,
	remoteAck = 0,
	history = 0,

	RTTs = nil,
	averageRTT = 0,
	averageReceiveTime = 0,
	lastReceiveTime = 0,
	lastReceiveTick = 0,

	debug_droprate = 0,
	packets = {},
	reliablePackets = {},
}

function GameClient:register( object, id )
	assert( isnumber( id ), "Id must be a number." )
	assert( self.objects[id] == nil, "ID is already taken: " .. tostring( id ) )
	
	self.objects[id] = object
	self.packets[id] = {}
	self.reliablePackets[id] = {}

	if not self.RTTs then
		self.RTTs = {}
		for i=1, 10 do
			self.RTTs[i] = 
			{
				localAck = 0,
				tick = 0,
				rtt = 0,
			}
		end
	end
end

function GameClient:clientWrite()
	Client.queueUint( self.localAck )
	Client.queueUint( self.remoteAck )
	Client.queueUint( self.history )

	-- store RTT information
	for i=#self.RTTs, 2, -1 do
		self.RTTs[i].localAck = self.RTTs[i-1].localAck
		self.RTTs[i].tick = self.RTTs[i-1].tick
		self.RTTs[i].rtt = self.RTTs[i-1].rtt
	end

	self.RTTs[1].localAck = self.localAck
	self.RTTs[1].tick = Core.getTicks()
	self.RTTs[1].rtt = 0

	-- collect objects that will write to the message
	local writingObjects = 0
	for k,v in pairs(self.objects) do
		if v:clientWrite() then
			writingObjects = writingObjects + 1
		else
			if #self.reliablePackets[k] > 0 then
				for i=1, #self.reliablePackets[k] do
					if self.reliablePackets[k][i].localAck == self.localAck then
						writingObjects = writingObjects + 1
						break
					end
				end
			end
		end
	end

	-- write to the message
	Client.queueInt( writingObjects )
	for k,v in pairs(self.objects) do
		if #self.packets[k] > 0 or #self.reliablePackets[k] > 0 then
			Client.queueInt( k )

			for i=1, #self.packets[k] do
				local type = self.packets[k][i].type
				if type == CLIENT_BOOL then Client.queueBool( self.packets[k][i].value )
				elseif type == CLIENT_INT then Client.queueInt( self.packets[k][i].value )
				elseif type == CLIENT_FLOAT then Client.queueFloat( self.packets[k][i].value )
				elseif type == CLIENT_STRING then Client.queueString( self.packets[k][i].value )
				else
					Log.error( "BAD TYPE" )
				end
			end

			for i=1, #self.reliablePackets[k] do
				if self.reliablePackets[k][i].localAck == self.localAck then
					local type = self.reliablePackets[k][i].type
					if type == CLIENT_BOOL then Client.queueBool( self.reliablePackets[k][i].value )
					elseif type == CLIENT_INT then Client.queueInt( self.reliablePackets[k][i].value )
					elseif type == CLIENT_FLOAT then Client.queueFloat( self.reliablePackets[k][i].value )
					elseif type == CLIENT_STRING then Client.queueString( self.reliablePackets[k][i].value )
					else
						Log.error( "BAD TYPE" )
					end
				end
			end

			self.packets[k] = {}
		end
	end

	self.localAck = self.localAck + 1
end

function GameClient:clientRead()
	local curTick = Core.getTicks()
	local messages = Client.getMessages()

	-- calculate average receive time
	if #messages > 0 then
		if self.lastReceiveTick > 0 then
			local receiveTime = curTick - self.lastReceiveTick
			self.averageReceiveTime = ( self.lastReceiveTime + receiveTime ) * 0.5
			self.lastReceiveTime = receiveTime
		end

		self.lastReceiveTick = curTick
	end

	for i=1, #messages do
		local message = messages[i]

		local r = math.random(100)
		if r > self.debug_droprate then
			message.localAck = message:readUint()
			message.remoteAck = message:readUint()
			message.history = message:readUint()

			local idCount = message:readInt()
			for j=1, idCount do
				local id = message:readInt()

				if self.objects[id] then
					self.objects[id]:clientRead( message )
				else
					break
				end
			end

			local prevRemoteAck = self.remoteAck
			self.remoteAck = message.localAck

			self.history = bit32.lshift( self.history, self.remoteAck - prevRemoteAck )
			self.history = bit32.bor( self.history, 1 )

			-- check if any reliable packets have been dropped
			for i=1, #self.reliablePackets do
				local notReceived = {}

				for j=1, #self.reliablePackets[i] do
					local packet = self.reliablePackets[i][j]

					if packet.localAck <= message.remoteAck then
						local offset = message.remoteAck - packet.localAck
						local wasReceived = false
						if offset <= 31 then
							wasReceived = ( bit32.extract( message.history, offset ) > 0 )
						else
							Log.debug( "OUT OF RANGE" )
						end

						if not wasReceived then
							packet.localAck = self.localAck
							notReceived[#notReceived+1] = packet
						end
					else
						notReceived[#notReceived+1] = packet
					end
				end

				self.reliablePackets[i] = notReceived
			end
			
			-- calculate RTT
			local validRTTs = 0
			self.averageRTT = 0
			for i=1, #self.RTTs do
				if self.RTTs[i].localAck == message.remoteAck then
					self.RTTs[i].rtt = curTick - self.RTTs[i].tick
				end

				if self.RTTs[i].rtt > 0 then
					self.averageRTT = self.averageRTT + self.RTTs[i].rtt
					validRTTs = validRTTs + 1
				end
			end

			self.averageRTT = self.averageRTT / validRTTs
		end
	end
end

function GameClient:queue( id, type, value, reliable )
	assert( type == CLIENT_BOOL or type == CLIENT_INT or type == CLIENT_FLOAT or type == CLIENT_STRING, "Bad type: " .. tostring( type ) )

	if reliable then
		local count = #self.reliablePackets[id]
		self.reliablePackets[id][count+1] = { type = type, value = value, localAck = self.localAck }
	else
		local count = #self.packets[id]
		self.packets[id][count+1] = { type = type, value = value }
	end
end