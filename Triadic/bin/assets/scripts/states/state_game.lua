StateGame =
{
	name = "StateGame",
}

function StateGame:load()
	doscript( "game/player_handler.lua" )
	doscript( "game/chat.lua" )

	if IS_SERVER then
		doscript( "game/server.lua" )
	else
		doscript( "game/client.lua" )
	end

	PlayerHandler:load()
	Chat:load()
end

function StateGame:unload()
	PlayerHandler:unload()
	Chat:unload()
end

function StateGame:update( deltaTime )
	PlayerHandler:update( deltaTime )
end

function StateGame:fixedUpdate()
	PlayerHandler:fixedUpdate()
	Chat:fixedUpdate()
end

function StateGame:render()
	PlayerHandler:render()
	Chat:render()
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

Game:addState( StateGame )
Game:setState( StateGame.name )