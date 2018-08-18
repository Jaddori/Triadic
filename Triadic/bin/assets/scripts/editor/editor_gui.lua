GUI_MENU_HEIGHT = 0
GUI_PANEL_WIDTH = 256
GUI_BUTTON_HEIGHT = 0
local MENU_SETTINGS_BUTTON_WIDTH = 128
local MENU_FILE_BUTTON_WIDTH = 128

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
		color = {0.5,0.5,0.5,0.75},
		
		file =
		{
			visible = false,
			items = {},
			newButton = nil,
			openButton = nil,
			saveButton = nil,
			saveAsButton = nil,
			exitButton = nil,
			
			onNew = nil,
			onOpen = nil,
			onSave = nil,
			onSaveAs = nil,
			onExit = nil,
		},
		settings =
		{
			visible = false,
			items = {},
			showGridButton = nil,
			showOrigoButton = nil,
			
			onShowGrid = nil,
			onShowOrigo = nil,
		},
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
				visibleLabel = {},
				visibleCheckbox = {},
				nameLabel = {},
				nameTextbox = {},
				positionLabel = {},
				positionTextbox = {},
				orientationLabel = {},
				orientationTextbox = {},
				scaleLabel = {},
				scaleTextbox = {},
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
		
		items = {},
	},
}

-- menu
function gui.menu:load()
	self.textureIndex = Assets.loadTexture( "./assets/textures/white.dds" )
	self.size = {WINDOW_WIDTH,GUI_MENU_HEIGHT}

	local xoffset = 0
	xoffset = xoffset + gui.menu.file:load( xoffset )
	xoffset = xoffset + gui.menu.settings:load( xoffset )
end

function gui.menu:update( deltaTime )
	self.file:update( deltaTime )
	self.settings:update( deltaTime )
	
	for _,v in pairs(self.items) do
		v:update( deltaTime )
	end
end

function gui.menu:render()
	Graphics.queueQuad( self.textureIndex, self.position, self.size, self.color )

	for _,v in pairs(self.items) do
		v:render()
	end
	
	self.file:render()
	self.settings:render()
end

