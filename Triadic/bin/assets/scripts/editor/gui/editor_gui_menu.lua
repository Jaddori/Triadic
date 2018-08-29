GUI_MENU_HEIGHT = GUI_BUTTON_HEIGHT
GUI_MENU_DEPTH = 0.5

GUI_MENU_SETTINGS_BUTTON_WIDTH = 96
GUI_MENU_FILE_BUTTON_WIDTH = 96

local menu =
{
	textureIndex = -1,
	items = {},
	position = {0,0},
	size = {0,0},
	depth = GUI_MENU_DEPTH,
	color = {0.5, 0.5, 0.5, 1.0},

	file = {},
	settings = {},
}

function menu:load()
	self.textureIndex = Assets.loadTexture( "./assets/textures/white.dds" )
	self.size = {WINDOW_WIDTH, GUI_MENU_HEIGHT}

	self.file = doscript( "editor/gui/editor_gui_menu_file.lua" )
	self.settings = doscript( "editor/gui/editor_gui_menu_settings.lua" )

	local xoffset = 0
	xoffset = xoffset + self.file:load( xoffset, self.items, self.depth )
	xoffset = xoffset + self.settings:load( xoffset, self.items, self.depth )
end

function menu:update( deltaTime )
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

function menu:render()
	-- render background
	Graphics.queueQuad( self.textureIndex, self.position, self.size, self.depth, self.color )

	-- render items
	for _,v in pairs(self.items) do
		v:render()
	end
	
	self.file:render()
	self.settings:render()
end

return menu