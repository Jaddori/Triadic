SERVER_BOOL = 1
SERVER_INT = 2
SERVER_FLOAT = 3
SERVER_STRING = 4

GameServer =
{
	objects = {},
	localAck = 0,
	remoteAck = 0,
	history = 0,

	debug_droprate = 0,
	packets = {},
	reliablePackets = {},
}

function GameServer:register( object, id )
	assert( isnumber( id ), "Id must be a number." )

	self.objects[id] = object
	self.packets[id] = {}
	self.reliablePackets[id] = {}
end

function GameServer:fixedUpdate()
	local messageCount = Server.beginRead()
	for i=1, messageCount do
		local message = Server.getMessage()

		local r = math.random(100)
		if r > self.debug_droprate then
			message.localAck = message:readUint()
			message.remoteAck = message:readUint()
			message.history = message:readUint()

			local idCount = message:readInt()
			for j=1, idCount do
				local id = message:readInt()

				if self.objects[id] then
					self.objects[id]:serverRead( message )
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

							Log.debug( "Server: Resending dropped reliable packet." )
						end
					else
						notReceived[#notReceived+1] = packet
					end
				end

				self.reliablePackets[i] = notReceived
			end
		end
	end
	Server.endRead()
end

function GameServer:serverWrite()
	Server.queueUint( self.localAck )
	Server.queueUint( self.remoteAck )
	Server.queueUint( self.history )

	local writingObjects = 0
	for k,v in pairs(self.objects) do
		if v:serverWrite() then
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

	Server.queueInt( writingObjects )
	for k,v in pairs(self.objects) do
		if #self.packets[k] > 0 or #self.reliablePackets[k] > 0 then
			Server.queueInt( k )

			for i=1, #self.packets[k] do
				local type = self.packets[k][i].type
				if type == SERVER_BOOL then Server.queueBool( self.packets[k][i].value )
				elseif type == SERVER_INT then Server.queueInt( self.packets[k][i].value )
				elseif type == SERVER_FLOAT then Server.queueFloat( self.packets[k][i].value )
				elseif type == SERVER_STRING then Server.queueString( self.packets[k][i].value )
				else
					Log.error( "BAD TYPE" )
				end
			end

			for i=1, #self.reliablePackets[k] do
				if self.reliablePackets[k][i].localAck == self.localAck then
					local type = self.reliablePackets[k][i].type
					if type == SERVER_BOOL then Server.queueBool( self.reliablePackets[k][i].value )
					elseif type == SERVER_INT then Server.queueInt( self.reliablePackets[k][i].value )
					elseif type == SERVER_FLOAT then Server.queueFloat( self.reliablePackets[k][i].value )
					elseif type == SERVER_STRING then Server.queueString( self.reliablePackets[k][i].value )
					else
						Log.error( "BAD TYPE" )
					end

					Log.debug( "Server: Writing reliable" )
				end
			end

			self.packets[k] = {}
		end
	end

	self.localAck = self.localAck + 1
end

function GameServer:queue( id, type, value )
	assert( type == SERVER_BOOL or type == SERVER_INT or type == SERVER_FLOAT or type == SERVER_STRING, "Bad type: " .. tostring( type ) )

	self.packets[id][#self.packets[id]+1] = { type = type, value = value }
end

function GameServer:queueReliable( id, type, value )
	assert( type == SERVER_BOOL or type == SERVER_INT or type == SERVER_FLOAT or type == SERVER_STRING, "Bad type: " .. tostring( type ) )

	self.reliablePackets[id][#self.reliablePackets[id]+1] = { type = type, value = value, localAck = self.localAck }
end