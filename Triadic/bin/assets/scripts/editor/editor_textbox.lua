local DEFAULT_TEXTURE = "./assets/textures/white.dds"
local DEFAULT_FONT_INFO = "./assets/fonts/verdana12.bin"
local DEFAULT_FONT_TEXTURE = "./assets/fonts/verdana12.dds"
local CARET_BLINK_FREQUENCY = 0.35

EditorTextbox =
{
	fontIndex = -1,
	fontHeight = -1,
	font = nil,
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
	caretIndex = 0,
}

function EditorTextbox.create( position, size )
	if EditorTextbox.textureIndex < 0 then
		EditorTextbox.textureIndex = Assets.loadTexture( DEFAULT_TEXTURE )
	end
	
	if EditorTextbox.fontIndex < 0 then
		EditorTextbox.fontIndex = Assets.loadFont( DEFAULT_FONT_INFO, DEFAULT_FONT_TEXTURE )
		EditorTextbox.font = Assets.getFont( EditorTextbox.fontIndex )
		EditorTextbox.fontHeight = EditorTextbox.font:getHeight()
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
				self.caretIndex = self.text:len()
			end
			
			self.pressed = False
		end
		
		result = true
	else
		self.hovered = false
		self.pressed = False
		
		if Input.buttonReleased( Buttons.Left ) then
			if self.focus then
				self:onFinish()
			end
			
			self.focus = false
			self.caretVisible = false
		end
	end
	
	if self.focus then
		-- get text input
		local textInput = Input.getTextInput()
		
		if textInput:len() > 0 then
			--self.text = self.text .. textInput
			if self.caretIndex <= 0 then
				self.text = textInput .. self.text
			elseif self.caretIndex >= self.text:len() then
				self.text = self.text .. textInput
			else
				local first = self.text:sub(1, self.caretIndex)
				local second = self.text:sub(self.caretIndex+1, self.text:len())
				
				self.text = first .. textInput .. second
			end
			result = true
			
			self.caretIndex = self.caretIndex + textInput:len()
		end
		
		-- delete input if Backspace is pressed
		local textLength = self.text:len()
		if Input.keyRepeated( Keys.Backspace ) and textLength > 0 and self.caretIndex > 0 then
			--self.text = self.text:sub( 1, textLength-1 )
			if self.caretIndex >= textLength then
				self.text = self.text:sub( 1, textLength-1 )
			else
				local first = self.text:sub(1, self.caretIndex-1)
				local second = self.text:sub(self.caretIndex+1, textLength)
				
				self.text = first .. second
			end
			
			self.caretIndex = self.caretIndex - 1
		end
		
		-- move the caret with arrow keys
		if Input.keyRepeated( Keys.Left ) and self.caretIndex > 0 then
			self.caretIndex = self.caretIndex - 1
		end
		
		if Input.keyRepeated( Keys.Right ) and self.caretIndex < textLength then
			self.caretIndex = self.caretIndex + 1
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
			
			self:onFinish()
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
	--local text = self.text
	--if self.caretVisible then
	--	if self.caretIndex <= 0 then
	--		text = "|" .. text
	--	elseif self.caretIndex >= text:len() then
	--		text = text .. "|"
	--	else
	--		local first = text:sub(1, self.caretIndex)
	--		local second = text:sub(self.caretIndex+1, text:len())
	--		text = first .. "|" .. second
	--	end
	--end
	--Graphics.queueText( self.fontIndex, text, textPosition, self.textColor )
	Graphics.queueText( self.fontIndex, self.text, textPosition, self.textColor )
	if self.caretVisible then
		local xoffset = self.font:measureText( self.text:sub(1, self.caretIndex) )[1] - 2
		Graphics.queueText( self.fontIndex, "|", {textPosition[1]+xoffset, textPosition[2]}, self.textColor )
	end
end

function EditorTextbox:onFinish()
end