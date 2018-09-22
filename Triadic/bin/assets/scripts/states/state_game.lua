StateGame =
{
	name = "StateGame",
}

function StateGame:load()
	doscript( "player.lua" )
	doscript( "game/chat.lua" )

	if IS_SERVER then
		doscript( "game/server.lua" )
	else
		doscript( "game/client.lua" )
	end

	Player:load()
	Chat:load()
end

function StateGame:unload()
	Player:unload()
	Chat:unload()
end

function StateGame:update( deltaTime )
	Player:update( deltaTime )

	if IS_CLIENT then
		GameClient:update( deltaTime )
	end
end

function StateGame:fixedUpdate()
	Player:fixedUpdate()
	Chat:fixedUpdate()

	if IS_SERVER then
		GameServer:fixedUpdate()
	end
end

function StateGame:render()
	Player:render()
	Chat:render()
end

function StateGame:clientWrite()
	GameClient:clientWrite()
end

function StateGame:serverWrite()
	GameServer:serverWrite()
end

Game:addState( StateGame )
Game:setState( StateGame.name )