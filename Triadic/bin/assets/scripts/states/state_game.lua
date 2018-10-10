StateGame =
{
	name = "StateGame",
}

function StateGame:load()
	doscript( "game/player_handler.lua" )
	doscript( "game/chat.lua" )
	
	doscript( "game/bounding_boxes.lua" )

	doscript( "game/lights.lua" )
	doscript( "game/props.lua" )
	doscript( "game/particles.lua" )

	if IS_SERVER then
		doscript( "game/server.lua" )
	else
		doscript( "game/client.lua" )
	end

	PlayerHandler:load()
	Chat:load()

	self:loadLevel( "walkable_level02.lua" )

	Graphics.setLightingEnabled( true )
end

function StateGame:loadLevel( level )
	dofile( "./assets/levels/" .. level )
end

function StateGame:unload()
	PlayerHandler:unload()
	Chat:unload()
end

function StateGame:update( deltaTime )
	PlayerHandler:update( deltaTime )
	Particles:update( deltaTime )
end

function StateGame:fixedUpdate()
	PlayerHandler:fixedUpdate()
	Chat:fixedUpdate()

	if Input.keyReleased( Keys.T ) then
		Graphics.setLightingEnabled( not Graphics.getLightingEnabled() )
	end

	if Input.keyReleased( Keys.B ) then
		BoundingBoxes.ignoreDepth = true
		BoundingBoxes.debug = not BoundingBoxes.debug
	end
end

function StateGame:render()
	PlayerHandler:render()
	Chat:render()

	BoundingBoxes:render()
	Lights:render()
	Props:render()
	Particles:render()
end

function StateGame:clientWrite()
	GameClient:clientWrite()
end

function StateGame:clientRead()
	GameClient:clientRead()
end

function StateGame:serverWrite()
	GameServer:serverWrite()
end

function StateGame:serverRead()
	GameServer:serverRead()
end

function StateGame:enter()
end

function StateGame:exit()
end

Game:addState( StateGame )