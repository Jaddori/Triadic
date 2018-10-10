StateJoinGame =
{
	name = "StateJoinGame",

	titleLabel = nil,

	ipInput = nil,
	connectButton = nil,
	backButton = nil,

	capture =
	{
		depth = -1,
		button = -1,
		item = nil,
		focusItem = nil,
	}
}

function StateJoinGame:load()
	self.titleLabel = EditorLabel.create( Vec2.create(), Vec2.create({WINDOW_WIDTH, 128}), "Triadic" )
	self.titleLabel:loadFont( "./assets/fonts/verdana18.bin", "./assets/fonts/verdana18.dds" )
	self.titleLabel:setTextAlignment( ALIGN_MIDDLE, ALIGN_MIDDLE )

	self.ipInput = EditorInputbox.create( Vec2.create({32,128}), 256, "IP:" )
	self.ipInput.textbox:setText( "127.0.0.1" )

	self.connectButton = EditorButton.create( Vec2.create({32+256-128, 128+self.ipInput.size[2]+8}), Vec2.create({128,32}), "Connect" )
	self.connectButton.onClick = function( button )
		Game:setState( "StateGame" )
	end

	self.backButton = EditorButton.create( Vec2.create({32,256+32}), Vec2.create({128,24}), "Back" )
	self.backButton.onClick = function( button )
		Game:popState()
	end
end

function StateJoinGame:update( deltaTime )
	local mousePosition = Input.getMousePosition()

	if self.capture.button == -1 then
		if Input.buttonPressed( Buttons.Left ) then
			self.capture.button = Buttons.Left
		end

		if self.capture.button > -1 then
			local prevFocusItem = self.capture.focusItem

			self.ipInput:checkCapture( self.capture, mousePosition )
			self.connectButton:checkCapture( self.capture, mousePosition )
			self.backButton:checkCapture( self.capture, mousePosition )

			if self.capture.focusItem ~= self.capture.item then
				self.capture.focusItem = nil
			end
			
			if prevFocusItem and prevFocusItem ~= self.capture.focusItem then
				if prevFocusItem.unsetFocus then
					prevFocusItem:unsetFocus()
				end
			end

			if self.capture.focusItem then
				if self.capture.focusItem.setFocus then
					self.capture.focusItem:setFocus()
				end
			end

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
	else
		if self.capture.focusItem then
			local stillFocused = self.capture.focusItem:updateKeyboardInput()
			if not stillFocused then
				self.capture.focusItem = nil
			end
		end
	end

	self.ipInput:update( deltaTime, mousePosition )
	self.connectButton:update( deltaTime, mousePosition )
	self.backButton:update( deltaTime, mousePosition )
end

function StateJoinGame:render()
	self.titleLabel:render()

	self.ipInput:render()
	self.connectButton:render()
	self.backButton:render()
end

if IS_CLIENT then
	Game:addState( StateJoinGame )
end