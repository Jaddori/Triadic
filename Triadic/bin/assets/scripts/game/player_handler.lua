PlayerHandler =
{
	playerCount = 0,
}

function PlayerHandler:load()
	doscript( "player.lua" )

	if IS_CLIENT then
		self.localPlayer = Player.create( true )
		--self.remotePlayer = Player.create( false )
		self.remotePlayers = { Player.create( false ) }

		self.localPlayer:load()
		--self.remotePlayer:load()
		for i=1, #self.remotePlayers do
			self.remotePlayers[i]:load()
		end

		GameClient:register( self, 1 )
	else -- IS_SERVER
		self.players = { Player.create( false ), Player.create( false ) }
		self.players[1].hash = 0
		self.players[1].networkID = 0
		self.players[2].hash = 0
		self.players[2].networkID = 0

		GameServer:register( self, 1 )
	end
end

function PlayerHandler:unload()
	if IS_CLIENT then
		self.localPlayer:unload()
		--self.remotePlayer:unload()

		for i=1, #self.remotePlayers do
			self.remotePlayers[i]:unload()
		end
	end
end

function PlayerHandler:update( deltaTime )
	if IS_CLIENT then
		self.localPlayer:update( deltaTime )
		--self.remotePlayer:update( deltaTime )

		for i=1, #self.remotePlayers do
			self.remotePlayers[i]:update( deltaTime )
		end
	end
end

function PlayerHandler:fixedUpdate()
	if IS_CLIENT then
		self.localPlayer:fixedUpdate()
	end
end

function PlayerHandler:render()
	if IS_CLIENT then
		self.localPlayer:render()
		--self.remotePlayer:render()

		for i=1, #self.remotePlayers do
			self.remotePlayers[i]:render()
		end
	end
end

function PlayerHandler:clientWrite()
	self.localPlayer:clientWrite()

	return true
end

function PlayerHandler:clientRead( message )
	--self.localPlayer:clientRead( message )
	--self.remotePlayer:clientRead( message )

	local playerCount = message:readInt()
	local remoteIndex = 1

	for i=1, playerCount do
		local networkID = message:readInt()
		if networkID == Client.getNetworkID() then
			self.localPlayer:clientRead( message )
		else
			self.remotePlayers[remoteIndex]:clientRead( message )
			remoteIndex = remoteIndex + 1
		end
	end
end

function PlayerHandler:serverWrite( hash )
	--if hash == self.players[1].hash then
	--	self.players[1]:serverWrite( hash )
	--	self.players[2]:serverWrite( hash )
	--elseif hash == self.players[2].hash then
	--	self.players[2]:serverWrite( hash )
	--	self.players[1]:serverWrite( hash )
	--end

	GameServer:queue( hash, 1, SERVER_INT, #self.players )
	for i=1, #self.players do
		GameServer:queue( hash, 1, SERVER_INT, self.players[i].networkID )
		self.players[i]:serverWrite( hash )
	end

	return true
end

function PlayerHandler:serverRead( message )
	local hash = message:getHash()

	--if self.players[1].hash == hash then
	--	self.players[1]:serverRead( message )
	--elseif self.players[2].hash == hash then
	--	self.players[2]:serverRead( message )
	--end

	for i=1, #self.players do
		if self.players[i].hash == hash then
			self.players[i]:serverRead( message )
		end
	end
end

function PlayerHandler:serverOnNewHash( hash )
	if self.players[1].hash == 0 then
		self.players[1].hash = hash
		self.players[1].networkID = Server.getNetworkID( hash )
		Log.debug( "PlayerHandler: Adding player 1 with hash " .. tostring( hash ) )
	else
		self.players[2].hash = hash
		self.players[2].networkID = Server.getNetworkID( hash )
		Log.debug( "PlayerHandler: Adding player 2 with hash " .. tostring( hash ) )
	end
end