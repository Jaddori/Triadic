GameServer =
{
	objects = {},
	localAck = 0,
	remoteAck = 0,
	history = 0,
}

function GameServer:register( object, id )
	assert( isnumber( id ), "Id must be a number." )

	self.objects[id] = object
end

function GameServer:fixedUpdate()
	local messageCount = Server.beginRead()
	for i=1, messageCount do
		local message = Server.getMessage()

		message.localAck = message:readInt()
		message.remoteAck = message:readInt()
		message.history = message:readInt()

		local idCount = message:readInt()
		for j=1, idCount do
			local id = message:readInt()

			if self.objects[id] then
				self.objects[id]:serverRead( message )
			else
				break
			end
		end

		self.remoteAck = message.localAck
	end
	Server.endRead()
end

function GameServer:serverWrite()
	Server.queueInt( self.localAck )
	Server.queueInt( self.remoteAck )
	Server.queueInt( self.history )

	Server.queueInt( #self.objects )
	for k,v in pairs(self.objects) do
		Server.queueInt( k )
		v:serverWrite()
	end

	self.localAck = self.localAck + 1
end