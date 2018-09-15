StateGame =
{
	name = "StateGame",
	messages = { "a", "b", "c", "d" },
	fontIndex = -1,
}

function StateGame:load()
	doscript( "player.lua" )

	Player:load()

	self.fontIndex = Assets.loadFont( "./assets/fonts/verdana12.bin", "./assets/fonts/verdana12.dds" )
end

function StateGame:unload()
	Player:unload()
end

function StateGame:update( deltaTime )
	Player:update( deltaTime )

	local messageCount = Client.beginRead()

	for i=1, messageCount do
		local message = Client.getMessage()
		if message then
			local text = message:readString()
			
			for i=4, 0, -1 do
				self.messages[i] = self.messages[i-1]
			end

			self.messages[1] = text
		end
	end

	Client.endRead()
end

function StateGame:render()
	Player:render()

	local position = {32, 32}
	for i=1, #self.messages do
		Graphics.queueText( self.fontIndex, self.messages[i], position, 0.0, {1,1,1,1} )
		position[2] = position[2] + 16
	end
end

Game:addState( StateGame )
Game:setState( StateGame.name )