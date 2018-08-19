GUI_MENU_HEIGHT = 0
GUI_PANEL_WIDTH = 256
GUI_BUTTON_HEIGHT = 0
GUI_COMPONENT_LIST_WIDTH = 128
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
			onCompile = nil,
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
				subItems = {},
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

	componentList =
	{
		visible = false,
		textureIndex = -1,
		position = {0,0},
		size = {0,0},
		color = { 0.35, 0.35, 0.35, 1.0 },
		items = {},

		onClick = nil,
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
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	local result = self.file:update( deltaTime )
	setCapture( result, capture )

	result = self.settings:update( deltaTime )
	setCapture( result, capture )
	
	for _,v in pairs(self.items) do
		result = v:update( deltaTime )
		setCapture( result, capture )
	end

	return capture
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

	self.compileButton = EditorButton.create( {xoffset, yoffset}, {MENU_FILE_BUTTON_WIDTH, GUI_BUTTON_HEIGHT}, "Compile" )
	self.compileButton.onClick = function( button )
		if self.onCompile then
			self.onCompile()
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
	self.items[#self.items+1] = self.compileButton
	self.items[#self.items+1] = self.exitButton
	
	return width
end

function gui.menu.file:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	if self.visible then
		for _,v in pairs(self.items) do
			local result = v:update( deltaTime )
			setCapture( result, capture )
		end
		
		if Input.buttonReleased( Buttons.Left ) then
			self.visible = false
		end
	end

	return capture
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
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	if self.visible then
		for _,v in pairs(self.items) do
			local result = v:update( deltaTime )
			setCapture( result, capture )
		end
		
		if Input.buttonReleased( Buttons.Left ) then
			self.visible = false
		end
	end

	return capture
end

function gui.menu.settings:render()
	if self.visible then
		for _,v in pairs(self.items) do
			v:render()
		end
	end
end

-- component list
function gui.componentList:load()
	self.textureIndex = Assets.loadTexture( "./assets/textures/white.dds" )

	self.position = {WINDOW_WIDTH - GUI_PANEL_WIDTH - GUI_COMPONENT_LIST_WIDTH, GUI_MENU_HEIGHT}
	self.size = {GUI_COMPONENT_LIST_WIDTH, WINDOW_HEIGHT-GUI_MENU_HEIGHT}
end

function gui.componentList:addItem( text, tag )
	local count = #self.items

	local padding = 4

	local button = EditorButton.create( {self.position[1]+padding, self.position[2]+padding+count*(GUI_BUTTON_HEIGHT+padding)}, {self.size[1]-padding*2, GUI_BUTTON_HEIGHT}, text )
	button.tag = tag
	button.index = count + 1
	button.onClick = function( button )
		if self.onClick then
			self.onClick( button )
		end

		self.visible = false
	end

	self.items[count+1] = button
	
	return button
end

function gui.componentList:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	local mousePosition = Input.getMousePosition()
	capture.mouseCaptured = insideRect( self.position, self.size, mousePosition )

	for _,v in pairs(self.items) do
		local result = v:update( deltaTime )
		setCapture( result, capture )
	end

	return capture
end

function gui.componentList:render()
	-- render background
	Graphics.queueQuad( self.textureIndex, self.position, self.size, self.color )

	-- render items
	for _,v in pairs(self.items) do
		v:render()
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
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	for _,v in pairs(self.items) do
		local result = v:update( deltaTime )
		setCapture( result, capture )
	end
	
	if Input.buttonReleased( Buttons.Left ) then
		self.visible = false
	end
	
	return capture
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
	local pos = gui.panel.contentPosition
	local size = gui.panel.contentSize
	local padding = 4
	local yoffset = 0

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

	self.visibleLabel = EditorLabel.create( {pos[1] + padding, pos[2] + padding + yoffset}, "Visible:" )
	yoffset = yoffset + self.visibleLabel:getHeight() + padding

	self.visibleCheckbox = EditorCheckbox.create( {pos[1] + padding, pos[2] + padding + yoffset} )
	yoffset = yoffset + self.visibleCheckbox.size[2] + padding

	self.componentsLabel = EditorLabel.create( {pos[1] + padding, pos[2] + padding + yoffset}, "Components:" )
	yoffset = yoffset + self.componentsLabel:getHeight() + padding

	self.addComponentButton = EditorButton.create( {pos[1] + padding, pos[2] + padding + yoffset}, {size[1]-padding*2, GUI_BUTTON_HEIGHT}, "Add Component" )
	self.addComponentButton.onClick = function( button )
		gui.componentList.visible = not gui.componentList.visible
	end
	yoffset = yoffset + GUI_BUTTON_HEIGHT + padding

	-- add to items list
	self.items[#self.items+1] = self.nameLabel
	self.items[#self.items+1] = self.nameTextbox
	self.items[#self.items+1] = self.positionLabel
	self.items[#self.items+1] = self.positionTextbox
	self.items[#self.items+1] = self.orientationLabel
	self.items[#self.items+1] = self.orientationTextbox
	self.items[#self.items+1] = self.scaleLabel
	self.items[#self.items+1] = self.scaleTextbox
	self.items[#self.items+1] = self.visibleLabel
	self.items[#self.items+1] = self.visibleCheckbox
	self.items[#self.items+1] = self.componentsLabel
	self.items[#self.items+1] = self.addComponentButton
end

function gui.panel.tabs.info:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	for _,v in pairs(self.items) do
		local result = v:update( deltaTime )
		setCapture( result, capture )
	end

	for _,v in pairs(self.subItems) do
		local result = v:update( deltaTime )
		setCapture( result, capture )
	end
	
	return capture
end

function gui.panel.tabs.info:render()
	-- render items
	for _,v in pairs(self.items) do
		v:render()
	end

	for _,v in pairs(self.subItems) do
		v:render()
	end
end

function gui.panel.tabs.info:setEntity( entity )
	-- clear items
	count = #self.subItems
	for i=0, count do self.subItems[i]=nil end
	
	if entity then
		-- set name and position
		self.visibleCheckbox.checked = entity.visible
		self.nameTextbox.text = entity.name
		self.positionTextbox:setText( stringVec( entity.position ) )
		self.orientationTextbox:setText( stringVec( entity.orientation ) )
		self.scaleTextbox:setText( stringVec( entity.scale ) )

		-- create new items
		self.entity = entity
		
		local padding = 4
		local position = gui.panel.contentPosition
		local size = gui.panel.contentSize
		local yoffset = self.addComponentButton.position[2] + self.addComponentButton.size[2] + 8
		for _,v in pairs(self.entity.components) do
			local button = EditorButton.create( {position[1]+padding, yoffset}, {size[1]-padding*2, GUI_BUTTON_HEIGHT}, v.name )
			button.onClick = function( button )
				v:showInfoWindow()
			end
			self.subItems[#self.subItems+1] = button
			yoffset = yoffset + GUI_BUTTON_HEIGHT + padding
		end

		self.addComponentButton.disabled = false
	else
		self.visibleCheckbox.checked = false
		self.nameTextbox:setText( "" )
		self.positionTextbox:setText( "" )
		self.orientationTextbox:setText( "" )
		self.scaleTextbox:setText( "" )
		self.addComponentButton.disabled = true
		gui.componentList.visible = false
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
	local capture = { mouseCaptured = false, keyboardCaptured = false }
	
	for _,v in pairs(self.items) do
		local result = v:update( deltaTime )
		setCapture( result, capture )
	end
	
	return capture
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

function gui.panel.tabs.entities:removeEntity( entity )
	local index = 0
	for i=1, #self.items do
		if self.items[i].tag == entity then
			index = i
			break
		end
	end

	if index > 0 then
		self.items[index] = nil
	end
end

function gui.panel.tabs.entities:clear()
	local count = #self.items
	for i=1, count do self.items[i] = nil end
end

-- prefabs
function gui.panel.tabs.prefabs:load() end
function gui.panel.tabs.prefabs:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	return capture
end
function gui.panel.tabs.prefabs:render() end

function gui:load()
	doscript( "editor/editor_button.lua" )
	doscript( "editor/editor_label.lua" )
	doscript( "editor/editor_textbox.lua" )
	doscript( "editor/editor_checkbox.lua" )
	doscript( "editor/editor_inputbox.lua" )
	doscript( "editor/editor_window.lua" )
	
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

	self.componentList:load()
	
	self.panel.tabs.info:load()
	self.panel.tabs.entities:load()
	self.panel.tabs.prefabs:load()
end

function gui:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	-- menu
	local result = self.menu:update( deltaTime )
	setCapture( result, capture )
	
	-- panel
	for _,v in pairs(self.panel.tabBar.items) do
		result = v:update( deltaTime )
		setCapture( result, capture )
	end
	
	-- tabs
	result = self.panel.tabs[self.panel.tabBar.curTab]:update( deltaTime )
	setCapture( result, capture )

	-- component list
	if self.componentList.visible then
		result = self.componentList:update( deltaTime )
		setCapture( result, capture )
	end

	-- component info windows
	for _,v in pairs(Entity.windowList) do
		result = v:update( deltaTime )
		setCapture( result, capture )
	end
	
	-- context menu
	if self.contextMenu.visible then
		result = self.contextMenu:update( deltaTime )
		setCapture( result, capture )
	end
	
	if not capture.mouseCaptured then
		local mousePosition = Input.getMousePosition()
		capture.mouseCaptured = insideRect( self.panel.position, self.panel.size, mousePosition ) 
	end
	
	return capture
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
	
	-- component list
	if self.componentList.visible then
		self.componentList:render()
	end

	-- component info windows
	for _,v in pairs(Entity.windowList) do
		v:render()
	end

	-- context menu
	if self.contextMenu.visible then
		self.contextMenu:render()
	end
end

return gui