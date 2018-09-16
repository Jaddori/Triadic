GameServer =
{
	objects = {},
}

function GameServer:register( object, id )
	assert( isnumber( id ), "Id must be a number." )

	self.objects[id] = object
end

function GameServer:update( deltaTime )
	local messageCount = Server.beginRead()
	for i=1, messageCount do
		local message = Server.getMessage()

		local idCount = message:readInt()
		for j=1, idCount do
			local id = message:readInt()

			if self.objects[id] then
				self.objects[id]:serverRead( message )
			else
				break
			end
		end
	end
	Server.endRead()
end

function GameServer:serverWrite()
	Server.queueInt( #self.objects )
	for k,v in pairs(self.objects) do
		Server.queueInt( k )
		v:serverWrite()
	end
end