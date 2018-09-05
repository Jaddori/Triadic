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

function EditorInputbox.createWithText( text )
	assert( isstring( text ), "Text must be a string." )

	return EditorInputbox.create( nil, 0, text )
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

function EditorInputbox:checkCapture( capture, mousePosition )
	self.textbox:checkCapture( capture, mousePosition )
end

function EditorInputbox:update( deltaTime, mousePosition )
	self.label:update( deltaTime, mousePosition )
	self.textbox:update( deltaTime, mousePosition )
end

function EditorInputbox:render()
	self.label:render()
	self.textbox:render()
end