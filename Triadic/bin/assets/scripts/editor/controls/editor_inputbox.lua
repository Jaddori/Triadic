EditorInputbox =
{
	label = {},
	textbox = {},
	position = {0,0},
	size = {0,0},
	depth = 0,
}

function EditorInputbox.create( position, width, text )
	local result = 
	{
		position = tableVal( position ),
		size = {0,0},
		depth = 0,
		label = {},
		textbox = {},
	}

	setmetatable( result, { __index = EditorInputbox } )

	local yoffset = 0
	result.label = EditorLabel.create( {result.position[1], result.position[2] + yoffset}, {width, GUI_BUTTON_HEIGHT}, text )
	yoffset = yoffset + GUI_BUTTON_HEIGHT

	result.textbox = EditorTextbox.create( {result.position[1], result.position[2] + yoffset}, {width, GUI_BUTTON_HEIGHT} )
	result.textbox.onFocus = function( textbox )
		textbox:selectAll()
	end
	yoffset = yoffset + GUI_BUTTON_HEIGHT

	result.size = {width, yoffset}

	return result
end

function EditorInputbox:setPosition( position )
	self.label:setPosition( position )
	self.textbox:setPosition( {position[1], position[2] + self.label.size[2]} )
end

function EditorInputbox:setSize( size )
	self.label:setSize( {size[1], GUI_BUTTON_HEIGHT} )
	self.textbox:setSize( {size[1], GUI_BUTTON_HEIGHT} )
end

function EditorInputbox:setDepth( depth )
	self.depth = depth
	self.label.depth = depth
	self.textbox.depth = depth
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