local DEFAULT_FONT_INFO = "./assets/fonts/verdana12.bin"
local DEFAULT_FONT_TEXTURE = "./assets/fonts/verdana12.dds"

EditorLabel =
{
	fontIndex = -1,
	position = {0,0},
	size = {0,0},
	depth = 0,
	textColor = {1.0, 1.0, 1.0, 1.0},
	alignText = {},
}

function EditorLabel.create( position, size, text )
	if EditorLabel.fontIndex < 0 then
		EditorLabel.fontIndex = Assets.loadFont( DEFAULT_FONT_INFO, DEFAULT_FONT_TEXTURE )
	end
	
	local label = {}
	setmetatable( label, { __index = EditorLabel } )
	
	label.position = tableVal( position )
	label.size = tableVal( size )
	label.depth = 0
	label.alignText = EditorAlignText.create( label, EditorLabel.fontIndex, text )
	label.alignText:align( ALIGN_NEAR, ALIGN_NEAR )
	
	return label
end

function EditorLabel.createWithText( text )
	assert( isstring( text ), "Text must be a string." )

	return EditorLabel.create( nil, {0, GUI_BUTTON_HEIGHT}, text )
end

function EditorLabel:setPosition( position )
	self.position[1] = position[1]
	self.position[2] = position[2]

	self.alignText:align()
end

function EditorLabel:setSize( size )
	self.size[1] = size[1]
	self.size[2] = size[2]

	self.alignText:align()
end

function EditorLabel:setDepth( depth )
	self.depth = depth
end

function EditorLabel:setTextAlignment( horizontal, vertical )
	self.alignText:align( horizontal, vertical )
end

function EditorLabel:checkCapture( capture, mousePosition )
end

function EditorLabel:updateMouseInput( deltaTime )
end

function EditorLabel:update( deltaTime )
end

function EditorLabel:render()
	self.alignText:render( self.depth, self.textColor )
end

function EditorLabel:loadFont( info, texture )
	local fontIndex = Assets.loadFont( info, texture )
	self.alignText:setFontIndex( fontIndex )
end

function EditorLabel:setText( text )
	self.alignText:setText( text )
end