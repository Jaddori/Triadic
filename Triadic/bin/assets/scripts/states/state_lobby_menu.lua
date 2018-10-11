require( "./assets/scripts/states/state_menu" )

LOBBY_SERVER_TIMEOUT = 1000

StateLobbyMenu = StateMenu.create( "LobbyMenu" )

function StateLobbyMenu:load()
	if IS_CLIENT then
		self.titleLabel = EditorLabel.create( Vec2.create(), Vec2.create({WINDOW_WIDTH, 128}), "Triadic" )
		self.titleLabel:loadFont( "./assets/fonts/verdana18.bin", "./assets/fonts/verdana18.dds" )
		self.titleLabel:setTextAlignment( ALIGN_MIDDLE, ALIGN_MIDDLE )

		self.playersLabel = EditorLabel.create( Vec2.create({128,128}), Vec2.create({64,24}), "Players:" )
		
		self.nameLabels =
		{
			EditorLabel.create( Vec2.create({128+32,128+24}), Vec2.create({64,24}), "" ),
			EditorLabel.create( Vec2.create({128+32,128+24+24}), Vec2.create({64,24}), "" ),
			EditorLabel.create( Vec2.create({128+32,128+24+24+24}), Vec2.create({64,24}), "" ),
		}

		self.backButton = EditorButton.create( Vec2.create({32,256+32}), Vec2.create({128,24}), "Back" )
		self.backButton.onClick = function( button )
			Game:popState()
		end

		self:addControl( self.titleLabel )
		self:addControl( self.playersLabel )
		self:addControl( self.backButton )

		for _,v in pairs(self.nameLabels) do
			v.visible = false
			self:addControl( v )
		end
	else -- IS_SERVER
		self.players = {}
	end
end

function StateLobbyMenu:enter()
	if IS_CLIENT then
		GameClient:register( self, 13 )
		GameClient:connect( "127.0.0.1", 12345 )
	else -- IS_SERVER
		GameServer:register( self, 13 )
	end

	--doscript( "game/player_handler.lua" )
	--PlayerHandler:load()
end

function StateLobbyMenu:exit()
	if IS_CLIENT then
		--GameClient:unregister( 13 )
	else -- IS_SERVER
		--GameServer:unregister( 13 )
	end
end

function StateLobbyMenu:fixedUpdate()
	if IS_SERVER then
		local curTick = Core.getTicks()

		for i=1, #self.players do
			local elapsed = curTick - self.players[i].lastReceive
			if elapsed > LOBBY_SERVER_TIMEOUT then
				self.players[i] = nil
				break
			end
		end
	end
end

function StateLobbyMenu:serverWrite( hash )
	GameServer:queue( hash, 13, SERVER_INT, #self.players )

	for i=1, #self.players do
		GameServer:queue( hash, 13, SERVER_STRING, self.players[i].name )
	end

	return true
end

function StateLobbyMenu:serverRead( message )
	local hash = message:getHash()

	local index = 0
	for i=1, #self.players do
		if self.players[i].hash == hash then
			index = i
			break
		end
	end

	if index > 0 then
		self.players[index].lastReceive = Core.getTicks()
	end
end

function StateLobbyMenu:serverOnHandshakeCompleted( hash, networkID )
	--doscript( "states/state_gameplay.lua" )
	--StateGameplay:load()
	--Game:setState( "Gameplay" )

	local index = #self.players + 1
	self.players[index] =
	{
		name = tostring( hash ),
		lastReceive = Core.getTicks(),
		hash = hash,
	}
end

function StateLobbyMenu:clientWrite()
	GameClient:queue( 13, CLIENT_INT, 1337 )

	return true
end

function StateLobbyMenu:clientRead( message )
	local playerCount = message:readInt()

	--for i=1, playerCount do
	--	local name = message:readString()
--
	--	if self.nameLabels[i].alignText.text ~= name then
	--		self.nameLabels[i]:setText( name )
	--	end
	--end

	for i=1, #self.nameLabels do
		if i <= playerCount then
			local name = message:readString()

			if self.nameLabels[i].alignText.text ~= name then
				self.nameLabels[i]:setText( name )
			end
		else
			self.nameLabels[i]:setText( "" )
		end
	end
end

function StateLobbyMenu:clientOnHandshakeCompleted()
	--doscript( "states/state_gameplay.lua" )
	--StateGameplay:load()
	--Game:setState( "Gameplay" )
end

Game:addState( StateLobbyMenu )