local BOUNDING_TYPE_RAY = 1
local BOUNDING_TYPE_SPHERE = 2
local BOUNDING_TYPE_AABB = 3

ComponentBoundingBox =
{
	name = "Bounding Box",
	parent = nil,
	type = BOUNDING_TYPE_SPHERE,
	color = { 1,0,1,1 },
	offset = {0,0,0},

	-- ray
	ray =
	{
		length = 1.0,
		direction = normalizeVec({1,1,1}),
	},

	-- sphere
	sphere =
	{
		radius = 2.0,
	},

	-- aabb
	aabb =
	{
		minPosition = {-2,-2,-2},
		maxPosition = {2,2,2},
		minOffset = {-2,-2,-2},
		maxOffset = {2,2,2},
	},
}

ComponentBoundingBoxWindow =
{
	window = {},
	component = {},
}

function ComponentBoundingBox.create( parent )
	local result =
	{
		parent = parent,
		type = BOUNDING_TYPE_SPHERE,
		offset = {0,0,0},

		ray =
		{
			start = {0,0,0},
			length = 5.0,
			direction = normalizeVec({1,1,1}),
		},
		sphere =
		{
			center = {0,0,0},
			radius = 2.0,
		},
		aabb =
		{
			minPosition = {-2,-2,-2},
			maxPosition = {2,2,2},
			minOffset = {-2,-2,-2},
			maxOffset = {2,2,2},
		}
	}

	setmetatable( result, { __index = ComponentBoundingBox} )

	result:parentMoved()

	return result
end

function ComponentBoundingBox:write( file, level )
end

function ComponentBoundingBox:read( file )
end

function ComponentBoundingBox:compile( file, level )
end

function ComponentBoundingBox:copy( parent )
	local result = self.create( parent )

	result.type = self.type
	copyVec( self.color, result.color )
	result.ray.length = self.ray.length
	copyVec( self.ray.direction, result.ray.direction )
	result.sphere.radius = self.sphere.radius
	copyVec( self.aabb.minPosition, result.aabb.minPosition )
	copyVec( self.aabb.maxPosition, result.aabb.maxPosition )

	self:parentMoved()

	return result
end

function ComponentBoundingBox:parentMoved()
	local center = addVec( self.parent.position, self.offset )

	copyVec( center, self.ray.start )
	copyVec( center, self.sphere.center )
	self.aabb.minPosition = addVec( center, self.aabb.minOffset )
	self.aabb.maxPosition = addVec( center, self.aabb.maxOffset )
end

function ComponentBoundingBox:select( ray )
	local result = -1

	local hit = {}
	-- sphere
	if self.type == BOUNDING_TYPE_SPHERE then
		if Physics.raySphere( ray, self.sphere, hit ) then
			result = hit.length
		end
	-- aabb
	elseif self.type == BOUNDING_TYPE_AABB then
		if Physics.rayAABB( ray, self.aabb, hit ) then
			result = hit.length
		end
	end

	return result
end

function ComponentBoundingBox:update( deltaTime )
end

function ComponentBoundingBox:render()
	local result = true

	local color = self.color
	if self.parent.hovered then
		color = {1,1,0,1}
	end

	-- ray
	if self.type == BOUNDING_TYPE_RAY then
		local rayEnd =
		{
			self.ray.direction[1] * self.ray.length,
			self.ray.direction[2] * self.ray.length,
			self.ray.direction[3] * self.ray.length
		}
		rayEnd = addVec( self.ray.start, rayEnd )
		DebugShapes.addLine( self.ray.start, rayEnd, color )

		result = false -- super hard to select a ray, just show the normal sphere
	-- sphere
	elseif self.type == BOUNDING_TYPE_SPHERE then
		DebugShapes.addSphere( self.sphere.center, self.sphere.radius, color )
	-- aabb
	else
		DebugShapes.addAABB( self.aabb.minPosition, self.aabb.maxPosition, color )
	end

	return result
end

function ComponentBoundingBox:showInfoWindow()
	if ComponentBoundingBoxWindow.window.visible then
		ComponentBoundingBoxWindow:hide()
	else
		ComponentBoundingBoxWindow:show( self )
	end
end

function ComponentBoundingBox:changeType( type )
	if self.type ~= type then
		self.type = type
		self:parentMoved()
	end
end

