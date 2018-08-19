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
	selectionColor = { 0.35, 0.35, 0.35, 1.0 },
	disabledColor = {0.45, 0.45, 0.45, 1},
	disabledTextColor = {0.75, 0.75, 0.75, 1.0},
	text = "",
	readOnly = false,
	disabled = false,
	
	hovered = false,
	pressed = false,
	focus = false,
	
	caretVisible = false,
	caretElapsed = 0.0,
	caretIndex = 0,
	
	selectionStart = 0,
	selectionEnd = 0,

	onFocus = nil,
	onFinish = nil,
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
	textbox.disabled = false
	
	return textbox
end

function EditorTextbox:setPosition( position )
	self.position[1] = position[1]
	self.position[2] = position[2]
end

function EditorTextbox:setSize( size )
	self.size[1] = size[1]
	self.size[2] = size[2]
end

function EditorTextbox:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCaptured = false }
	
	local mousePosition = Input.getMousePosition()
	
	if not self.disabled then
		if insideRect( self.position, self.size, mousePosition ) and not self.readOnly then
			self.hovered = true
			
			if Input.buttonDown( Buttons.Left ) then
				self.pressed = true
			else
				if self.pressed then
					self.focus = true
					self.caretIndex = self.text:len()

					if self.onFocus then
						self:onFocus()
					end
				end
				
				self.pressed = false
			end
			
			capture.mouseCaptured = true
		else
			self.hovered = false
			self.pressed = false
			
			if Input.buttonReleased( Buttons.Left ) then
				if self.focus then
					self:onFinish()
				end
				
				self.focus = false
				self.caretVisible = false
				self.selectionStart = self.caretIndex
				self.selectionEnd = self.caretIndex
			end
		end
		
		if self.focus then
			-- get text input
			local textInput = Input.getTextInput()
			
			if textInput:len() > 0 then
				-- if there was a selection, replace the selected text
				if self.selectionStart ~= self.selectionEnd then
					local first = math.min( self.selectionStart, self.selectionEnd )
					local last = math.max( self.selectionStart, self.selectionEnd )
					
					local preText = self.text:sub( 1, first )
					local postText = self.text:sub( last+1, self.text:len() )
					
					self.text = preText .. postText
					self.caretIndex = first
					self.selectionStart = first
					self.selectionEnd = first
				end
			
				-- add the new text at the caret position
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
				
				self.selectionStart = self.caretIndex
				self.selectionEnd = self.caretIndex
			end
			
			-- delete input if Backspace is pressed
			local textLength = self.text:len()
			if Input.keyRepeated( Keys.Backspace ) and textLength > 0 then
				-- delete selection
				if self.selectionStart ~= self.selectionEnd then
					local first = math.min( self.selectionStart, self.selectionEnd )
					local last = math.max( self.selectionStart, self.selectionEnd )
					
					local preSelectionText = ""
					if first > 0 then preSelectionText = self.text:sub( 1, first ) end
					
					local postSelectionText = ""
					if last < #self.text then postSelectionText = self.text:sub( last+1, textLength ) end
					
					self.text = preSelectionText .. postSelectionText
					
					self.caretIndex = first
					self.selectionStart = first
					self.selectionEnd = first
				
				-- delete from caret index
				elseif self.caretIndex > 0 then
					if self.caretIndex >= textLength then
						self.text = self.text:sub( 1, textLength-1 )
					else
						local first = self.text:sub(1, self.caretIndex-1)
						local second = self.text:sub(self.caretIndex+1, textLength)
						
						self.text = first .. second
					end
					
					self.caretIndex = self.caretIndex - 1
				end
				
				textLength = self.text:len()
			end
			
			-- delete input if Delete is pressed
			if Input.keyRepeated( Keys.Delete ) then
				-- delete selection
				if self.selectionStart ~= self.selectionEnd then
					local first = math.min( self.selectionStart, self.selectionEnd )
					local last = math.max( self.selectionStart, self.selectionEnd )
					
					local preSelectionText = ""
					if first > 0 then preSelectionText = self.text:sub( 1, first ) end
					
					local postSelectionText = ""
					if last < #self.text then postSelectionText = self.text:sub( last+1, textLength ) end
					
					self.text = preSelectionText .. postSelectionText
					
					self.caretIndex = first
					self.selectionStart = first
					self.selectionEnd = first
				
				-- delete from caret index
				elseif self.caretIndex < textLength then
					local preText = self.text:sub( 1, self.caretIndex )
					local postText = self.text:sub( self.caretIndex+2 )
					
					self.text = preText .. postText
				end
			end
			
			-- move the caret with arrow keys
			if Input.keyRepeated( Keys.Left ) and self.caretIndex > 0 then
				self.caretIndex = self.caretIndex - 1
				
				if Input.keyDown( Keys.LeftShift ) or Input.keyDown( Keys.RightShift ) then
					self.selectionEnd = self.caretIndex
				else
					self.selectionStart = self.caretIndex
					self.selectionEnd = self.selectionStart
				end
			end
			
			if Input.keyRepeated( Keys.Right ) then
				if self.caretIndex < textLength then
					self.caretIndex = self.caretIndex + 1
				end
				
				if Input.keyDown( Keys.LeftShift ) or Input.keyDown( Keys.RightShift ) then
					self.selectionEnd = self.caretIndex
				else
					self.selectionStart = self.caretIndex
					self.selectionEnd = self.selectionStart
				end
			end

			-- move the caret with Home/End keys
			if Input.keyRepeated( Keys.Home ) then
				self.caretIndex = 0

				if Input.keyDown( Keys.LeftShift ) or Input.keyDown( Keys.RightShift ) then
					self.selectionEnd = self.caretIndex
				else
					self.selectionStart = self.caretIndex
					self.selectionEnd = self.selectionStart
				end
			end

			if Input.keyRepeated( Keys.End ) then
				self.caretIndex = #self.text

				if Input.keyDown( Keys.LeftShift ) or Input.keyDown( Keys.RightShift ) then
					self.selectionEnd = self.caretIndex
				else
					self.selectionStart = self.caretIndex
					self.selectionEnd = self.selectionStart
				end
			end
			
			-- blink the caret
			self.caretElapsed = self.caretElapsed + deltaTime
			if self.caretElapsed >= CARET_BLINK_FREQUENCY then
				self.caretElapsed = self.caretElapsed - CARET_BLINK_FREQUENCY
				
				self.caretVisible = not self.caretVisible
			end
			
			-- remove focus if Return is pressed
			if Input.keyReleased( Keys.Return) or Input.keyReleased( Keys.KeypadReturn ) then
				self.focus = false
				self.caretVisible = false
				
				self:onFinish()
			end
			
			-- select all text
			if Input.keyDown( Keys.LeftControl ) or Input.keyDown( Keys.RightControl ) then
				if Input.keyPressed( Keys.A ) then
					self:selectAll()
				end
			end

			capture.keyboardCaptured = true
		end
	end

	return capture
