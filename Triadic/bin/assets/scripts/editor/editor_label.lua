local DEFAULT_FONT_INFO = "./assets/fonts/verdana12.bin"
local DEFAULT_FONT_TEXTURE = "./assets/fonts/verdana12.dds"

EditorLabel =
{
	fontIndex = -1,
	fontHeight = -1,
	position = {0,0},
	textColor = {1.0, 1.0, 1.0, 1.0},
	text = "",
}

function EditorLabel.create( position, text )
	if EditorLabel.fontIndex < 0 then
		EditorLabel.fontIndex = Assets.loadFont( DEFAULT_FONT_INFO, DEFAULT_FONT_TEXTURE )
		EditorLabel.fontHeight = Assets.getFont( EditorLabel.fontIndex ):getHeight()
	end
	
	local label = {}
	setmetatable( label, { __index = EditorLabel } )
	
	label.position = position
	label.text = text
	
	return label
end

function EditorLabel:setPosition( position )
	self.position[1] = position[1]
	self.position[2] = position[2]
end

function EditorLabel:setSize( size )
end

function EditorLabel:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCapture = false }

	return capture
end

function EditorLabel:render()
	Graphics.queueText( self.fontIndex,  self.text, self.position, self.textColor )
end

function EditorLabel:loadFont( info, texture )
	self.fontIndex = Assets.loadFont( info, texture )
	self.fontHeight = Assets.getFont( self.fontIndex ):getHeight()
end

function EditorLabel:getHeight()
	return self.fontHeight
end