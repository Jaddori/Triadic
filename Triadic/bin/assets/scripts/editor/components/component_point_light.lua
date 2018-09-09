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
		size = 1,
	}

	setmetatable( result, { __index = ComponentPointLight } )

	if result.parent then
		result:parentMoved()
	end

	return result
end

function ComponentPointLight:write( file, level, prefabName )
	local location = ""

	if self.parent then -- entity
		location = self.parent.name .. "_component"
		writeIndent( file, level, "local " .. location .. " = ComponentPointLight.create( " .. self.parent.name .. " )\n" )
	else -- prefab
		location = "Prefabs[\"" .. prefabName .. "\"].components[\"" .. self.name .. "\"]"
		writeIndent( file, level, location .. " = ComponentPointLight.create()\n" )
	end

	writeIndent( file, level, location .. ".position = {" .. stringVec( self.position ) .. "}\n" )
	writeIndent( file, level, location .. ".offset = {" .. stringVec( self.offset ) .. "}\n" )
	writeIndent( file, level, location .. ".color = {" .. stringVec( self.color ) .. "}\n" )
	writeIndent( file, level, location .. ".intensity = " .. tostring( self.intensity ) .. "\n" )

	if self.linear ~= ComponentPointLight.linear then
		writeIndent( file, level, location .. ".linear = " .. tostring( self.linear ) .. "\n" )
	end

	if self.constant ~= ComponentPointLight.constant then
		writeIndent( file, level, location .. ".constant = " .. tostring( self.constant ) .. "\n" )
	end

	if self.exponent ~= ComponentPointLight.exponent then
		writeIndent( file, level, location .. ".exponent = " .. tostring( self.exponent ) .. "\n" )
	end

	writeIndent( file, level, location .. ".size = " .. tostring( self.size ) .. "\n" )

	if self.parent then
		writeIndent( file, level, self.parent.name .. ":addComponent( " .. location .. " )\n" )
	end
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
	self.window.focused = true
	if self.window.onFocus then self.window:onFocus() end

	-- update items
	self.offsetInputbox.textbox:setText( stringVec( component.offset ) )
	self.colorInputbox.textbox:setText( stringVec( component.color ) )
	self.intensityInputbox.textbox:setText( component.intensity )
	self.linearInputbox.textbox:setText( component.intensity )
	self.constantInputbox.textbox:setText( component.intensity )
	self.exponentInputbox.textbox:setText( component.intensity )
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
	-- window
	self.window = EditorWindow.create( "Point Light component" )
	self.window.position[1] = WINDOW_WIDTH - GUI_PANEL_WIDTH - self.window.size[1] - 8
	self.window.position[2] = GUI_MENU_HEIGHT + 8
	self.window.visible = false

	-- layout
	local layout = EditorLayoutTopdown.create( {0,0}, self.window.size[1] )

	-- offset
	--local offsetInputbox = EditorInputbox.create( nil, nil, "Offset:" )
	local offsetInputbox = EditorInputbox.createWithText( "Offset:" )
	offsetInputbox.textbox.onFinish = function( textbox )
		self.component.offset = vecString( textbox.text )
	end
	--self.window:addItem( offsetInputbox )
	layout:addItem( offsetInputbox )

	-- color
	--local colorInputbox = EditorInputbox.create( nil, nil, "Color:" )
	local colorInputbox = EditorInputbox.createWithText( "Color:" )
	colorInputbox.textbox.onFinish = function( textbox )
		self.component.color = vecString( textbox.text )
	end
	--self.window:addItem( colorInputbox )
	layout:addItem( colorInputbox )

	-- intensity
	--local intensityInputbox = EditorInputbox.create( nil, nil, "Intensity:" )
	local intensityInputbox = EditorInputbox.createWithText( "Intensity:" )
	intensityInputbox.textbox.onFinish = function( textbox )
		self.component.intensity = tonumber( textbox.text )
	end
	--self.window:addItem( intensityInputbox )
	layout:addItem( intensityInputbox )

	-- linear
	--local linearInputbox = EditorInputbox.create( nil, nil, "Linear:" )
	local linearInputbox = EditorInputbox.createWithText( "Linear:" )
	linearInputbox.textbox.onFinish = function( textbox )
		self.component.linear = tonumber( textbox.text )
	end
	--self.window:addItem( linearInputbox )
	layout:addItem( linearInputbox )

	-- constant
	--local constantInputbox = EditorInputbox.create( nil, nil, "Constant:" )
	local constantInputbox = EditorInputbox.createWithText( "Constant:" )
	constantInputbox.textbox.onFinish = function( textbox )
		self.component.constant = tonumber( textbox.text )
	end
	--self.window:addItem( constantInputbox )
	layout:addItem( constantInputbox )

	-- exponent
	--local exponentInputbox = EditorInputbox.create( nil, nil, "Exponent:" )
	local exponentInputbox = EditorInputbox.createWithText( "Exponent:" )
	exponentInputbox.textbox.onFinish = function( textbox )
		self.component.exponent = tonumber( textbox.text )
	end
	--self.window:addItem( exponentInputbox )
	layout:addItem( exponentInputbox )

	self.window:addItem( layout )

	-- set table references for easy access
	self.offsetInputbox = offsetInputbox
	self.colorInputbox = colorInputbox
	self.intensityInputbox = intensityInputbox
	self.linearInputbox = linearInputbox
	self.constantInputbox = constantInputbox
	self.exponentInputbox = exponentInputbox
end

function ComponentPointLightWindow:update( deltaTime, mousePosition )
	self.window:update( deltaTime, mousePosition )
end

function ComponentPointLightWindow:render()
	self.window:render()
end

ComponentPointLightWindow:load()

return ComponentPointLight, ComponentPointLightWindow