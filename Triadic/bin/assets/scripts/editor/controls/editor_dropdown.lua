local DEFAULT_ARROW_DOWN_TEXTURE = "./assets/textures/editor/dropdown_arrow_down.dds"
local DEFAULT_ARROW_UP_TEXTURE = "./assets/textures/editor/dropdown_arrow_up.dds"
local DEFAULT_ARROW_SIZE = 16

EditorDropdown = 
{
	fontIndex = -1,
	fontHeight = -1,
	textureIndex = -1,
	position = {0,0},
	size = {0,0},
	depth = 0,
	color = {0.5, 0.5, 0.5, 1.0},
	hoverColor = {0.75, 0.75, 0.75, 1.0},
	pressColor = {0.35, 0.35, 0.35, 1.0},
	textColor = {1,1,1,1},
	expanded = false,
	hovered = false,
	pressed = false,
	selectedIndex = 0,

	-- arrow
	arrowDownTextureIndex = -1,
	arrowUpTextureIndex = -1,
	arrowPosition = {0,0},
	arrowSize = {DEFAULT_ARROW_SIZE, DEFAULT_ARROW_SIZE},
	arrowColor = {1,1,1,1},

	-- menu
	menu =
	{
		itemSize = 0,
		items = {},
	},

	onItemSelected = nil,
}

function EditorDropdown.create( position, size )
	if EditorDropdown.textureIndex < 0 then
		EditorDropdown.textureIndex = Assets.loadTexture( GUI_DEFAULT_BACKGROUND_TEXTURE )
	end

	if EditorDropdown.arrowDownTextureIndex < 0 then
		EditorDropdown.arrowDownTextureIndex = Assets.loadTexture( DEFAULT_ARROW_DOWN_TEXTURE )
		EditorDropdown.arrowUpTextureIndex = Assets.loadTexture( DEFAULT_ARROW_UP_TEXTURE )
	end

	if EditorDropdown.fontIndex < 0 then
		EditorDropdown.fontIndex = Assets.loadFont( GUI_DEFAULT_FONT_INFO, GUI_DEFAULT_FONT_TEXTURE )
		EditorDropdown.fontHeight = Assets.getFont( EditorDropdown.fontIndex ):getHeight()
	end

	local result = 
	{
		position = tableVal( position ),
		size = tableVal( size ),
		depth = 0,
		hovered = false,
		pressed = false,
		expanded = false,
		selectedIndex = 0,

		arrowPosition = {0,0},

		menu = 
		{
			itemSize = 0,
			items = {},
		},
	}

	setmetatable( result, { __index = EditorDropdown } )

	return result
end

function EditorDropdown:expand( expanded )
	self.expanded = expanded or not self.expanded
end

function EditorDropdown:addItem( text, tag )
	local index = #self.menu.items+1
	self.menu.items[index] = 
	{
		text = text,
		tag = tag,
		hovered = false,
		pressed = false,
		index = index,
	}

	local font = Assets.getFont( self.fontIndex )
	local textWidth = font:measureText( text )[1]

	if textWidth > self.menu.itemSize then
		self.menu.itemSize = textWidth
	end

	self.selectedIndex = 1
end

function EditorDropdown:updateArrowPosition()
	local arrowPadding = (self.size[2] - self.arrowSize[2]) * 0.5
	self.arrowPosition[1] = self.position[1] + self.size[1] - self.arrowSize[1] - arrowPadding
	self.arrowPosition[2] = self.position[2] + arrowPadding
end

function EditorDropdown:setPosition( position )
	self.position[1] = position[1]
	self.position[2] = position[2]

	self:updateArrowPosition()
end

function EditorDropdown:setSize( size )
	self.size[1] = size[1]
	self.size[2] = size[2]

	self:updateArrowPosition()
end

function EditorDropdown:setDepth( depth )
	self.depth = depth
end

function EditorDropdown:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	local mousePosition = Input.getMousePosition()

	-- update menu
	local itemPressed = false
	if self.expanded then
		local position = {self.position[1], self.position[2] + self.size[2]}
		local size = {self.size[1], self.size[2]}
		if self.menu.itemSize > size[1] then
			size[1] = self.menu.itemSize
		end

		for _,v in pairs(self.menu.items) do
			if insideRect( position, size, mousePosition ) then
				capture.mouseCaptured = true

				v.hovered = true

				if Input.buttonDown( Buttons.Left ) then
					v.pressed = true
					itemPressed = true
				else
					if v.pressed then
						self.selectedIndex = v.index

						if self.onItemSelected then
							self:onItemSelected( v )
						end
					end
				end
			else
				v.hovered = false
				v.pressed = false
			end

			position[2] = position[2] + self.size[2]
		end
	end
	
	-- update main box
	if insideRect( self.position, self.size, mousePosition ) then
		capture.mouseCaptured = true

		self.hovered = true
		if Input.buttonDown( Buttons.Left ) then
			self.pressed = true
		else
			if self.pressed then
				self:expand()
			end

			self.pressed = false
		end
	else
		self.hovered = false
		self.pressed = false

		if Input.buttonReleased( Buttons.Left ) then
			self.expanded = false
		end

		if not self.pressed and not itemPressed and Input.buttonDown( Buttons.Left ) then
			self.expanded = false
		end
	end

	return capture
end

function EditorDropdown:render()
	local color = self.color
	if self.pressed then
		color = self.pressColor
	elseif self.hovered or self.expanded then
		color = self.hoverColor
	end

	local textPadding = 8

	-- draw background
	Graphics.queueQuad( self.textureIndex, self.position, self.size, self.depth, color )

	-- draw selected item text
	if self.selectedIndex > 0 then
		local textPosition = { self.position[1] + textPadding, self.position[2] }
		Graphics.queueText( self.fontIndex, self.menu.items[self.selectedIndex].text, textPosition, self.depth + GUI_DEPTH_SMALL_INC, self.textColor )
	end

	-- draw arrow
	local arrowTextureIndex = self.arrowDownTextureIndex
	if self.expanded then
		arrowTextureIndex = self.arrowUpTextureIndex
	end
	Graphics.queueQuad( arrowTextureIndex, self.arrowPosition, self.arrowSize, self.depth + GUI_DEPTH_SMALL_INC, self.arrowColor )

	-- draw menu
	if self.expanded then
		local position = { self.position[1], self.position[2] + self.size[2] }
		local size = { self.size[1], self.size[2] }
		if self.menu.itemSize > size[1] then
			size[1] = self.menu.itemSize
		end
		
		for _,v in pairs(self.menu.items) do
			local color = self.color
			if v.pressed then
				color = self.pressColor
			elseif v.hovered then
				color = self.hoverColor
			end

			-- draw background
			Graphics.queueQuad( self.textureIndex, position, size, self.depth + GUI_DEPTH_SMALL_INC*3, color )

			-- draw text
			Graphics.queueText( self.fontIndex, v.text, {position[1]+textPadding, position[2]}, self.depth + GUI_DEPTH_SMALL_INC*4, self.textColor )

			position[2] = position[2] + self.size[2]
		end
	end
end