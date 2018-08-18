local DEFAULT_TEXTURE = "./assets/textures/white.dds"

ComponentWalkable =
{
	name = "Walkable",
	size = {20,20},
	interval = 1,
	parent = nil,
	nodes = {},
}

ComponentWalkableInfo =
{
	name = "Walkable",
	position = {0,0},
	size = {0,0},
	expanded = true,
	textureIndex = -1,
	color = {0.35, 0.35, 0.35, 1.0},
	titleButton = nil,
	entity = nil,
	walkableComponent = nil,
	curInfo = nil,
	items = {},
}

function ComponentWalkable.create( parent )
	local result =
	{
		parent = parent,
		size = {20,20},
		interval = 1,
		nodes = {},
	}

	setmetatable( result, { __index = ComponentWalkable } )

	return result
end

function ComponentWalkable:calculate()
	local count = #self.nodes
	for i=1, count do self.nodes[i] = nil end

	local startX = self.parent.position[1]
	local endX = self.parent.position[1] + self.size[1]

	local startZ = self.parent.position[3]
	local endZ = self.parent.position[3] + self.size[2]

	for x = startX, endX, self.interval do
		for z = startZ, endZ, self.interval do
			self.nodes[#self.nodes+1] = 
			{
				center = {x, 0, z},
				radius = self.interval*0.5,
				color = {0,1,0,1},
			}
		end
	end
end

function ComponentWalkable:write( file, level )
end

function ComponentWalkable:read( file )
end

function ComponentWalkable:copy( parent )
	local result = self.create( parent )

	copyVec( self.size, result.size )
	result.interval = self.interval

	return result
end

function ComponentWalkable:select( ray )
	local result = false

	local minPosition = {self.parent.position[1], -0.5, self.parent.position[3]}
	local maxPosition = {self.parent.position[1]+self.size[1], 0.5, self.parent.position[3]+self.size[2]}
	local boundingBox = Physics.createAABB( minPosition, maxPosition )

	result = Physics.rayAABB( ray, boundingBox )

	return result
end

function ComponentWalkable:update( deltaTime )
end

function ComponentWalkable:render()
	-- render bounds
	local minPosition = {self.parent.position[1], -0.5, self.parent.position[3]}
	local maxPosition = {self.parent.position[1]+self.size[1], 0.5, self.parent.position[3]+self.size[2]}

	DebugShapes.addAABB( minPosition, maxPosition, {0,1,0,1} )

	if self.parent.selected then
		-- render nodes
		if self.nodes then
			for _,v in pairs(self.nodes) do
				DebugShapes.addSphere( v.center, v.radius, v.color )
			end
		end
	end

	return true
end

function ComponentWalkable:addInfo( position, size, items )
	local info =
	{
		name = "Walkable",
		position = {0,0},
		size = {0,0},
		items = {},
	}
	setmetatable( info, { __index = ComponentWalkableInfo } )

	local padding = 4
	local inset = 8
	local xoffset = position[1] + padding
	local yoffset = position[2]

	-- add title button
	info.titleButton = EditorButton.create( {xoffset, yoffset}, {size[1]-padding*2, 24}, "Walkable:" )
	info.titleButton.tag = info
	yoffset = yoffset + 24

	info.titleButton.onClick = function( self )
		self.tag.expanded = not self.tag.expanded
	end

	-- set position
	info.position[1] = position[1] + padding
	info.position[2] = yoffset
	info.size[1] = size[1] - padding * 2

	-- add sub items
	local sizeLabel = EditorLabel.create( {xoffset+padding, yoffset}, "Size:" )
	yoffset = yoffset + sizeLabel:getHeight()

	local sizeTextbox = EditorTextbox.create( {xoffset+padding, yoffset}, {info.size[1]-padding*2, GUI_BUTTON_HEIGHT} )
	sizeTextbox.text = stringVec( self.size )
	sizeTextbox.onFocus = function( textbox )
		textbox:selectAll()
	end
	sizeTextbox.onFinish = function( textbox )
		local components = split( textbox.text, "," )

		local x = tonumber( components[1] )
		local z = tonumber( components[2] )

		self.size = {x,z}
	end
	yoffset = yoffset + GUI_BUTTON_HEIGHT

	local intervalLabel = EditorLabel.create( {xoffset+padding, yoffset}, "Interval:" )
	yoffset = yoffset + intervalLabel:getHeight()

	local intervalTextbox = EditorTextbox.create( {xoffset+padding, yoffset}, {info.size[1]-padding*2, GUI_BUTTON_HEIGHT} )
	intervalTextbox.text = tostring( self.interval )
	intervalTextbox.onFocus = function( textbox )
		textbox:selectAll()
	end
	intervalTextbox.onFinish = function( textbox )
		local interval = tonumber( textbox.text )
		self.interval = interval
	end
	yoffset = yoffset + GUI_BUTTON_HEIGHT + padding

	local calculateButton = EditorButton.create( {xoffset+padding, yoffset}, {info.size[1]-padding*2, GUI_BUTTON_HEIGHT}, "Calculate" )
	calculateButton.onClick = function( button )
		ComponentWalkableInfo.walkableComponent:calculate()
	end
	--yoffset = yoffset + GUI_BUTTON_HEIGHT
	yoffset = yoffset + padding

	info.items[#info.items+1] = sizeLabel
	info.items[#info.items+1] = sizeTextbox
	info.items[#info.items+1] = intervalLabel
	info.items[#info.items+1] = intervalTextbox
	info.items[#info.items+1] = calculateButton

	-- set size
	info.size[2] = yoffset - position[2]
	ComponentWalkableInfo.entity = self.parent
	ComponentWalkableInfo.walkableComponent = self
	ComponentWalkableInfo.curInfo = info

	-- add to callers list of items
	items[#items+1] = info

	return info.size[2]
end

-- INFO
function ComponentWalkableInfo:load()
	ComponentWalkableInfo.textureIndex = Assets.loadTexture( DEFAULT_TEXTURE )


end

function ComponentWalkableInfo:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCapture = false }

	local result = self.titleButton:update( deltaTime )
	setCapture( result, capture )

	if self.expanded then
		-- update items
		for _,v in pairs(self.items) do
			result = v:update( deltaTime )
			setCapture( result, capture )
		end
	end

	return capture
end

function ComponentWalkableInfo:render()
	self.titleButton:render()

	if self.expanded then
		-- render background
		Graphics.queueQuad( self.textureIndex, self.position, self.size, self.color )

		-- render items
		for _,v in pairs(self.items) do
			v:render()
		end
	end
end

ComponentWalkableInfo:load()

return ComponentWalkable, ComponentWalkableInfo