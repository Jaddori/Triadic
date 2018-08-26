GUI_DEFAULT_BACKGROUND_TEXTURE = "./assets/textures/white.dds"
GUI_DEFAULT_FONT_INFO = "./assets/fonts/verdana12.bin"
GUI_DEFAULT_FONT_TEXTURE = "./assets/fonts/verdana12.dds"
GUI_DEPTH_INC = 0.01
GUI_DEPTH_SMALL_INC = 0.001

GUI_BUTTON_HEIGHT = 0
GUI_WINDOW_BASE_DEPTH = 0.0

local gui =
{
	fontIndex = -1,
	fontHeight = 0,
	
	menu = {},	
	panel =	{},
	componentList = {},
	contextMenu = {},

	openWindows = {},
}

-- windows
function gui:focusWindow( window )
	local openWindows = {}
	if window and window.visible then
		openWindows[1] = window
	end

	for i=1, #self.openWindows do
		if self.openWindows[i] ~= window and self.openWindows[i].visible then
			openWindows[#openWindows+1] = self.openWindows[i]
		end
	end

	for i=1, #openWindows do
		openWindows[i]:setDepth( GUI_WINDOW_BASE_DEPTH - GUI_DEPTH_INC*i )
	end

	self.openWindows = openWindows
end

function gui:load()
	-- load controls
	local controlFiles = Filesystem.getFiles( "./assets/scripts/editor/controls/*" )
	for _,v in pairs(controlFiles) do
		doscript( "editor/controls/" .. v )
	end
	
	self.fontIndex = Assets.loadFont( "./assets/fonts/verdana12.bin", "./assets/fonts/verdana12.dds" )
	local font = Assets.getFont( self.fontIndex )
	self.fontHeight = font:getHeight()
	
	GUI_BUTTON_HEIGHT = self.fontHeight + 4 -- 2 pixels of padding at top and bottom
	GUI_MENU_HEIGHT = GUI_BUTTON_HEIGHT
	
	-- create menu
	self.menu = doscript( "editor/gui/editor_gui_menu.lua" )
	self.menu:load()
	
	-- create panel
	self.panel = doscript( "editor/gui/editor_gui_panel.lua" )
	self.panel:load()
	self.panel.tabs[GUI_TAB_INFO].onAddComponent = function()
		self.componentList.visible = not self.componentList.visible
	end

	-- create component list
	self.componentList = doscript( "editor/gui/editor_gui_component_list.lua" )
	self.componentList:load()

	-- create context menu
	self.contextMenu = doscript( "editor/gui/editor_gui_context_menu.lua" )
	self.contextMenu:load()
end

function gui:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	-- menu
	local result = self.menu:update( deltaTime )
	setCapture( result, capture )
	
	result = self.panel:update( deltaTime )
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
	
	self.panel:render()
	
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