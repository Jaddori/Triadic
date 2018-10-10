Game =
{
	name = "Game",

	states = {},
	currentState = "",
	stateStack = {},
}

function Game:load()
	local controls = Filesystem.getFiles( "./assets/scripts/editor/controls/*" )
	for _,v in pairs(controls) do
		doscript( "editor/controls/" .. v )
	end

	local stateScripts = Filesystem.getFiles( "./assets/scripts/states/*" )
	for _,v in pairs(stateScripts) do
		doscript( "states/" .. v )
	end

	for _,v in pairs(self.states) do
		--v:load()
		if v.load then
			v:load()
		end
	end
end

function Game:unload()
	for _,v in pairs(self.states) do
		--v:unload()
		if v.unload then
			v:unload()
		end
	end
end

function Game:safeCall( func, ... )
	local curState = self.states[self.currentState]

	if curState and curState[func] then
		curState[func]( curState, ... )
	end
end

function Game:update( deltaTime )
	self:safeCall( "update", deltaTime )
end

function Game:fixedUpdate()
	self:safeCall( "fixedUpdate" )
end

function Game:render()
	self:safeCall( "render" )
end

function Game:clientWrite()
	self:safeCall( "clientWrite" )
end

function Game:clientRead()
	self:safeCall( "clientRead" )
end

function Game:serverWrite()
	self:safeCall( "serverWrite" )
end

function Game:serverRead()
	self:safeCall( "serverRead" )
end

function Game:addState( state )
	self.states[state.name] = state
	
	if self.currentState == "" then
		self:setState( state.name )
	end
end

function Game:setState( name )
	self:safeCall( "exit" )

	self.stateStack = { name }
	self.currentState = name

	self:safeCall( "enter" )
end

function Game:pushState( name )
	self:safeCall( "exit" )

	self.stateStack[#self.stateStack+1] = name
	self.currentState = name

	self:safeCall( "enter" )
end

function Game:popState()
	if #self.stateStack > 0 then
		self:safeCall( "exit" )

		self.stateStack[#self.stateStack] = nil
		self.currentState = self.stateStack[#self.stateStack]

		self:safeCall( "enter" )
	end
end

addScript( Game )