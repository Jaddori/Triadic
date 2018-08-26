local DEFAULT_TEXTURE = "./assets/textures/white.dds"

ComponentWalkable =
{
	name = "Walkable",
	size = {20,20},
	interval = 1,
	parent = nil,
	nodes = {},
}

ComponentWalkableWindow =
{
	window = {},
	component = {},
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
	local componentName = self.parent.name .. "_component"
	writeIndent( file, level, "local " .. componentName .. " = ComponentWalkable.create( " .. self.parent.name .. " )\n" )

	writeIndent( file, level, componentName .. ".size = {" .. stringVec( self.size ) .. "}\n" )
	writeIndent( file, level, componentName .. ".interval = " .. tostring( self.interval ) .. "\n" )

	writeIndent( file, level, self.parent.name .. ":addComponent( " .. componentName .. " )\n" )
end

function ComponentWalkable:read( file )
end

function ComponentWalkable:compile( file, level )
end

function ComponentWalkable:copy( parent )
	local result = self.create( parent )

	copyVec( self.size, result.size )
	result.interval = self.interval

	return result
end

function ComponentWalkable:select( ray )
	local result = -1

	local minPosition = {self.parent.position[1], -0.5, self.parent.position[3]}
	local maxPosition = {self.parent.position[1]+self.size[1], 0.5, self.parent.position[3]+self.size[2]}
	local boundingBox = Physics.createAABB( minPosition, maxPosition )

	local hit = {}
	if Physics.rayAABB( ray, boundingBox, hit ) then
		result = hit.length
	end

	return result
end

function ComponentWalkable:update( deltaTime )
end

function ComponentWalkable:render()
	-- render bounds
	local color = {0,1,0,1}
	if self.parent.hovered then
		color[1] = 1
	end
	local minPosition = {self.parent.position[1], -0.5, self.parent.position[3]}
	local maxPosition = {self.parent.position[1]+self.size[1], 0.5, self.parent.position[3]+self.size[2]}

	DebugShapes.addAABB( minPosition, maxPosition, color )

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

function ComponentWalkable:showInfoWindow()
	if ComponentWalkableWindow.window.visible then
		ComponentWalkableWindow:hide()
	else
		ComponentWalkableWindow:show( self )
	end
end

-- WINDOW
function ComponentWalkableWindow:show( component )
	self.component = component
	self.window.visible = true

	-- update items
	self.window.items[1].textbox:setText( stringVec( component.size ) )
	self.window.items[2].textbox:setText( component.interval )
end

function ComponentWalkableWindow:hide()
	self.window.visible = false
end

function ComponentWalkableWindow:refresh( entity )
	if self.window.visible then
		if entity.components[ComponentWalkable.name] then
			self:show( entity.components[ComponentWalkable.name] )
		else
			self.window.visible = false
		end
	end
end

function ComponentWalkableWindow:load()
	self.window = EditorWindow.create( "Walkable Component" )
	self.window.position[1] = WINDOW_WIDTH - GUI_PANEL_WIDTH - self.window.size[1] - 8
	self.window.position[2] = GUI_MENU_HEIGHT + 8
	self.window.visible = false
	self.window.focused = true
	if self.window.onFocus then self.window:onFocus() end

	-- size
	local sizeInput = EditorInputbox.create( {0,0}, 0, "Size:" )
	sizeInput.textbox.onFinish = function( textbox )
		self.component.size = vecString( textbox.text )
	end
	self.window:addItem( sizeInput )
	
	-- interval
	local intervalInput = EditorInputbox.create( {0,0}, 0, "Interval:" )
	intervalInput.textbox.onFinish = function( textbox )
		self.component.interval = tonumber( textbox.text )
	end
	self.window:addItem( intervalInput )

	-- calculate
	local calculateButton = EditorButton.create( {0,0}, {0,GUI_BUTTON_HEIGHT}, "Calculate" )
	calculateButton.onClick = function( button )
		self.component:calculate()
	end
	self.window:addItem( calculateButton )
end

function ComponentWalkableWindow:update( deltaTime )
	return self.window:update( deltaTime )
end

function ComponentWalkableWindow:render()
	self.window:render()
end

ComponentWalkableWindow:load()

return ComponentWalkable, ComponentWalkableWindow