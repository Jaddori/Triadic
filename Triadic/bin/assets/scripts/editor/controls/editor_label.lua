local DEFAULT_FONT_INFO = "./assets/fonts/verdana12.bin"
local DEFAULT_FONT_TEXTURE = "./assets/fonts/verdana12.dds"

EditorLabel =
{
	fontIndex = -1,
	position = {0,0},
	size = {0,0},
	depth = 0,
	textColor = {1.0, 1.0, 1.0, 1.0},
	--text = "",
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
	--label.text = text
	label.depth = 0
	label.alignText = EditorAlignText.create( label, EditorLabel.fontIndex, text )
	label.alignText:align( ALIGN_NEAR, ALIGN_NEAR )

	--local font = Assets.getFont( EditorLabel.fontIndex )
	--label.size = font:measureText( label.text )
	
	return label
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

function EditorLabel:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCapture = false }

	return capture
end

function EditorLabel:render()
	--Graphics.queueText( self.fontIndex,  self.text, self.position, self.depth, self.textColor )
	self.alignText:render( self.depth, self.textColor )
end

function EditorLabel:loadFont( info, texture )
	--self.fontIndex = Assets.loadFont( info, texture )
	--local font = Assets.getFont( self.fontIndex )

	--self.size = font:measureText( self.text )

	local fontIndex = Assets.loadFont( info, texture )
	self.alignText:setFontIndex( fontIndex )
end

function EditorLabel:setText( text )
	--self.text = tostring( text )
	
	--local font = Assets.getFont( self.fontIndex )
	--self.size = font:measureText( self.text )

	self.alignText:setText( text )
end