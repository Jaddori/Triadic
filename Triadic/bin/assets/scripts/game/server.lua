SERVER_BOOL = 1
SERVER_INT = 2
SERVER_FLOAT = 3
SERVER_STRING = 4

GameServer =
{
	objects = {},
	acks = {},

	debug_droprate = 0,
	packets = {},
	reliablePackets = {},
}

function GameServer:register( object, id )
	assert( isnumber( id ), "ID must be a number." )
	assert( self.objects[id] == nil, "ID is already taken: " .. tostring( id ) )

	self.objects[id] = object
end

function GameServer:serverWrite()
	for ackKey,ackValue in pairs(self.acks) do
		Server.queueUint( ackValue.hash, ackValue.localAck )
		Server.queueUint( ackValue.hash, ackValue.remoteAck )
		Server.queueUint( ackValue.hash, ackValue.history )

		local writingObjects = 0
		for objectKey,objectValue in pairs(self.objects) do
			if objectValue:serverWrite( ackValue.hash ) then
				writingObjects = writingObjects + 1
			else
				if #self.reliablePackets[ackValue.hash][objectKey] > 0 then
					for packetKey,packetValue in pairs(self.reliablePackets[ackValue.hash][objectKey]) do
						if packetValue.localAck == ackValue.localAck then
							writingObjects = writingObjects + 1
							break
						end
					end
				end
			end
		end

		Server.queueInt( ackValue.hash, writingObjects )
		for objectKey,objectValue in pairs(self.objects) do
			if #self.packets[ackValue.hash][objectKey] > 0 or #self.reliablePackets[ackValue.hash][objectKey] > 0 then
				Server.queueInt( ackValue.hash, objectKey )

				for packetKey, packetValue in pairs(self.packets[ackValue.hash][objectKey]) do
					local type = packetValue.type

					if type == SERVER_INT then Server.queueInt( ackValue.hash, packetValue.value )
					elseif type == SERVER_UINT then Server.queueUint( ackValue.hash, packetValue.value )
					elseif type == SERVER_FLOAT then Server.queueFloat( ackValue.hash, packetValue.value )
					elseif type == SERVER_STRING then Server.queueString( ackValue.hash, packetValue.value )
					end
				end

				for packetKey, packetValue in pairs(self.reliablePackets[ackValue.hash][objectKey]) do
					if packetValue.localAck == ackValue.localAck then
						local type = packetValue.type

						if type == SERVER_INT then Server.queueInt( ackValue.hash, packetValue.value )
						elseif type == SERVER_UINT then Server.queueUint( ackValue.hash, packetValue.value )
						elseif type == SERVER_FLOAT then Server.queueFloat( ackValue.hash, packetValue.value )
						elseif type == SERVER_STRING then
							Server.queueString( ackValue.hash, packetValue.value )
						end
					end
				end
			end

			self.packets[ackValue.hash][objectKey] = {}
		end

		ackValue.localAck = ackValue.localAck + 1
	end
end

function GameServer:serverRead()
	local messages = Server.getMessages()

	for i=1, #messages do
		local message = messages[i]

		local hash = message:getHash()
		
		-- setup packet table for hash, if non-existant
		if not self.packets[hash] then
			self.packets[hash] = {}
			self.reliablePackets[hash] = {}
			
			self.acks[hash] =
			{
				hash = hash,
				localAck = 0,
				remoteAck = 0,
				history = 0
			}

			for k,v in pairs(self.objects) do
				self.packets[hash][k] = {}
				self.reliablePackets[hash][k] = {}

				if v.serverOnNewHash then
					v:serverOnNewHash( hash )
				end
			end
		end

		local r = math.random(100)
		if r > self.debug_droprate then
			message.localAck = message:readInt()
			message.remoteAck = message:readInt()
			message.history = message:readInt()

			if message.localAck > self.acks[hash].remoteAck then
				-- let all registered objects read from the message
				local idCount = message:readInt()
				for j=1, idCount do
					local id = message:readInt()

					if self.objects[id] then
						self.objects[id]:serverRead( message )
					else
						Log.error( "Server: bad object id. Discarding packet." )
						break
					end
				end

				-- update acks
				local prevRemoteAck = self.acks[hash].remoteAck
				self.acks[hash].remoteAck = message.localAck

				self.acks[hash].history = bit32.lshift( self.acks[hash].history, self.acks[hash].remoteAck - prevRemoteAck )
				self.acks[hash].history = bit32.bor( self.acks[hash].history, 1 )

				-- check if any reliable packets were dropped
				for i=1, #self.reliablePackets[hash] do
					local notReceived = {}

					for j=1, #self.reliablePackets[hash][i] do
						local packet = self.reliablePackets[hash][i][j]

						if packet.localAck <= message.remoteAck then
							local offset = message.remoteAck - packet.localAck
							local wasReceived = false
							if offset < 32 then
								wasReceived = ( bit32.extract( message.history, offset ) > 0 )
							else
								Log.debug( "OUT OF RANGE" )
							end

							if not wasReceived then
								packet.localAck = self.acks[hash].localAck
								notReceived[#notReceived+1] = packet

								Log.debug( "Server: Resending dropped reliable packet." )
							end
						else
							notReceived[#notReceived+1] = packet
						end
					end

					self.reliablePackets[hash][i] = notReceived
				end
			end
		end
	end
end

function GameServer:queue( hash, id, type, value, reliable )
	assert( type == SERVER_INT or type == SERVER_UINT or type == SERVER_FLOAT or type == SERVER_STRING, "Server: bad type = " .. tostring( type ) )

	if reliable then
		local count = #self.reliablePackets[hash][id]
		self.reliablePackets[hash][id][count+1] = { type = type, value = value, localAck = self.acks[hash].localAck }
	else
		local count = #self.packets[hash][id]
		self.packets[hash][id][count+1] = { type = type, value = value }
	end
end