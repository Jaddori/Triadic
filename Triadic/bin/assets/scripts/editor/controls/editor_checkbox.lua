local DEFAULT_BACKGROUND_TEXTURE = "./assets/textures/white.dds"
local DEFAULT_CHECK_TEXTURE = "./assets/textures/check02.dds"
local DEFAULT_SIZE = 18

EditorCheckbox = 
{
	backgroundTextureIndex = -1,
	checkTextureIndex = -1,
	position = {0,0},
	size = {DEFAULT_SIZE, DEFAULT_SIZE},
	depth = 0,
	checkColor = {1,1,1,1},
	color = {0.4, 0.4, 0.4, 1.0},
	hoverColor = {0.75, 0.75, 0.75, 1.0},
	pressColor = {0.35, 0.35, 0.35, 1.0},

	hovered = false,
	pressed = false,
	checked = false,

	onCheck = nil,
}

function EditorCheckbox.create( position, size )
	if EditorCheckbox.backgroundTextureIndex < 0 then
		EditorCheckbox.backgroundTextureIndex = Assets.loadTexture( DEFAULT_BACKGROUND_TEXTURE )
	end

	if EditorCheckbox.checkTextureIndex < 0 then
		EditorCheckbox.checkTextureIndex = Assets.loadTexture( DEFAULT_CHECK_TEXTURE )
	end

	local checkbox =
	{
		position = tableVal( position ),
		size = size,
		depth = 0,
		hovered = false,
		pressed = false,
		checked = false,
	}

	setmetatable( checkbox, { __index = EditorCheckbox } )

	return checkbox
end

function EditorCheckbox.createDefault()
	return EditorCheckbox.create( nil, { DEFAULT_SIZE, DEFAULT_SIZE } )
end

function EditorCheckbox:setPosition( position )
	self.position[1] = position[1]
	self.position[2] = position[2]
end

function EditorCheckbox:setSize( size )
end

function EditorCheckbox:setDepth( depth )
	self.depth = depth
end

function EditorCheckbox:checkCapture( capture, mousePosition )
	if capture.depth < self.depth then
		if insideRect( self.position, self.size, mousePosition ) then
			capture.depth = self.depth
			capture.item = self
		end
	end
end

function EditorCheckbox:updateMouseInput( deltaTime, mousePosition )
	self.pressed = insideRect( self.position, self.size, mousePosition )
end

function EditorCheckbox:press( mousePosition )
	self.hovered = true
end

function EditorCheckbox:release( mousePosition )
	if insideRect( self.position, self.size, mousePosition ) then
		self.checked = not self.checked

		if self.onCheck then
			self:onCheck()
		end
	end

	self.hovered = false
	self.pressed = false
end

function EditorCheckbox:update( deltaTime, mousePosition )
	self.hovered = insideRect( self.position, self.size, mousePosition )
end

function EditorCheckbox:render()
	local color = self.color
	if self.pressed then
		color = self.pressColor
	elseif self.hovered then
		color = self.hoverColor
	end

	-- draw background
	Graphics.queueQuad( self.backgroundTextureIndex, self.position, self.size, self.depth, color )

	-- draw check
	if self.checked then
		Graphics.queueQuad( self.checkTextureIndex, self.position, self.size, self.depth + GUI_DEPTH_SMALL_INC, self.checkColor )
	end
end