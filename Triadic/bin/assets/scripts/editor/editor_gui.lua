local MENU_HEIGHT = 0
local PANEL_WIDTH = 256
local BUTTON_HEIGHT = 0

local gui =
{
	fontIndex = -1,
	fontHeight = 0,
	
	menu =
	{
		textureIndex = -1,
		items = {},
		position = {0,0},
		size = {0,0},
		color = {0.5,0.5,0.5,0.75}
	},
	
	panel =
	{
		textureIndex = -1,
		position = {0,0},
		size = {0,0},
		color = {0.5, 0.5, 0.5, 0.75},
		
		contentPosition = {0,0},
		contentSize = {0,0},
		
		tabBar =
		{
			items = {},
			curItem = -1,
			curTab = "",
		},
		
		tabs =
		{
			info =
			{
				items = {},
				entity = nil,
				nameLabel = {},
				nameTextbox = {},
				positionLabel = {},
				positionTextbox = {},
				componentsLabel = {},
			},
			entities =
			{
				items = {},
			},
			prefabs =
			{
				items = {},
			},
		},
	},
	
	contextMenu =
	{
		textureIndex = -1,
		position = {0,0},
		size = {128,0},
		color = {0.5, 0.5, 0.5, 0.75},
		visible = false,
		onClick = nil,
		
		items = {}
	},
}

-- context menu
function gui.contextMenu:addItem( text, tag )
	local count = #self.items
	
	local button = EditorButton.create( {0, count*BUTTON_HEIGHT}, {self.size[1], BUTTON_HEIGHT}, text )
	button.tag = tag
	button.onClick = function( self )
		if gui.contextMenu.onClick then
			gui.contextMenu.onClick( button )
		end
	end
	
	self.items[count+1] = button
	self.size[2] = #self.items * BUTTON_HEIGHT
	
	return button
end

function gui.contextMenu:show( position )
	self.position[1] = position[1]
	self.position[2] = position[2]
	self.visible = true
	
	for i=1, #self.items do
		self.items[i].position[1] = self.position[1]
		self.items[i].position[2] = self.position[2] + (i-1) * BUTTON_HEIGHT
	end
end

function gui.contextMenu:update( deltaTime )
	local result = false

	for _,v in pairs(self.items) do
		if v:update( deltaTime ) then
			result = true
		end
	end
	
	if Input.buttonReleased( Buttons.Left ) then
		self.visible = false
	end
	
	return result
end

function gui.contextMenu:render()
	for _,v in pairs(self.items) do
		v:render()
	end
end

-- tab bar
function gui.panel.tabBar:onClick( index )
	if self.curItem > 0 then
		self.items[self.curItem].color = nil
	end
	
	self.curItem = index
	self.items[self.curItem].color = { 0.75, 0.75, 0.0, 1.0 }
	
	if index == 1 then self.curTab = "info"
	elseif index == 2 then self.curTab = "entities"
	else self.curTab = "prefabs" end
end

function gui.panel.tabBar:load()
	local xoffset = gui.panel.position[1]
	local yoffset = gui.panel.position[2]
	local buttonHeight = gui.fontHeight + 4
	
	-- items
	self.items[1] = EditorButton.create
	(
		{ xoffset, yoffset }, -- position
		{ 64, buttonHeight }, -- size
		"Info"
	)
	self.items[1].onClick = function( self )
		gui.panel.tabBar:onClick( 1 )
	end
	xoffset = xoffset + 64
	
	self.items[2] = EditorButton.create
	(
		{ xoffset, yoffset },
		{ 64, buttonHeight },
		"Entities"
	)
	self.items[2].onClick = function( self )
		gui.panel.tabBar:onClick( 2 )
	end
	xoffset = xoffset + 64
	
	self.items[3] = EditorButton.create
	(
		{ xoffset, yoffset },
		{ 64, buttonHeight },
		"Prefabs"
	)
	self.items[3].onClick = function( self )
		gui.panel.tabBar:onClick( 3 )
	end
	xoffset = xoffset + 64
	
	self:onClick( 1 )
end

-- info
function gui.panel.tabs.info:load()
	-- labels
	local pos = gui.panel.contentPosition
	local size = gui.panel.contentSize
	local padding = 4
	local yoffset = 0
	
	self.nameLabel = EditorLabel.create( {pos[1] + padding, pos[2] + padding + yoffset}, "Name:" )
	yoffset = yoffset + self.nameLabel:getHeight() + padding
	
	self.nameTextbox = EditorTextbox.create( {pos[1] + padding, pos[2] + padding + yoffset}, {size[1]-padding*2, 24} )
	yoffset = yoffset + 24 + padding
	
	self.positionLabel = EditorLabel.create( {pos[1] + padding, pos[2] + padding + yoffset }, "Position:" )
	yoffset = yoffset + self.nameLabel:getHeight() + padding
	
	self.positionTextbox = EditorTextbox.create( {pos[1] + padding, pos[2] + padding + yoffset }, {size[1]-padding*2, 24} )
	yoffset = yoffset + 24 + padding
	
	self.componentsLabel = EditorLabel.create( {pos[1] + padding, pos[2] + padding + yoffset}, "Components:" )
	yoffset = yoffset + self.componentsLabel:getHeight() + padding
end

