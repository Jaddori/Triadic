local DEFAULT_TEXTURE = "./assets/textures/white.dds"
local DEFAULT_FONT_INFO = "./assets/fonts/verdana12.bin"
local DEFAULT_FONT_TEXTURE = "./assets/fonts/verdana12.dds"
local CARET_BLINK_FREQUENCY = 0.35

EditorTextbox =
{
	fontIndex = -1,
	fontHeight = -1,
	textureIndex = -1,
	position = {0,0},
	size = {0,0},
	color = {0.5, 0.5, 0.5, 0.5},
	hoverColor = {0.75, 0.75, 0.75, 1},
	pressColor = {0.35, 0.35, 0.35, 1},
	focusColor = { 0.65, 0.65, 0.15, 1},
	textColor = {1.0, 1.0, 1.0, 1.0},
	text = "",
	readOnly = false,
	
	hovered = false,
	pressed = false,
	focus = false,
	
	caretVisible = false,
	caretElapsed = 0.0,
}

function EditorTextbox.create( position, size )
	if EditorTextbox.textureIndex < 0 then
		EditorTextbox.textureIndex = Assets.loadTexture( DEFAULT_TEXTURE )
	end
	
	if EditorTextbox.fontIndex < 0 then
		EditorTextbox.fontIndex = Assets.loadFont( DEFAULT_FONT_INFO, DEFAULT_FONT_TEXTURE )
		EditorTextbox.fontHeight = Assets.getFont( EditorTextbox.fontIndex ):getHeight()
	end
	
	local textbox = {}
	setmetatable( textbox, { __index = EditorTextbox } )
	
	textbox.position = position
	textbox.size = size
	textbox.hovered = false
	textbox.pressed = false
	textbox.focus = false
	textbox.readOnly = false
	
	return textbox
end

function EditorTextbox:update( deltaTime )
	local result = false
	
	local mousePosition = Input.getMousePosition()
	
	if insideRect( self.position, self.size, mousePosition ) and not self.readOnly then
		self.hovered = true
		
		if Input.buttonDown( Buttons.Left ) then
			self.pressed = true
		else
			if self.pressed then
				self.focus = true
			end
			
			self.pressed = False
		end
		
		result = true
	else
		self.hovered = false
		self.pressed = False
		
		if Input.buttonReleased( Buttons.Left ) then
			self.focus = false
			self.caretVisible = false
		end
	end
	
	if self.focus then
		-- get text input
		local textInput = Input.getTextInput()
		
		if textInput:len() > 0 then
			self.text = self.text .. textInput
			result = true
		end
		
		-- blink the caret
		self.caretElapsed = self.caretElapsed + deltaTime
		if self.caretElapsed >= CARET_BLINK_FREQUENCY then
			self.caretElapsed = self.caretElapsed - CARET_BLINK_FREQUENCY
			
			self.caretVisible = not self.caretVisible
		end
		
		-- remove focus if Return is pressed
		if Input.keyReleased( Keys.Return) then
			self.focus = false
			self.caretVisible = false
		end
	end
	
	return result
end

function EditorTextbox:render()
	local color = self.color
	if self.pressed then
		color = self.pressColor
	elseif self.hovered then
		color = self.hoverColor
	elseif self.focus then
		color = self.focusColor
	end
	
	Graphics.queueQuad( self.textureIndex, self.position, self.size, color )
	
	local textPosition = {self.position[1] + 8, self.position[2]}
	local text = self.text
	if self.caretVisible then
		text = text .. "|"
	end
	Graphics.queueText( self.fontIndex, text, textPosition, self.textColor )
end