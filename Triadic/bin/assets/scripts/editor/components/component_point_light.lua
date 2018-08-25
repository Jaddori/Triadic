ComponentPointLight =
{
	name = "Point Light",
	parent = nil,
	position = {0,0,0},
	offset = {0,0,0},
	color = {1,1,1},
	intensity = 2,
	linear = 1,
	constant = 0,
	exponent = 1,
	size = 1,
}

ComponentPointLightWindow =
{
	window = {},
	component = {},
}

function ComponentPointLight.create( parent )
	local result =
	{
		parent = parent,
		position = {0,0,0},
		offset = {0,0,0},
		color = {1,1,1},
		intensity = 2,
		linear = 1,
		constant = 0,
		exponent = 1,
		size = 1,
	}

	setmetatable( result, { __index = ComponentPointLight } )

	result:parentMoved()

	return result
end

function ComponentPointLight:write( file, level )
end

function ComponentPointLight:read( file )
end

function ComponentPointLight:compile( file, level )
end

function ComponentPointLight:copy( parent )
	local result = self.create( parent )

	copyVec( self.color, result.color )
	result.intensity = self.intensity
	result.linear = self.linear
	result.constant = self.constant
	result.exponent = self.exponent

	return result
end

function ComponentPointLight:select( ray )
	return -1
end

function ComponentPointLight:update( deltaTime )
end

function ComponentPointLight:render()
	Graphics.queuePointLight( self.position, self.color, self.intensity, self.linear, self.constant, self.exponent )

	if self.parent.selected then
		local center = self.position
		local radius = Graphics.getPointLightSize( self.color, self.intensity, self.linear, self.constant, self.exponent )
		local color = {0,0,0}
		copyVec( self.color, color )
		color[4] = 1
		DebugShapes.addSphere( center, radius, color )
	end

	return false
end

function ComponentPointLight:showInfoWindow()
	if ComponentPointLightWindow.window.visible then
		ComponentPointLightWindow:hide()
	else
		ComponentPointLightWindow:show( self )
	end
end

function ComponentPointLight:parentMoved()
	self.position = addVec( self.parent.position, self.offset )
end

-- WINDOW
function ComponentPointLightWindow:show( component )
	self.component = component
	self.window.visible = true

	-- update items
	self.window.items[1].textbox:setText( stringVec( component.offset ) )
	self.window.items[2].textbox:setText( stringVec( component.color ) )
	self.window.items[3].textbox:setText( component.intensity )
	self.window.items[4].textbox:setText( component.linear )
	self.window.items[5].textbox:setText( component.constant )
	self.window.items[6].textbox:setText( component.exponent )
end

function ComponentPointLightWindow:hide()
	self.window.visible = false
end

function ComponentPointLightWindow:refresh( entity )
	if self.window.visible then
		if entity.components[ComponentPointLight.name] then
			self:show( entity.components[ComponentPointLight.name] )
		else
			self.window.visible = false
		end
	end
end

function ComponentPointLightWindow:load()
	self.window = EditorWindow.create( "Point Light component" )
	self.window.position[1] = WINDOW_WIDTH - GUI_PANEL_WIDTH - self.window.size[1] - 8
	self.window.position[2] = GUI_MENU_HEIGHT + 8
	self.window.visible = false

	-- offset
	local offsetInputbox = EditorInputbox.create( nil, nil, "Offset:" )
	offsetInputbox.textbox.onFinish = function( textbox )
		self.component.offset = vecString( textbox.text )
	end
	self.window:addItem( offsetInputbox )

	-- color
	local colorInputbox = EditorInputbox.create( nil, nil, "Color:" )
	colorInputbox.textbox.onFinish = function( textbox )
		self.component.color = vecString( textbox.text )
	end
	self.window:addItem( colorInputbox )

	-- intensity
	local intensityInputbox = EditorInputbox.create( nil, nil, "Intensity:" )
	intensityInputbox.textbox.onFinish = function( textbox )
		self.component.intensity = tonumber( textbox.text )
	end
	self.window:addItem( intensityInputbox )

	-- linear
	local linearInputbox = EditorInputbox.create( nil, nil, "Linear:" )
	linearInputbox.textbox.onFinish = function( textbox )
		self.component.linear = tonumber( textbox.text )
	end
	self.window:addItem( linearInputbox )

	-- constant
	local constantInputbox = EditorInputbox.create( nil, nil, "Constant:" )
	constantInputbox.textbox.onFinish = function( textbox )
		self.component.constant = tonumber( textbox.text )
	end
	self.window:addItem( constantInputbox )

	-- exponent
	local exponentInputbox = EditorInputbox.create( nil, nil, "Exponent:" )
	exponentInputbox.textbox.onFinish = function( textbox )
		self.component.exponent = tonumber( textbox.text )
	end
	self.window:addItem( exponentInputbox )
end

function ComponentPointLightWindow:update( deltaTime )
	return self.window:update( deltaTime )
end

function ComponentPointLightWindow:render()
	self.window:render()
end

ComponentPointLightWindow:load()

return ComponentPointLight, ComponentPointLightWindow