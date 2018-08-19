EditorInputbox =
{
	label = {},
	textbox = {},
	position = {0,0},
	size = {0,0},
}

function EditorInputbox.create( position, width, text )
	local result = 
	{
		position = position,
		size = {0,0},
		label = {},
		textbox = {},
	}

	setmetatable( result, { __index = EditorInputbox } )

	local yoffset = 0
	result.label = EditorLabel.create( {position[1], position[2] + yoffset}, text )
	yoffset = yoffset + result.label:getHeight()

	result.textbox = EditorTextbox.create( {position[1], position[2] + yoffset}, {width, GUI_BUTTON_HEIGHT} )
	result.textbox.onFocus = function( textbox )
		textbox:selectAll()
	end
	yoffset = yoffset + GUI_BUTTON_HEIGHT

	result.size = {width, yoffset}

	return result
end

function EditorInputbox:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCaptured = false }
	
	local result = self.label:update( deltaTime )
	setCapture( result, capture )

	result = self.textbox:update( deltaTime )
	setCapture( result, capture )

	return capture
end

function EditorInputbox:render()
	self.label:render()
	self.textbox:render()
end