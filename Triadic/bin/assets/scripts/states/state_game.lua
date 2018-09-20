StateGame =
{
	name = "StateGame",
	messages = { "a", "b", "c", "d" },
	fontIndex = -1,
}

function StateGame:load()
	doscript( "player.lua" )

	if IS_SERVER then
		doscript( "game/server.lua" )
	else
		doscript( "game/client.lua" )
	end

	Player:load()
end

function StateGame:unload()
	Player:unload()
end

function StateGame:update( deltaTime )
	Player:update( deltaTime )

	if IS_CLIENT then
		GameClient:update( deltaTime )
	end
end

function StateGame:fixedUpdate()
	Player:fixedUpdate()

	if IS_SERVER then
		GameServer:fixedUpdate()
	end
end

function StateGame:render()
	Player:render()
end

function StateGame:clientWrite()
	GameClient:clientWrite()
end

function StateGame:serverWrite()
	GameServer:serverWrite()
end

Game:addState( StateGame )
Game:setState( StateGame.name )