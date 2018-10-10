StatePlayMenu =
{
	name = "StatePlayMenu",

	titleLabel = nil,

	hostButton = nil,
	joinButton = nil,
	backButton = nil,

	capture =
	{
		depth = -1,
		button = -1,
		item = nil,
		focusItem = nil,
		entity = nil,
		axis = -1,
	},
}

function StatePlayMenu:load()
	self.titleLabel = EditorLabel.create( Vec2.create(), Vec2.create({WINDOW_WIDTH, 128}), "Triadic" )
	self.titleLabel:loadFont( "./assets/fonts/verdana18.bin", "./assets/fonts/verdana18.dds" )
	self.titleLabel:setTextAlignment( ALIGN_MIDDLE, ALIGN_MIDDLE )

	self.hostButton = EditorButton.create( Vec2.create({32,128}), Vec2.create({128,24}), "Host Game" )
	self.hostButton.onClick = function( button )
		Game:pushState( "StateLobby" )
	end

	self.joinButton = EditorButton.create( Vec2.create({32,128+48}), Vec2.create({128,24}), "Join Game" )
	self.joinButton.onClick = function( button )
		Game:pushState( "StateJoinGame" )
	end

	self.backButton = EditorButton.create( Vec2.create({32,256+32}), Vec2.create({128,24}), "Back" )
	self.backButton.onClick = function( button )
		Game:popState()
	end
end

function StatePlayMenu:update( deltaTime )
	local mousePosition = Input.getMousePosition()

	if self.capture.button == -1 then
		if Input.buttonPressed( Buttons.Left ) then
			self.capture.button = Buttons.Left
		end

		if self.capture.button > -1 then
			self.hostButton:checkCapture( self.capture, mousePosition )
			self.joinButton:checkCapture( self.capture, mousePosition )
			self.backButton:checkCapture( self.capture, mousePosition )

			if self.capture.item then
				if self.capture.item.press then
					self.capture.item:press( mousePosition )
				end
			end
		end
	else
		if Input.buttonReleased( self.capture.button ) then
			if self.capture.item then
				if self.capture.item.release then
					self.capture.item:release( mousePosition )
				end
			end

			self.capture.depth = -1
			self.capture.item = nil
			self.capture.button = -1
		end
	end

	if self.capture.item then
		if self.capture.item.updateMouseInput then
			self.capture.item:updateMouseInput( deltaTime, mousePosition )
		end
	end

	self.hostButton:update( deltaTime, mousePosition )
	self.joinButton:update( deltaTime, mousePosition )
	self.backButton:update( deltaTime, mousePosition )
end

function StatePlayMenu:render()
	self.titleLabel:render()

	self.hostButton:render()
	self.joinButton:render()
	self.backButton:render()
end

if IS_CLIENT then
	Game:addState( StatePlayMenu )
end