end

function EditorTextbox:render()
	local color = self.color
	local textColor = self.textColor

	if self.disabled then
		color = self.disabledColor
		textColor = self.disabledTextColor
	elseif self.pressed then
		color = self.pressColor
	elseif self.hovered then
		color = self.hoverColor
	elseif self.focus then
		color = self.focusColor
	end
	
	local textPadding = 8
	
	-- draw background
	Graphics.queueQuad( self.textureIndex, self.position, self.size, color )
	
	-- draw text
	local textPosition = {self.position[1] + textPadding, self.position[2]}
	Graphics.queueText( self.fontIndex, self.text, textPosition, textColor )
	if self.caretVisible then
		local xoffset = self.font:measureText( self.text:sub(1, self.caretIndex) )[1] - 2
		Graphics.queueText( self.fontIndex, "|", {textPosition[1]+xoffset, textPosition[2]}, self.textColor )
	end
	
	-- draw selection
	if self.selectionStart ~= self.selectionEnd then
		local preSelectionWidth = 0
		--local postSelectionWidth = 0
		
		local first = self.selectionStart
		local last = self.selectionEnd
		
		-- make sure first is actually the first
		if last < first then last, first = first, last end
		
		if first > 0 then
			local preSelectionText = self.text:sub( 1, first )
			preSelectionWidth = self.font:measureText( preSelectionText )[1]
		end
		
		local selectionText = self.text:sub( first+1, last )
		local selectionWidth = self.font:measureText( selectionText )[1]
		
		local position = { self.position[1] + preSelectionWidth + textPadding, self.position[2]+2 }
		local size = { selectionWidth, self.size[2]-4 }
		
		Graphics.queueQuad( self.textureIndex, position, size, self.selectionColor )
	end
end

function EditorTextbox:onFinish()
end

function EditorTextbox:setText( text )
	self.text = text
	self.caretIndex = self.text:len()
	self.selectionStart = self.caretIndex
	self.selectionEnd = self.caretIndex
end

function EditorTextbox:selectText( first, last )
	self.selectionStart = first
	if self.selectionStart < 0 then
		self.selectionStart = 0
	end

	self.selectionEnd = last
	if self.selectionEnd > self.text:len() then
		self.selectionEnd = self.text:len()
	end

	self.caretIndex = self.selectionEnd
end

function EditorTextbox:selectAll()
	self:selectText( 0, self.text:len() )
end