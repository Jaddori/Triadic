local GUI_DEFAULT_CROSS_TEXTURE = "./assets/textures/cross.dds"

local info =
{
	items = {},
	subItems = {},
	entity = nil,
	depth = 0,
	crossTextureIndex = -1,

	position = {0,0},
	size = {0,0},

	nameInputbox = {},
	positionInputbox = {},
	orientationInputbox = {},
	scaleInputbox = {},
	visibleLabel = {},
	visibleCheckbox = {},
	createPrefabButton = {},
	componentsLabel = {},
	addComponentButton = {},

	prefabNameWindow = {},

	onAddComponent = nil,
}

function info:load( position, size, depth )
	copyVec( position, self.position )
	copyVec( size, self.size )

	local padding = 4
	local yoffset = 0

	self.depth = depth + GUI_DEPTH_INC

	self.crossTextureIndex = Assets.loadTexture( GUI_DEFAULT_CROSS_TEXTURE )

	-- name
	self.nameInputbox = EditorInputbox.create( {position[1] + padding, position[2] + padding + yoffset}, size[1]-padding*2, "Name:" )
	self.nameInputbox:setDepth( self.depth )
	self.items[#self.items+1] = self.nameInputbox
	yoffset = yoffset + self.nameInputbox.size[2] + padding

	-- position
	self.positionInputbox = EditorInputbox.create( {position[1] + padding, position[2] + padding + yoffset}, size[1]-padding*2, "Position:" )
	self.positionInputbox:setDepth( self.depth )
	self.items[#self.items+1] = self.positionInputbox
	yoffset = yoffset + self.positionInputbox.size[2] + padding

	-- orientation
	self.orientationInputbox = EditorInputbox.create( {position[1] + padding, position[2] + padding + yoffset}, size[1]-padding*2, "Orientation:" )
	self.orientationInputbox:setDepth( self.depth )
	self.items[#self.items+1] = self.orientationInputbox
	yoffset = yoffset + self.orientationInputbox.size[2] + padding

	-- scale
	self.scaleInputbox = EditorInputbox.create( {position[1] + padding, position[2] + padding + yoffset}, size[1]-padding*2, "Scale:" )
	self.scaleInputbox:setDepth( self.depth )
	self.items[#self.items+1] = self.scaleInputbox
	yoffset = yoffset + self.scaleInputbox.size[2] + padding

	-- visible
	self.visibleLabel = EditorLabel.create( {position[1] + padding, position[2] + padding + yoffset}, "Visible:" )
	self.visibleLabel:setDepth( self.depth )
	self.items[#self.items+1] = self.visibleLabel
	yoffset = yoffset + self.visibleLabel:getHeight() + padding

	self.visibleCheckbox = EditorCheckbox.create( {position[1] + padding, position[2] + padding + yoffset} )
	self.visibleCheckbox:setDepth( self.depth )
	self.items[#self.items+1] = self.visibleCheckbox
	yoffset = yoffset + self.visibleCheckbox.size[2] + padding

	-- create prefab
	self.createPrefabButton = EditorButton.create( {position[1] + padding, position[2] + padding + yoffset}, {size[1]-padding*2, GUI_BUTTON_HEIGHT}, "Create Prefab" )
	self.createPrefabButton:setDepth( self.depth )
	self.items[#self.items+1] = self.createPrefabButton
	yoffset = yoffset + self.createPrefabButton.size[2] + padding

	-- prefab name window
	self.prefabNameWindow = EditorWindow.create( "Create Prefab" )
	self.prefabNameWindow.visible = false

	local prefabNameInputbox = EditorInputbox.create( nil, nil, "Name:" )
	prefabNameInputbox.textbox.onTextChanged = function( textbox )
		local len = textbox.text:len()
		self.prefabNameWindow.items[2].disabled = not (len > 0)
	end
	self.prefabNameWindow:addItem( prefabNameInputbox )

	local prefabNameCreateButton = EditorButton.create( nil, {0, GUI_BUTTON_HEIGHT}, "Create" )
	prefabNameCreateButton.onClick = function( button )
		self.prefabNameWindow.visible = false

		if self.prefabNameWindow.onCreate then
			self.prefabNameWindow.onCreate( self.prefabNameWindow.items[1].textbox.text )
		end
	end
	self.prefabNameWindow:addItem( prefabNameCreateButton )

	-- components
	self.componentsLabel = EditorLabel.create( {position[1] + padding, position[2] + padding + yoffset}, "Components:" )
	self.componentsLabel:setDepth( self.depth )
	self.items[#self.items+1] = self.componentsLabel
	yoffset = yoffset + self.componentsLabel:getHeight() + padding

	-- add component
	self.addComponentButton = EditorButton.create( {position[1] + padding, position[2] + padding + yoffset}, {size[1]-padding*2, GUI_BUTTON_HEIGHT}, "Add Component" )
	self.addComponentButton:setDepth( self.depth )
	self.addComponentButton.onClick = function( button )
		if self.onAddComponent then
			self.onAddComponent()
		end
	end
	self.items[#self.items+1] = self.addComponentButton
	yoffset = yoffset + GUI_BUTTON_HEIGHT + padding
end

function info:showPrefabNameWindow()
	local s = self.prefabNameWindow.size

	local view = { WINDOW_WIDTH - GUI_PANEL_WIDTH, WINDOW_HEIGHT - GUI_MENU_HEIGHT }

	local x = view[1]*0.5 - s[1]*0.5
	local y = view[2]*0.5 - s[2]*0.5

	self.prefabNameWindow.items[1].textbox:setText("")
	self.prefabNameWindow.items[2].disabled = true

	self.prefabNameWindow:setPosition( {x,y} )
	self.prefabNameWindow.visible = true
end

function info:setEntity( entity )
	-- clear items
	count = #self.subItems
	for i=0, count do self.subItems[i]=nil end
	
	if entity then
		-- set name and position
		self.visibleCheckbox.checked = entity.visible
		self.nameInputbox.textbox:setText( entity.name )
		self.positionInputbox.textbox:setText( stringVec( entity.position ) )
		self.orientationInputbox.textbox:setText( stringVec( entity.orientation ) )
		self.scaleInputbox.textbox:setText( stringVec( entity.scale ) )

		-- create new items
		self.entity = entity
		
		local padding = 4
		local yoffset = self.addComponentButton.position[2] + self.addComponentButton.size[2] + 8
		local removeSize = 16
		for _,v in pairs(self.entity.components) do
			local button = EditorButton.create( {self.position[1]+padding, yoffset}, {self.size[1]-removeSize-padding*4, GUI_BUTTON_HEIGHT}, v.name )
			button:setDepth( self.depth )
			button.onClick = function( button )
				v:showInfoWindow()
			end

			local removePadding = ( button.size[2] - removeSize ) * 0.5
			local removeButton = EditorButton.create( {button.position[1]+button.size[1]+padding, yoffset+removePadding}, {removeSize,removeSize}, "" )
			removeButton:setDepth( self.depth )
			removeButton.textureIndex = self.crossTextureIndex
			removeButton.color = {1,1,1,1}
			removeButton.hoverColor = {1.0, 0.35, 0.35, 1.0}
			removeButton.onClick = function( button )
				self.entity.components[v.name] = nil
				self:setEntity( self.entity )
			end

			self.subItems[#self.subItems+1] = button
			self.subItems[#self.subItems+1] = removeButton

			yoffset = yoffset + GUI_BUTTON_HEIGHT + padding
		end

		self.addComponentButton.disabled = false
	else
		self.visibleCheckbox.checked = false
		self.nameInputbox.textbox:setText( "" )
		self.positionInputbox.textbox:setText( "" )
		self.orientationInputbox.textbox:setText( "" )
		self.scaleInputbox.textbox:setText( "" )
		self.addComponentButton.disabled = true
	end
end

function info:refresh()
	self.positionInputbox.textbox:setText( stringVec( self.entity.position ) )
	self.orientationInputbox.textbox:setText( stringVec( self.entity.orientation ) )
	self.scaleInputbox.textbox:setText( stringVec( self.entity.scale ) )
end

function info:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	-- update items
	for _,v in pairs(self.items) do
		local result = v:update( deltaTime )
		setCapture( result, capture )
	end

	-- update sub items
	for _,v in pairs(self.subItems) do
		local result = v:update( deltaTime )
		setCapture( result, capture )
	end

	-- update prefab name window
	local result = self.prefabNameWindow:update( deltaTime )
	setCapture( result, capture )
	
	return capture
end

function info:render()
	-- render items
	for _,v in pairs(self.items) do
		v:render()
	end

	-- render sub items
	for _,v in pairs(self.subItems) do
		v:render()
	end

	-- render prefab name window
	self.prefabNameWindow:render()
end

return info