-- (menu) file
function gui.menu.file:load( xoffset )
	local width = 64
	
	local fileButton = EditorButton.create( {xoffset, 0}, {width, GUI_MENU_HEIGHT}, "File" )
	fileButton.onClick = function( self )
		gui.menu.file.visible = true
	end
	gui.menu.items[#gui.menu.items+1] = fileButton
	
	-- drop down menu
	local yoffset = GUI_MENU_HEIGHT
	self.newButton = EditorButton.create( {xoffset, yoffset}, {MENU_FILE_BUTTON_WIDTH, GUI_BUTTON_HEIGHT}, "New" )
	self.newButton.onClick = function( button )
		if self.onNew then
			self.onNew()
		end
	end
	yoffset = yoffset + GUI_BUTTON_HEIGHT
	
	self.openButton = EditorButton.create( {xoffset, yoffset}, {MENU_FILE_BUTTON_WIDTH, GUI_BUTTON_HEIGHT}, "Open" )
	self.openButton.onClick = function( button )
		if self.onOpen then
			self.onOpen()
		end
	end
	yoffset = yoffset + GUI_BUTTON_HEIGHT
	
	self.saveButton = EditorButton.create( {xoffset, yoffset}, {MENU_FILE_BUTTON_WIDTH, GUI_BUTTON_HEIGHT}, "Save" )
	self.saveButton.onClick = function( button )
		if self.onSave then
			self.onSave()
		end
	end
	yoffset = yoffset + GUI_BUTTON_HEIGHT
	
	self.saveAsButton = EditorButton.create( {xoffset, yoffset}, {MENU_FILE_BUTTON_WIDTH, GUI_BUTTON_HEIGHT}, "Save As" )
	self.saveAsButton.onClick = function( button )
		if self.onSaveAs then
			self.onSaveAs()
		end
	end
	yoffset = yoffset + GUI_BUTTON_HEIGHT
	
	self.exitButton = EditorButton.create( {xoffset, yoffset}, {MENU_FILE_BUTTON_WIDTH, GUI_BUTTON_HEIGHT}, "Exit" )
	self.exitButton.onClick = function( self )
		gui.menu.file.visible = false
		
		if gui.menu.file.onExit then
			gui.menu.file.onExit()
		end
	end
	yoffset = yoffset + GUI_BUTTON_HEIGHT
	
	self.items[#self.items+1] = self.newButton
	self.items[#self.items+1] = self.openButton
	self.items[#self.items+1] = self.saveButton
	self.items[#self.items+1] = self.saveAsButton
	self.items[#self.items+1] = self.exitButton
	
	return width
end

function gui.menu.file:update( deltaTime )
	if self.visible then
		for _,v in pairs(self.items) do
			v:update( deltaTime )
		end
		
		if Input.buttonReleased( Buttons.Left ) then
			self.visible = false
		end
	end
end

function gui.menu.file:render()
	if self.visible then
		for _,v in pairs(self.items) do
			v:render()
		end
	end
end

-- (menu) settings
function gui.menu.settings:load( xoffset )
	local width = 64
	
	local settingsButton = EditorButton.create( {xoffset, 0}, {width, GUI_MENU_HEIGHT}, "Settings" )
	settingsButton.onClick = function( self )
		gui.menu.settings.visible = true
	end
	gui.menu.items[#gui.menu.items+1] = settingsButton

	local pos = {xoffset, 0}
	local yoffset = GUI_MENU_HEIGHT
	
	self.showGridButton = EditorButton.create( {pos[1], pos[2]+yoffset}, {MENU_SETTINGS_BUTTON_WIDTH, GUI_BUTTON_HEIGHT}, "Show grid" )
	self.showGridButton.onClick = function( self )
		gui.menu.settings.visible = false
		
		if gui.menu.settings.onShowGrid then
			gui.menu.settings.onShowGrid()
		end
	end
	yoffset = yoffset + GUI_BUTTON_HEIGHT
	
	self.showOrigoButton = EditorButton.create( {pos[1], pos[2]+yoffset}, {MENU_SETTINGS_BUTTON_WIDTH, GUI_BUTTON_HEIGHT}, "Show origo" )
	self.showOrigoButton.onClick = function( self )
		gui.menu.settings.visible = false
		
		if gui.menu.settings.onShowOrigo then
			gui.menu.settings.onShowOrigo()
		end
	end
	yoffset = yoffset + GUI_BUTTON_HEIGHT
	
	self.items[#self.items+1] = self.showGridButton
	self.items[#self.items+1] = self.showOrigoButton
	
	return width
end

function gui.menu.settings:update( deltaTime )
	if self.visible then
		for _,v in pairs(self.items) do
			v:update( deltaTime )
		end
		
		if Input.buttonReleased( Buttons.Left ) then
			self.visible = false
		end
	end
end

function gui.menu.settings:render()
	if self.visible then
		for _,v in pairs(self.items) do
			v:render()
		end
	end
end

-- context menu
function gui.contextMenu:addItem( text, tag )
	local count = #self.items
	
	local button = EditorButton.create( {0, count*GUI_BUTTON_HEIGHT}, {self.size[1], GUI_BUTTON_HEIGHT}, text )
	button.tag = tag
	button.onClick = function( self )
		if gui.contextMenu.onClick then
			gui.contextMenu.onClick( button )
		end
	end
	
	self.items[count+1] = button
	self.size[2] = #self.items * GUI_BUTTON_HEIGHT
	
	return button
end

function gui.contextMenu:show( position )
	self.position[1] = position[1]
	self.position[2] = position[2]
	self.visible = true
	
	for i=1, #self.items do
		self.items[i].position[1] = self.position[1]
		self.items[i].position[2] = self.position[2] + (i-1) * GUI_BUTTON_HEIGHT
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
	
	local prevItem = self.curItem
	
	self.curItem = index
	self.items[self.curItem].color = { 0.75, 0.75, 0.0, 1.0 }
	
	if index == 1 then self.curTab = "info"
	elseif index == 2 then self.curTab = "entities"
	else self.curTab = "prefabs" end
	
	if prevItem ~= self.curItem then
		if gui.panel.tabs[self.curTab].onShow then
			gui.panel.tabs[self.curTab]:onShow()
		end
	end
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

	self.visibleLabel = EditorLabel.create( {pos[1] + padding, pos[2] + padding + yoffset}, "Visible:" )
	yoffset = yoffset + self.visibleLabel:getHeight() + padding

	self.visibleCheckbox = EditorCheckbox.create( {pos[1] + padding, pos[2] + padding + yoffset} )
	yoffset = yoffset + self.visibleCheckbox.size[2] + padding
	
	self.nameLabel = EditorLabel.create( {pos[1] + padding, pos[2] + padding + yoffset}, "Name:" )
	yoffset = yoffset + self.nameLabel:getHeight() + padding
	
	self.nameTextbox = EditorTextbox.create( {pos[1] + padding, pos[2] + padding + yoffset}, {size[1]-padding*2, 24} )
	self.nameTextbox.onFocus = function( textbox )
		textbox:selectAll()
	end
	yoffset = yoffset + 24 + padding
	
	self.positionLabel = EditorLabel.create( {pos[1] + padding, pos[2] + padding + yoffset}, "Position:" )
	yoffset = yoffset + self.nameLabel:getHeight() + padding
	
	self.positionTextbox = EditorTextbox.create( {pos[1] + padding, pos[2] + padding + yoffset}, {size[1]-padding*2, 24} )
	self.positionTextbox.onFocus = function( textbox )
		textbox:selectAll()
	end
	yoffset = yoffset + 24 + padding
	
	self.orientationLabel = EditorLabel.create( {pos[1] + padding, pos[2] + padding + yoffset}, "Orientation:" )
	yoffset = yoffset + self.orientationLabel:getHeight() + padding
	
	self.orientationTextbox = EditorTextbox.create( {pos[1] + padding, pos[2] + padding + yoffset}, {size[1]-padding*2, 24} )
	self.orientationTextbox.onFocus = function( textbox )
		textbox:selectAll()
	end
	yoffset = yoffset + 24 + padding
	
	self.scaleLabel = EditorLabel.create( {pos[1] + padding, pos[2] + padding + yoffset}, "Scale:" )
	yoffset = yoffset + self.scaleLabel:getHeight() + padding
	
	self.scaleTextbox = EditorTextbox.create( {pos[1] + padding, pos[2] + padding + yoffset}, {size[1]-padding*2, 24} )
	self.scaleTextbox.onFocus = function( textbox )
		textbox:selectAll()
	end
	yoffset = yoffset + 24 + padding
	
	self.componentsLabel = EditorLabel.create( {pos[1] + padding, pos[2] + padding + yoffset}, "Components:" )
	yoffset = yoffset + self.componentsLabel:getHeight() + padding
end

function gui.panel.tabs.info:update( deltaTime )
	local result = false

	if self.visibleLabel:update( deltaTime ) then result = true end
	if self.visibleCheckbox:update( deltaTime ) then result = true end
	if self.nameLabel:update( deltaTime ) then result = true end
	if self.nameTextbox:update( deltaTime ) then result = true end
	if self.positionLabel:update( deltaTime ) then result = true end
	if self.positionTextbox:update( deltaTime ) then result = true end
	if self.orientationLabel:update( deltaTime ) then result = true end
	if self.orientationTextbox:update( deltaTime ) then result = true end
	if self.scaleLabel:update( deltaTime ) then result = true end
	if self.scaleTextbox:update( deltaTime ) then result = true end
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
	self.visibleLabel:render()
	self.visibleCheckbox:render()
	self.nameLabel:render()
	self.nameTextbox:render()
	self.positionLabel:render()
	self.positionTextbox:render()
	self.orientationLabel:render()
	self.orientationTextbox:render()
	self.scaleLabel:render()
	self.scaleTextbox:render()
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
		self.visibleCheckbox.checked = entity.visible
		self.nameTextbox.text = entity.name
		self.positionTextbox:setText( stringVec( entity.position ) )
		self.orientationTextbox:setText( stringVec( entity.orientation ) )
		self.scaleTextbox:setText( stringVec( entity.scale ) )

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
		self.visibleCheckbox.checked = false
		self.nameTextbox:setText( "" )
		self.positionTextbox:setText( "" )
		self.orientationTextbox:setText( "" )
		self.scaleTextbox:setText( "" )
	end
end

function gui.panel.tabs.info:refresh()
	self.positionTextbox:setText( stringVec( self.entity.position ) )
	self.orientationTextbox:setText( stringVec( self.entity.orientation ) )
	self.scaleTextbox:setText( stringVec( self.entity.scale ) )
end

-- entities
function gui.panel.tabs.entities:load() end

function gui.panel.tabs.entities:update( deltaTime )
	local result = false
	
	for _,v in pairs(self.items) do
		if v:update( deltaTime ) then
			result = true
		end
	end
	
	return result
end

function gui.panel.tabs.entities:render()
	for _,v in pairs(self.items) do
		v:render()
	end
end

function gui.panel.tabs.entities:onShow()
	for _,v in pairs(self.items) do
		v.text = v.tag.name
	end
end

function gui.panel.tabs.entities:addEntity( entity, onSelect )
	local pos = gui.panel.contentPosition
	local size = gui.panel.contentSize
	local padding = 4
	local yoffset = #self.items * (GUI_BUTTON_HEIGHT + padding)

	local button = EditorButton.create( {pos[1] + padding, pos[2] + padding + yoffset}, {size[1] - padding*2, GUI_BUTTON_HEIGHT}, entity.name )
	button.tag = entity
	button.onClick = onSelect
	
	self.items[#self.items+1] = button
end

function gui.panel.tabs.entities:clear()
	local count = #self.items
	for i=1, count do self.items[i] = nil end
end

-- prefabs
function gui.panel.tabs.prefabs:load() end
function gui.panel.tabs.prefabs:update( deltaTime ) end
function gui.panel.tabs.prefabs:render() end

function gui:load()
	doscript( "editor/editor_button.lua" )
	doscript( "editor/editor_label.lua" )
	doscript( "editor/editor_textbox.lua" )
	doscript( "editor/editor_checkbox.lua" )
	
	self.fontIndex = Assets.loadFont( "./assets/fonts/verdana12.bin", "./assets/fonts/verdana12.dds" )
	local font = Assets.getFont( self.fontIndex )
	self.fontHeight = font:getHeight()
	
	GUI_BUTTON_HEIGHT = self.fontHeight + 4 -- 2 pixels of padding at top and bottom
	GUI_MENU_HEIGHT = GUI_BUTTON_HEIGHT
	
	-- create menu
	self.menu:load()
	
	-- create panel
	self.panel.textureIndex = Assets.loadTexture( "./assets/textures/white.dds" )
	self.panel.position = { WINDOW_WIDTH - GUI_PANEL_WIDTH, GUI_MENU_HEIGHT }
	self.panel.size = { GUI_PANEL_WIDTH, WINDOW_HEIGHT - GUI_MENU_HEIGHT }
	
	self.panel.contentPosition = { self.panel.position[1], self.panel.position[2] + GUI_BUTTON_HEIGHT }
	self.panel.contentSize = { self.panel.size[1], self.panel.size[2] - GUI_BUTTON_HEIGHT }
	
	self.panel.tabBar:load()
	
	self.panel.tabs.info:load()
	self.panel.tabs.entities:load()
	self.panel.tabs.prefabs:load()
end

function gui:update( deltaTime )
	local result = false

	-- menu
	self.menu:update( deltaTime )
	
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
	
	if not result then
		local mousePosition = Input.getMousePosition()
		result = insideRect( self.panel.position, self.panel.size, mousePosition ) 
	end
	
	return result
end

function gui:render()
	-- menu
	self.menu:render()
	
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