GUI_DEFAULT_BACKGROUND_TEXTURE = "./assets/textures/white.dds"
GUI_DEFAULT_FONT_INFO = "./assets/fonts/verdana12.bin"
GUI_DEFAULT_FONT_TEXTURE = "./assets/fonts/verdana12.dds"
GUI_DEPTH_INC = 0.01
GUI_DEPTH_SMALL_INC = 0.001

GUI_BUTTON_HEIGHT = 24
GUI_WINDOW_BASE_DEPTH = 0.0

StateMainMenu =
{
	name = "StateMainMenu",

	titleLabel = nil,

	playButton = nil,
	editorButton = nil,
	quitButton = nil,

	capture =
	{
		depth = -1,
		button = -1,
		item = nil,
		focusItem = nil,
	},
}

function StateMainMenu:load()
	self.titleLabel = EditorLabel.create( Vec2.create(), Vec2.create({WINDOW_WIDTH, 128}), "Triadic" )
	self.titleLabel:loadFont( "./assets/fonts/verdana18.bin", "./assets/fonts/verdana18.dds" )
	self.titleLabel:setTextAlignment( ALIGN_MIDDLE, ALIGN_MIDDLE )

	self.playButton = EditorButton.create( Vec2.create({32,128}), Vec2.create({128,24}), "Play" )
	self.playButton.onClick = function( button )
		--Game:setState( StateGame.name )
		Game:pushState( "StatePlayMenu" )
	end

	self.editorButton = EditorButton.create( Vec2.create({32,128+48}), Vec2.create({128,24}), "Editor" )

	self.quitButton = EditorButton.create( Vec2.create({32,256+32}), Vec2.create({128,24}), "Quit" )
	self.quitButton.onClick = function( button )
		Core.exit()
	end
end

function StateMainMenu:update( deltaTime )
	local mousePosition = Input.getMousePosition()

	if self.capture.button == -1 then
		if Input.buttonPressed( Buttons.Left ) then
			self.capture.button = Buttons.Left
		end

		if self.capture.button > -1 then
			self.playButton:checkCapture( self.capture, mousePosition )
			self.editorButton:checkCapture( self.capture, mousePosition )
			self.quitButton:checkCapture( self.capture, mousePosition )

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

	self.playButton:update( deltaTime, mousePosition )
	self.editorButton:update( deltaTime, mousePosition )
	self.quitButton:update( deltaTime, mousePosition )
end

function StateMainMenu:render()
	self.titleLabel:render()

	self.playButton:render()
	self.editorButton:render()
	self.quitButton:render()
end

if IS_CLIENT then
	Game:addState( StateMainMenu )
	Game:setState( "StateMainMenu" )
end