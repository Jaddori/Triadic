PlayerHandler =
{
	playerCount = 0,
}

function PlayerHandler:load()
	doscript( "player.lua" )

	if IS_CLIENT then
		self.localPlayer = Player.create( true )
		self.remotePlayer = Player.create( false )

		self.localPlayer:load()
		self.remotePlayer:load()

		GameClient:register( self, 1 )
	else -- IS_SERVER
		self.players = { Player.create( false ), Player.create( false ) }
		self.players[1].hash = 0
		self.players[2].hash = 0

		GameServer:register( self, 1 )
	end
end

function PlayerHandler:unload()
	if IS_CLIENT then
		self.localPlayer:unload()
		self.remotePlayer:unload()
	end
end

function PlayerHandler:update( deltaTime )
	if IS_CLIENT then
		self.localPlayer:update( deltaTime )
		self.remotePlayer:update( deltaTime )
	end
end

function PlayerHandler:fixedUpdate()
	if IS_CLIENT then
		self.localPlayer:fixedUpdate()
		--self.remotePlayer:fixedUpdate()
	else
		--self.players[2].transform:addPosition( {0.1,0,0} )
	end
end

function PlayerHandler:render()
	if IS_CLIENT then
		self.localPlayer:render()
		self.remotePlayer:render()
	end
end

function PlayerHandler:clientWrite()
	self.localPlayer:clientWrite()

	return true
end

function PlayerHandler:clientRead( message )
	self.localPlayer:clientRead( message )
	self.remotePlayer:clientRead( message )
end

function PlayerHandler:serverWrite( hash )
	if hash == self.players[1].hash then
		self.players[1]:serverWrite( hash )
		self.players[2]:serverWrite( hash )
	elseif hash == self.players[2].hash then
		self.players[2]:serverWrite( hash )
		self.players[1]:serverWrite( hash )
	end

	return true
end

function PlayerHandler:serverRead( message )
	local hash = message:getHash()
	
	if self.players[1].hash == hash then
		self.players[1]:serverRead( message )
	elseif self.players[2].hash == hash then
		self.players[2]:serverRead( message )
	end
end

function PlayerHandler:serverOnNewHash( hash )
	if self.players[1].hash == 0 then
		self.players[1].hash = hash
		Log.debug( "PlayerHandler: Adding player 1 with hash " .. tostring( hash ) )
	else
		self.players[2].hash = hash
		Log.debug( "PlayerHandler: Adding player 2 with hash " .. tostring( hash ) )
	end
end