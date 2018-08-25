EditorButton =
{
	textureIndex = -1,
	position = {0,0},
	size = {0,0},
	color = {0.5,0.5,0.5,1},
	hoverColor = { 0.75, 0.75, 0.75, 1 },
	pressColor = { 0.35, 0.35, 0.35, 1 },
	disabledColor = { 0.35, 0.35, 0.35, 1.0 },
	
	fontIndex = -1,
	text = "",
	textColor = {1,1,1,1},
	disabledTextColor = {0.75, 0.75, 0.75, 1.0},

	disabled = false,
	hovered = false,
	pressed = false,
}

function EditorButton.create( position, size, text )
	if EditorButton.textureIndex < 0 then
		EditorButton.textureIndex = Assets.loadTexture( GUI_DEFAULT_BACKGROUND_TEXTURE )
	end
	
	if EditorButton.fontIndex < 0 then
		EditorButton.fontIndex = Assets.loadFont( GUI_DEFAULT_FONT_INFO, GUI_DEFAULT_FONT_TEXTURE )
	end
	
	local button = {}
	setmetatable( button, { __index = EditorButton } )
	
	button.position = position
	button.size = size
	button.hovered = false
	button.pressed = false
	button.text = text or "Button"
	button.disabled = false
	
	return button
end

function EditorButton:setPosition( position )
	self.position[1] = position[1]
	self.position[2] = position[2]
end

function EditorButton:setSize( size )
	self.size[1] = size[1]
	self.size[2] = size[2]
end

function EditorButton:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	local mousePosition = Input.getMousePosition()
	
	if not self.disabled then
		if insideRect( self.position, self.size, mousePosition ) then
			self.hovered = true
			
			if Input.buttonDown( Buttons.Left ) then
				self.pressed = true
			else
				if self.pressed then
					self:onClick()
				end
				
				self.pressed = false
			end
			
			capture.mouseCaptured = true
		else
			self.hovered = false
			self.pressed = false
			
			if Input.buttonReleased( Buttons.Left ) then
				self:onUnclicked()
			end
		end
	end
	
	return capture
end

function EditorButton:render()
	local color = self.color
	local textColor = self.textColor

	if self.disabled then
		color = self.disabledColor
		textColor = self.disabledTextColor
	elseif self.pressed then
		color = self.pressColor
	elseif self.hovered then
		color = self.hoverColor
	end
	
	-- render background
	Graphics.queueQuad( self.textureIndex, self.position, self.size, color )
	
	-- render text
	local textPosition = { self.position[1] + 8, self.position[2] }
	Graphics.queueText( self.fontIndex, self.text, textPosition, textColor )
end

function EditorButton:onClick()
end

function EditorButton:onUnclicked()
end