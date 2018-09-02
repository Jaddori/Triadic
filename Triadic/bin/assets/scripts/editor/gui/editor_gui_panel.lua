GUI_PANEL_WIDTH = 256
GUI_PANEL_DEPTH = 0.5

GUI_TAB_INFO = 1
GUI_TAB_ENTITIES = 2
GUI_TAB_PREFABS = 3

local panel =
{
	textureIndex = -1,
	position = {0,0},
	size = {0,0},
	depth = GUI_PANEL_DEPTH,
	color = {0.5, 0.5, 0.5, 1.0},

	contentPosition = {0,0},
	contentSize = {0,0},

	tabBar = {},
	tabs = {},
}

function panel:load()
	self.textureIndex = Assets.loadTexture( GUI_DEFAULT_BACKGROUND_TEXTURE )

	self.position = { WINDOW_WIDTH - GUI_PANEL_WIDTH, GUI_MENU_HEIGHT }
	self.size = { GUI_PANEL_WIDTH, WINDOW_HEIGHT - GUI_MENU_HEIGHT }

	self.contentPosition = { self.position[1], self.position[2] + GUI_BUTTON_HEIGHT }
	self.contentSize = { self.size[1], self.size[2] - GUI_BUTTON_HEIGHT*2 }

	-- load tab bar
	self.tabBar = doscript( "editor/gui/editor_gui_tabbar.lua" )
	self.tabBar:load( self.position, self.depth )

	-- load tabs
	self.tabs[GUI_TAB_INFO] = doscript( "editor/gui/editor_gui_tab_info.lua" )
	self.tabs[GUI_TAB_INFO]:load( self.contentPosition, self.contentSize, self.depth )

	self.tabs[GUI_TAB_ENTITIES] = doscript( "editor/gui/editor_gui_tab_entities.lua" )
	self.tabs[GUI_TAB_ENTITIES]:load( self.contentPosition, self.contentSize, self.depth )

	self.tabs[GUI_TAB_PREFABS] = doscript( "editor/gui/editor_gui_tab_prefabs.lua" )
	self.tabs[GUI_TAB_PREFABS]:load( self.contentPosition, self.contentSize, self.depth )
end

function panel:checkCapture( capture, mousePosition )
	self.tabBar:checkCapture( capture, mousePosition )
	self.tabs[self.tabBar.currentTab]:checkCapture( capture, mousePosition )
end

function panel:update( deltaTime, mousePosition )
	self.tabBar:update( deltaTime, mousePosition )
	self.tabs[self.tabBar.currentTab]:update( deltaTime, mousePosition )

	--[[
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	-- update tab bar
	local currentTab = self.tabBar.currentTab
	local result = self.tabBar:update( deltaTime )
	setCapture( result, capture )

	-- update tabs
	if currentTab ~= self.tabBar.currentTab and self.tabBar.currentTab == GUI_TAB_ENTITIES then
		self.tabs[GUI_TAB_ENTITIES]:onShow()
	end

	result = self.tabs[self.tabBar.currentTab]:update( deltaTime )
	setCapture( result, capture )

	return capture--]]
end

function panel:render()
	-- render background
	Graphics.queueQuad( self.textureIndex, self.position, self.size, self.depth, self.color )

	-- render tab bar
	self.tabBar:render()

	-- render tabs
	self.tabs[self.tabBar.currentTab]:render()
end

return panel