-- WINDOW
function ComponentBoundingBoxWindow:show( component )
	self.component = component
	self.window.visible = true
	self.window.focused = true
	if self.window.onFocus then self.window:onFocus() end

	-- update items
	local count = #self.window.items
	for i=1, count do
		self.window.items[i] = nil
	end

	local typeLabel = EditorLabel.create( nil, "Type:" )
	self.window:addItem( typeLabel )

	local typeDropdown = EditorDropdown.create( {0,0}, {0, GUI_BUTTON_HEIGHT} )
	typeDropdown:addItem( "Ray", BOUNDING_TYPE_RAY )
	typeDropdown:addItem( "Sphere", BOUNDING_TYPE_SPHERE )
	typeDropdown:addItem( "AABB", BOUNDING_TYPE_AABB )
	typeDropdown.selectedIndex = self.component.type
	typeDropdown.onItemSelected = function( dropdown, item )
		self.component:changeType( item.tag )
		self:show( self.component )
	end
	self.window:addItem( typeDropdown )

	-- ray
	if self.component.type == BOUNDING_TYPE_RAY then
		local directionInputbox = EditorInputbox.create( nil, nil, "Direction:" )
		directionInputbox.textbox:setText( stringVec( self.component.ray.direction ) )
		directionInputbox.textbox.onFinish = function( textbox )
			local dir = normalizeVec( vecString( textbox.text ) )
			self.component.ray.direction = dir
			textbox:setText( stringVec( dir ) )
		end
		self.window:addItem( directionInputbox )

		local lengthInputbox = EditorInputbox.create( nil, nil, "Length:" )
		lengthInputbox.textbox:setText( self.component.ray.length )
		lengthInputbox.textbox.onFinish = function( textbox )
			self.component.ray.length = tonumber( textbox.text )
		end
		self.window:addItem( lengthInputbox )
	-- sphere
	elseif self.component.type == BOUNDING_TYPE_SPHERE then
		local radiusInputbox = EditorInputbox.create( nil, nil, "Radius:" )
		radiusInputbox.textbox:setText( self.component.sphere.radius )
		radiusInputbox.textbox.onFinish = function( textbox )
			self.component.sphere.radius = tonumber( textbox.text )
		end
		self.window:addItem( radiusInputbox )
	-- aabb
	else
		local minPositionInputbox = EditorInputbox.create( nil, nil, "Min. position:" )
		minPositionInputbox.textbox:setText( stringVec( self.component.aabb.minOffset ) )
		minPositionInputbox.textbox.onFinish = function( textbox )
			self.component.aabb.minOffset = vecString( textbox.text )
			self.component:parentMoved()
		end
		self.window:addItem( minPositionInputbox )

		local maxPositionInputbox = EditorInputbox.create( nil, nil, "Max. position:" )
		maxPositionInputbox.textbox:setText( stringVec( self.component.aabb.maxOffset ) )
		maxPositionInputbox.textbox.onFinish = function( textbox )
			self.component.aabb.maxOffset = vecString( textbox.text )
			self.component:parentMoved()
		end
		self.window:addItem( maxPositionInputbox )
	end

	
end

function ComponentBoundingBoxWindow:hide()
	self.window.visible = false
end

function ComponentBoundingBoxWindow:refresh( entity )
	if self.window.visible then
		if entity.components[ComponentBoundingBox.name] then
			self:show( entity.components[ComponentBoundingBox.name] )
		else
			self.window.visible = false
		end
	end
end

function ComponentBoundingBoxWindow:load()
	self.window = EditorWindow.create( "Bounding Box Component" )
	self.window.position[1] = WINDOW_WIDTH - GUI_PANEL_WIDTH - self.window.size[1] - 8
	self.window.position[2] = GUI_MENU_HEIGHT + 8
	self.window.visible = false

	-- add items
	local typeLabel = EditorLabel.create( nil, "Type:" )
	self.window:addItem( typeLabel )

	local typeDropdown = EditorDropdown.create( {0,0}, {0, GUI_BUTTON_HEIGHT} )
	typeDropdown:addItem( "Ray", BOUNDING_TYPE_RAY )
	typeDropdown:addItem( "Sphere", BOUNDING_TYPE_SPHERE )
	typeDropdown:addItem( "AABB", BOUNDING_TYPE_AABB )
	typeDropdown.selectedIndex = 2
	typeDropdown.onItemSelected = function( dropdown, item )
		self.component:changeType( item.tag )
		self:show( self.component )
	end
	self.window:addItem( typeDropdown )
end

function ComponentBoundingBoxWindow:update( deltaTime )
	return self.window:update( deltaTime )
end

function ComponentBoundingBoxWindow:render()
	self.window:render()
end

ComponentBoundingBoxWindow:load()

return ComponentBoundingBox, ComponentBoundingBoxWindow