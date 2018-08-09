local DEFAULT_TEXTURE = "./assets/textures/white.dds"
local DEFAULT_FONT_INFO = "./assets/fonts/verdana12.bin"
local DEFAULT_FONT_TEXTURE = "./assets/fonts/verdana12.dds"

EditorButton =
{
	textureIndex = -1,
	position = {0,0},
	size = {0,0},
	color = {0.5,0.5,0.5,1},
	hoverColor = { 0.75, 0.75, 0.75, 1 },
	pressColor = { 0.35, 0.35, 0.35, 1 },
	
	fontIndex = -1,
	text = "",
	textColor = {1,1,1,1},
}

function EditorButton.create( position, size, text )
	if EditorButton.textureIndex < 0 then
		EditorButton.textureIndex = Assets.loadTexture( DEFAULT_TEXTURE )
	end
	
	if EditorButton.fontIndex < 0 then
		EditorButton.fontIndex = Assets.loadFont( DEFAULT_FONT_INFO, DEFAULT_FONT_TEXTURE )
	end
	
	local button = {}
	setmetatable( button, { __index = EditorButton } )
	
	button.position = position
	button.size = size
	button.hovered = false
	button.pressed = false
	button.text = text or "Button"
	
	return button
end

function EditorButton:update( deltaTime )
	local result = false
	local mousePosition = Input.getMousePosition()
	
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
		
		result = true
	else
		self.hovered = false
		self.pressed = false
		
		if Input.buttonReleased( Buttons.Left ) then
			self:onUnclicked()
		end
	end
	
	return result
end

function EditorButton:render()
	local color = self.color
	if self.pressed then
		color = self.pressColor
	elseif self.hovered then
		color = self.hoverColor
	end
	
	Graphics.queueQuad( self.textureIndex, self.position, self.size, color )
	
	local textPosition = { self.position[1] + 8, self.position[2] }
	Graphics.queueText( self.fontIndex, self.text, textPosition, self.textColor )
end

function EditorButton:onClick()
end

function EditorButton:onUnclicked()
end