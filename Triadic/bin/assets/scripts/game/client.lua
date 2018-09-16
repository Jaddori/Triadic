GameClient =
{
	objects = {},
}

function GameClient:register( object, id )
	assert( isnumber( id ), "Id must be a number." )
	
	self.objects[id] = object
end

function GameClient:update( deltaTime )
	local messageCount = Client.beginRead()
	for i=1, messageCount do
		local message = Client.getMessage()

		local idCount = message:readInt()
		for j=1, idCount do
			local id = message:readInt()

			if self.objects[id] then
				self.objects[id]:clientRead( message )
			else
				break
			end
		end
	end
	Client.endRead()
end

function GameClient:clientWrite()
	Client.queueInt( #self.objects )
	for k,v in pairs(self.objects) do
		Client.queueInt( k )
		v:clientWrite()
	end
end