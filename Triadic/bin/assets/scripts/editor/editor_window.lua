local DEFAULT_TEXTURE = "./assets/textures/white.dds"
local DEFAULT_CROSS_TEXTURE = "./assets/textures/cross.dds"
local DEFAULT_FONT_INFO = "./assets/fonts/verdana12.bin"
local DEFAULT_FONT_TEXTURE = "./assets/fonts/verdana12.dds"
EDITOR_WINDOW_TITLEBAR_HEIGHT = 24
EDITOR_WINDOW_DEFAULT_WIDTH = 256
EDITOR_WINDOW_DEFAULT_HEIGHT = 128
EDITOR_WINDOW_CROSS_SIZE = 16

EditorWindow =
{
	visible = false,
	title = "",
	position = {0,0},
	size = {0,0},
	titlebarSize = {0,EDITOR_WINDOW_TITLEBAR_HEIGHT},

	crossSize = {EDITOR_WINDOW_CROSS_SIZE, EDITOR_WINDOW_CROSS_SIZE},
	crossCaptured = false,
	crossHovered = false,
	crossPressed = false,
	crossColor = {1,1,1,1},
	crossHoverColor = {1,0,0,1},
	crossPressColor = {0.5,0,0,1},

	textureIndex = -1,
	crossTextureIndex = -1,
	backgroundColor = {0.35, 0.35, 0.35, 1.0},

	fontIndex = -1,
	titlebarColor = {0.45, 0.45, 0.45, 1.0},
	titlebarTextColor = {1,1,1,1},

	items = {},

	hovered = false,
	pressed = false,
	movementOffset = {0,0},

	padding = 4,
}

function EditorWindow.create( title, position, size )
	if EditorWindow.textureIndex < 0 then
		EditorWindow.textureIndex = Assets.loadTexture( DEFAULT_TEXTURE )
		EditorWindow.crossTextureIndex = Assets.loadTexture( DEFAULT_CROSS_TEXTURE )
		EditorWindow.fontIndex = Assets.loadFont( DEFAULT_FONT_INFO, DEFAULT_FONT_TEXTURE )
	end

	local result =
	{
		visible = true,
		title = title,
		position = position or {0,GUI_MENU_HEIGHT},
		size = size or {EDITOR_WINDOW_DEFAULT_WIDTH, EDITOR_WINDOW_DEFAULT_HEIGHT},
		titlebarSize = {0, EDITOR_WINDOW_TITLEBAR_HEIGHT},

		items = {},

		hovered = false,
		pressed = false,
		movementOffset = {0,0},

		crossSize = {EDITOR_WINDOW_CROSS_SIZE, EDITOR_WINDOW_CROSS_SIZE},
		crossCaptured = false,
	}

	result.titlebarSize[1] = result.size[1]

	setmetatable( result, { __index = EditorWindow } )

	return result
end

function EditorWindow:addItem( item )
	self.items[#self.items+1] = item

	self:layout()
end

function EditorWindow:layout()
	local penultimateHeight = 0
	local yoffset = self.titlebarSize[2] + self.padding
	for _,v in pairs(self.items) do
		v:setPosition( {self.position[1] + self.padding, self.position[2] + yoffset} )
		v:setSize( {self.size[1] - self.padding*2, v.size[2]} )

		yoffset = yoffset + v.size[2] + self.padding
		penultimateHeight = yoffset + self.padding
	end

	self.size[2] = penultimateHeight
end

function EditorWindow:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	-- update window
	local mousePosition = Input.getMousePosition()
	if insideRect( self.position, self.size, mousePosition ) then
		capture.mouseCaptured = true

		if not self.titlebarCaptured and not self.crossCaptured then
			if Input.buttonPressed( Buttons.Left ) then
				local crossPosition = { self.position[1] + self.size[1] - self.crossSize[1], self.position[2] }
				if insideRect( crossPosition, self.crossSize, mousePosition ) then
					self.crossCaptured = true
				elseif insideRect( self.position, self.titlebarSize, mousePosition ) then
					self.titlebarCaptured = true
					self.movementOffset[1] = mousePosition[1] - self.position[1]
					self.movementOffset[2] = mousePosition[2] - self.position[2]
				end
			end
		else
			if Input.buttonDown( Buttons.Left ) then
				if not self.crossCaptured then
					self.position[1] = mousePosition[1] - self.movementOffset[1]
					self.position[2] = mousePosition[2] - self.movementOffset[2]

					-- clamp position to be inside window
					if self.position[1] < 0 then
						self.position[1] = 0
					elseif self.position[1] > ( WINDOW_WIDTH - GUI_PANEL_WIDTH - self.size[1] ) then
						self.position[1] = ( WINDOW_WIDTH - GUI_PANEL_WIDTH - self.size[1] )
					end

					if self.position[2] < GUI_MENU_HEIGHT then
						self.position[2] = GUI_MENU_HEIGHT
					elseif self.position[2] > ( WINDOW_HEIGHT - self.size[2] ) then
						self.position[2] = ( WINDOW_HEIGHT - self.size[2] )
					end

					self:layout()
				end
			else
				local crossPosition = { self.position[1] + self.size[1] - self.crossSize[1], self.position[2] }
				if insideRect( crossPosition, self.crossSize, mousePosition ) then
					self.visible = false
				end

				self.crossCaptured = false
				self.titlebarCaptured = false
			end
		end
	else
		if not Input.buttonDown( Buttons.Left ) then
			self.crossCaptured = false
		end
	end

	local crossPosition = { self.position[1] + self.size[1] - self.crossSize[1], self.position[2] }
	if insideRect( crossPosition, self.crossSize, mousePosition ) then
		self.crossHovered = true
	else
		self.crossHovered = false
	end

	-- update items
	for _,v in pairs(self.items) do
		local result = v:update( deltaTime )
		setCapture( result, capture )
	end

	return capture
end

function EditorWindow:render()
	if self.visible then
		-- render background
		Graphics.queueQuad( self.textureIndex, self.position, self.size, self.backgroundColor )
		Graphics.queueQuad( self.textureIndex, self.position, self.titlebarSize, self.titlebarColor )

		-- render title
		local padding = 4
		local textPosition = {self.position[1] + padding, self.position[2]}
		Graphics.queueText( self.fontIndex, self.title, textPosition, self.titlebarTextColor )

		-- render cross
		local crossColor = self.crossColor
		if self.crossHovered then
			if self.crossCaptured then
				crossColor = self.crossPressColor
			else
				crossColor = self.crossHoverColor
			end
		end
		padding = ( EDITOR_WINDOW_TITLEBAR_HEIGHT - self.crossSize[1] ) * 0.5
		local crossPosition = {self.position[1] + self.size[1] - self.crossSize[1] - padding, self.position[2] + padding }
		Graphics.queueQuad( self.crossTextureIndex, crossPosition, self.crossSize, crossColor )

		-- render items
		for _,v in pairs(self.items) do
			v:render()
		end
	end
end