GameClient =
{
	objects = {},
	localAck = 0,
	remoteAck = 0,
	history = 0,
}

function GameClient:register( object, id )
	assert( isnumber( id ), "Id must be a number." )
	
	self.objects[id] = object
end

function GameClient:update( deltaTime )
	local messageCount = Client.beginRead()
	for i=1, messageCount do
		local message = Client.getMessage()

		message.localAck = message:readInt()
		message.remoteAck = message:readInt()
		message.history = message:readInt()

		local idCount = message:readInt()
		for j=1, idCount do
			local id = message:readInt()

			if self.objects[id] then
				self.objects[id]:clientRead( message )
			else
				break
			end
		end

		self.remoteAck = message.localAck
	end
	Client.endRead()
end

function GameClient:clientWrite()
	Client.queueInt( self.localAck )
	Client.queueInt( self.remoteAck )
	Client.queueInt( self.history )

	Client.queueInt( #self.objects )
	for k,v in pairs(self.objects) do
		Client.queueInt( k )
		v:clientWrite()
	end

	self.localAck = self.localAck + 1
end