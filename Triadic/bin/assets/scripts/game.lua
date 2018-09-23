Game =
{
	name = "Game",

	states = {},
	currentState = "",
}

function Game:load()
	local stateScripts = Filesystem.getFiles( "./assets/scripts/states/*" )
	for _,v in pairs(stateScripts) do
		doscript( "states/" .. v )
	end

	for _,v in pairs(self.states) do
		v:load()
	end
end

function Game:unload()
	for _,v in pairs(self.states) do
		v:unload()
	end
end

function Game:update( deltaTime )
	self.states[self.currentState]:update( deltaTime )
end

function Game:fixedUpdate()
	self.states[self.currentState]:fixedUpdate()
end

function Game:render()
	self.states[self.currentState]:render()
end

function Game:clientWrite()
	self.states[self.currentState]:clientWrite()
end

function Game:clientRead()
	self.states[self.currentState]:clientRead()
end

function Game:serverWrite()
	self.states[self.currentState]:serverWrite()
end

function Game:serverRead()
	self.states[self.currentState]:serverRead()
end

function Game:addState( state )
	self.states[state.name] = state
	
	if self.currentState == "" then
		self.currentState = state.name
	end
end

function Game:setState( name )
	self.currentState = name
end

addScript( Game )