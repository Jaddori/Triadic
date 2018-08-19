local DEFAULT_TEXTURE = "./assets/textures/white.dds"
local DEFAULT_FONT_INFO = "./assets/fonts/verdana12.bin"
local DEFAULT_FONT_TEXTURE = "./assets/fonts/verdana12.dds"
EDITOR_LISTBOX_ITEM_HEIGHT = 24
EDITOR_LISTBOX_SCROLLBAR_WIDTH = 12
EDITOR_LISTBOX_SCROLLBAR_HEIGHT = 48

EditorListbox =
{
	fontIndex = -1,
	textureIndex = -1,

	visible = false,
	position = {0,0},
	size = {0,0},
	itemSize = {0,0},
	backgroundColor = {0.25, 0.25, 0.25, 1.0},
	itemColor = {0.5, 0.5, 0.5, 1.0},
	itemHoverColor = {0.75, 0.75, 0.75, 1.0},
	itemPressColor = {0.4, 0.4, 0.4, 1.0},
	textColor = {1,1,1,1},

	scrollbar =
	{
		position = {0,4},
		size = {EDITOR_LISTBOX_SCROLLBAR_WIDTH, EDITOR_LISTBOX_SCROLLBAR_HEIGHT},
		color = { 0.5, 0.5, 0.5, 1.0 },
		hoverColor = { 0.75, 0.75, 0.75, 1.0 },
		pressColor = { 0.4, 0.4, 0.4, 1.0 },
	},

	gutter =
	{
		position = {0,4},
		size = {EDITOR_LISTBOX_SCROLLBAR_WIDTH, 0},

		color = { 0.15, 0.15, 0.15, 1.0 },
	},

	padding = 4,
	items = {},

	onItemSelected = nil,
}

function EditorListbox.create( position, size )
	if EditorListbox.fontIndex < 0 then
		EditorListbox.fontIndex = Assets.loadFont( DEFAULT_FONT_INFO, DEFAULT_FONT_TEXTURE )
		EditorListbox.textureIndex = Assets.loadTexture( DEFAULT_TEXTURE )
	end

	local result =
	{
		position = position or {0,0},
		size = size or {0,0},
		itemSize = {0,EDITOR_LISTBOX_ITEM_HEIGHT},
		visible = true,
		items = {},
		padding = 4,
	}

	result.itemSize[1] = result.size[1]-result.padding*2

	setmetatable( result, { __index = EditorListbox } )

	return result
end

function EditorListbox:setPosition( position )
	self.position[1] = position[1]
	self.position[2] = position[2]
end

function EditorListbox:setSize( size )
	self.size[1] = size[1]
	self.size[2] = size[2]

	self.itemSize[1] = self.size[1] - EDITOR_LISTBOX_SCROLLBAR_WIDTH - self.padding*3
	self.scrollbar.position[1] = self.size[1] - self.scrollbar.size[1] - self.padding
	self.gutter.position[1] = self.size[1] - self.scrollbar.size[1] - self.padding
	self.gutter.size[2] = self.size[2] - self.padding*2
end

function EditorListbox:addItem( text, tag )
	local item =
	{
		text = text,
		tag = tag,
		hovered = false,
		pressed = false,
	}
	self.items[#self.items+1] = item
end

function EditorListbox:getItemPosition( index )
	local position = { self.position[1] + self.padding, self.position[2] + self.padding + ((index-1)*(EDITOR_LISTBOX_ITEM_HEIGHT+self.padding)) }

	return position
end

function EditorListbox:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	local mousePosition = Input.getMousePosition()
	if insideRect( self.position, self.size, mousePosition ) then
		for i=1, #self.items do
			local position = self:getItemPosition( i )

			if insideRect( position, self.itemSize, mousePosition ) then
				self.items[i].hovered = true

				if Input.buttonPressed( Buttons.Left ) then
					self.items[i].pressed = true
				elseif Input.buttonReleased( Buttons.Left ) then
					if self.items[i].pressed then
						self.items[i].pressed = false

						if self.onItemSelected then
							self:onItemSelected( self.items[i] )
						end
					end
				end
			else
				self.items[i].hovered = false

				if not Input.buttonDown( Buttons.Left ) then
					self.items[i].pressed = false
				end
			end
		end
	end

	return capture
end

function EditorListbox:render()
	-- render background
	Graphics.queueQuad( self.textureIndex, self.position, self.size, self.backgroundColor )

	-- render items
	for i=1, #self.items do
		local position = self:getItemPosition( i )
		local itemColor = self.itemColor
		if self.items[i].pressed then
			itemColor = self.itemPressColor
		elseif self.items[i].hovered then
			itemColor = self.itemHoverColor
		end

		Graphics.queueQuad( self.textureIndex, position, self.itemSize, itemColor )

		position[1] = position[1] + self.padding
		Graphics.queueText( self.fontIndex, self.items[i].text, position, self.textColor )
	end

	-- render gutter
	local position = { self.position[1] + self.gutter.position[1], self.position[2] + self.gutter.position[2] }
	Graphics.queueQuad( self.textureIndex, position, self.gutter.size, self.gutter.color )

	-- render scrollbar
	local position = { self.position[1] + self.scrollbar.position[1], self.position[2] + self.scrollbar.position[2] }
	Graphics.queueQuad( self.textureIndex, position, self.scrollbar.size, self.scrollbar.color )
end