function gui.panel.tabs.info:update( deltaTime )
	local result = false

	if self.nameLabel:update( deltaTime ) then result = true end
	if self.nameTextbox:update( deltaTime ) then result = true end
	if self.positionLabel:update( deltaTime ) then result = true end
	if self.positionTextbox:update( deltaTime ) then result = true end
	if self.componentsLabel:update( deltaTime ) then result = true end

	for _,v in pairs(self.items) do
		if v:update( deltaTime ) then
			result = true
		end
	end
	
	return result
end

function gui.panel.tabs.info:render()
	-- render title
	self.nameLabel:render()
	self.nameTextbox:render()
	self.positionLabel:render()
	self.positionTextbox:render()
	self.componentsLabel:render()

	-- render items
	for _,v in pairs(self.items) do
		v:render()
	end
end

function gui.panel.tabs.info:setEntity( entity )
	-- clear items
	count = #self.items
	for i=0, count do self.items[i]=nil end
	
	if entity then
		-- set name and position
		self.nameTextbox.text = entity.name
		self.positionTextbox.text = tostring( roundTo( entity.position[1], 2 ) ) .. "," ..
									tostring( roundTo( entity.position[2], 2 ) ) .. "," ..
									tostring( roundTo( entity.position[3], 2 ) )

		-- create new items
		self.entity = entity
		
		local position = gui.panel.contentPosition
		local size = gui.panel.contentSize
		local yoffset = self.componentsLabel.position[2] + self.componentsLabel:getHeight()
		for _,v in pairs(self.entity.components) do
			local allocatedSpace = v:addInfo({position[1], yoffset}, size, self.items)
			yoffset = yoffset + allocatedSpace
		end
	else
		self.nameTextbox.text = ""
		self.positionTextbox.text = ""
	end
end

function gui.panel.tabs.entities:load() end
function gui.panel.tabs.entities:update( deltaTime ) end
function gui.panel.tabs.entities:render() end

function gui.panel.tabs.prefabs:load() end
function gui.panel.tabs.prefabs:update( deltaTime ) end
function gui.panel.tabs.prefabs:render() end

function gui:load()
	doscript( "editor/editor_button.lua" )
	doscript( "editor/editor_label.lua" )
	doscript( "editor/editor_textbox.lua" )
	
	self.fontIndex = Assets.loadFont( "./assets/fonts/verdana12.bin", "./assets/fonts/verdana12.dds" )
	local font = Assets.getFont( self.fontIndex )
	self.fontHeight = font:getHeight()
	
	BUTTON_HEIGHT = self.fontHeight + 4 -- 2 pixels of padding at top and bottom
	MENU_HEIGHT = BUTTON_HEIGHT
	
	-- create menu
	self.menu.textureIndex = Assets.loadTexture( "./assets/textures/white.dds" )
	self.menu.size = {WINDOW_WIDTH,BUTTON_HEIGHT}
	
	self.menu.items[1] = EditorButton.create( {0,0}, {64, BUTTON_HEIGHT}, "File" )
	self.menu.items[2] = EditorButton.create( {64,0}, {64, BUTTON_HEIGHT}, "Etc" )
	self.menu.items[3] = EditorButton.create( {128,0}, {64, BUTTON_HEIGHT}, "..." )
	
	-- create panel
	self.panel.textureIndex = Assets.loadTexture( "./assets/textures/white.dds" )
	self.panel.position = { WINDOW_WIDTH - PANEL_WIDTH, MENU_HEIGHT }
	self.panel.size = { PANEL_WIDTH, WINDOW_HEIGHT - MENU_HEIGHT }
	
	self.panel.contentPosition = { self.panel.position[1], self.panel.position[2] + BUTTON_HEIGHT }
	self.panel.contentSize = { self.panel.size[1], self.panel.size[2] - BUTTON_HEIGHT }
	
	self.panel.tabBar:load()
	
	self.panel.tabs.info:load()
	self.panel.tabs.entities:load()
	self.panel.tabs.prefabs:load()
end

function gui:update( deltaTime )
	local result = false

	-- menu
	for _,v in pairs(self.menu.items) do
		if v:update( deltaTime ) then
			result = true
		end
	end
	
	-- panel
	for _,v in pairs(self.panel.tabBar.items) do
		if v:update( deltaTime ) then
			result = true
		end
	end
	
	-- tabs
	if self.panel.tabs[self.panel.tabBar.curTab]:update( deltaTime ) then
		result = true
	end
	
	-- context menu
	if self.contextMenu.visible then
		if self.contextMenu:update( deltaTime ) then
			result = true
		end
	end
	
	return result
end

function gui:render()
	-- menu
	Graphics.queueQuad( self.menu.textureIndex, self.menu.position, self.menu.size, self.menu.color )
	
	for _,v in pairs(self.menu.items) do
		v:render()
	end
	
	-- panel
	Graphics.queueQuad( self.panel.textureIndex, self.panel.position, self.panel.size, self.panel.color )
	
	for _,v in pairs(self.panel.tabBar.items) do
		v:render()
	end
	
	-- tabs
	self.panel.tabs[self.panel.tabBar.curTab]:render()
	
	-- context menu
	if self.contextMenu.visible then
		self.contextMenu:render()
	end
end

return gui