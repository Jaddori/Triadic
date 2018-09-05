local GUI_DEFAULT_CROSS_TEXTURE = "./assets/textures/cross.dds"
local PREFAB_BUTTON_CREATE = 1
local PREFAB_BUTTON_UPDATE = 2

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
	prefabInputbox = {},
	prefabDetachButton = {},
	positionInputbox = {},
	orientationInputbox = {},
	scaleInputbox = {},
	visibleLabel = {},
	visibleCheckbox = {},
	createPrefabButton = {},
	revertPrefabButton = {},
	componentsLabel = {},
	addComponentButton = {},

	prefabNameWindow = {},

	onCreatePrefab = nil,
	onUpdatePrefab = nil,
	onRevertToPrefab = nil,
	onAddComponent = nil,
	onDetachPrefab = nil,
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

	-- prefab name
	local detachBounds = GUI_BUTTON_HEIGHT
	self.prefabInputbox = EditorInputbox.create( {position[1] + padding, position[2] + padding + yoffset}, size[1]-padding*3-detachBounds, "Prefab:" )
	self.prefabInputbox.textbox.readOnly = true
	self.prefabInputbox:setDepth( self.depth )
	self.items[#self.items+1] = self.prefabInputbox
	yoffset = yoffset + self.prefabInputbox.size[2] + padding
	
	-- prefab detach button
	local prefabPosition = self.prefabInputbox.textbox.position
	local prefabSize = self.prefabInputbox.textbox.size
	local detachSize = 16
	self.prefabDetachButton = EditorButton.create( {prefabPosition[1] + prefabSize[1] + padding, prefabPosition[2] + (detachBounds-detachSize)*0.5}, {detachSize, detachSize}, "" )
	self.prefabDetachButton.disabled = true
	self.prefabDetachButton.textureIndex = Assets.loadTexture( GUI_DEFAULT_CROSS_TEXTURE )
	self.prefabDetachButton.color = {1,1,1,1}
	self.prefabDetachButton.hoverColor = {1.0, 0.35, 0.35, 1.0}
	self.prefabDetachButton:setDepth( self.depth )
	self.prefabDetachButton.onClick = function( button )
		if self.onDetachPrefab then
			self.onDetachPrefab()
		end
	end
	self.items[#self.items+1] = self.prefabDetachButton

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
	self.visibleLabel = EditorLabel.create( {position[1] + padding, position[2] + padding + yoffset}, {size[1]-padding*2, GUI_BUTTON_HEIGHT}, "Visible:" )
	self.visibleLabel:setDepth( self.depth )
	self.items[#self.items+1] = self.visibleLabel
	yoffset = yoffset + self.visibleLabel.size[2] + padding

	self.visibleCheckbox = EditorCheckbox.create( {position[1] + padding, position[2] + padding + yoffset} )
	self.visibleCheckbox:setDepth( self.depth )
	self.items[#self.items+1] = self.visibleCheckbox
	yoffset = yoffset + self.visibleCheckbox.size[2] + padding

	-- create prefab
	self.createPrefabButton = EditorButton.create( {position[1] + padding, position[2] + padding + yoffset}, {size[1]-padding*2, GUI_BUTTON_HEIGHT}, "Create Prefab" )
	self.createPrefabButton.disabled = true
	self.createPrefabButton.mode = PREFAB_BUTTON_CREATE
	self.createPrefabButton:setDepth( self.depth )
	self.createPrefabButton.onClick = function( button )
		-- create
		if button.mode == PREFAB_BUTTON_CREATE then
			if self.onCreatePrefab then
				self.onCreatePrefab()
			end
		-- update
		elseif button.mode == PREFAB_BUTTON_UPDATE then
			if self.onUpdatePrefab then
				self.onUpdatePrefab()
			end
		end
	end
	self.items[#self.items+1] = self.createPrefabButton
	yoffset = yoffset + self.createPrefabButton.size[2] + padding

	-- revert to prefab
	self.revertPrefabButton = EditorButton.create( {position[1] + padding, position[2] + padding + yoffset}, {size[1]-padding*2, GUI_BUTTON_HEIGHT}, "Revert to Prefab" )
	self.revertPrefabButton.disabled = true
	self.revertPrefabButton:setDepth( self.depth )
	self.revertPrefabButton.onClick = function( button )
		if self.onRevertToPrefab then
			self.onRevertToPrefab()
		end
	end
	self.items[#self.items+1] = self.revertPrefabButton
	yoffset = yoffset + self.revertPrefabButton.size[2] + padding

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
		self.prefabNameWindow:close()

		if self.prefabNameWindow.onConfirm then
			self.prefabNameWindow.onConfirm( self.prefabNameWindow.items[1].textbox.text )
		end
	end
	self.prefabNameWindow:addItem( prefabNameCreateButton )

	-- components
	self.componentsLabel = EditorLabel.create( {position[1] + padding, position[2] + padding + yoffset}, {size[1]-padding*2, GUI_BUTTON_HEIGHT}, "Components:" )
	self.componentsLabel:setDepth( self.depth )
	self.items[#self.items+1] = self.componentsLabel
	yoffset = yoffset + self.componentsLabel.size[2] + padding

	-- add component
	self.addComponentButton = EditorButton.create( {position[1] + padding, position[2] + padding + yoffset}, {size[1]-padding*2, GUI_BUTTON_HEIGHT}, "Add Component" )
	self.addComponentButton.disabled = true
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
		self.nameInputbox.textbox:setText( entity.name )
		if entity.prefab then
			self.prefabInputbox.textbox:setText( entity.prefab.name )
			self.prefabDetachButton.disabled = false
			self.revertPrefabButton.disabled = false

			self.createPrefabButton:setText( "Update Prefab" )
			self.createPrefabButton.mode = PREFAB_BUTTON_UPDATE
		else
			self.prefabInputbox.textbox:setText( "" )
			self.prefabDetachButton.disabled = true
			self.revertPrefabButton.disabled = true

			self.createPrefabButton:setText( "Create Prefab" )
			self.createPrefabButton.mode = PREFAB_BUTTON_CREATE
		end
		self.positionInputbox.textbox:setText( stringVec( entity.position ) )
		self.orientationInputbox.textbox:setText( stringVec( entity.orientation ) )
		self.scaleInputbox.textbox:setText( stringVec( entity.scale ) )
		self.visibleCheckbox.checked = entity.visible

		-- create new items
		self.entity = entity
		
		local padding = 4
		local yoffset = self.addComponentButton.position[2] + self.addComponentButton.size[2] + 8
		local removeSize = 16
		for _,v in pairs(self.entity.components) do
			local button = EditorButton.create( {self.position[1]+padding, yoffset}, {self.size[1]-removeSize-padding*4, GUI_BUTTON_HEIGHT}, v.name )
			button:setDepth( self.depth )
			button:setTextAlignment( ALIGN_NEAR, ALIGN_NEAR )
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
		self.createPrefabButton.disabled = false
	else
		self.nameInputbox.textbox:setText( "" )
		self.prefabInputbox.textbox:setText( "" )
		self.prefabDetachButton.disabled = true
		self.positionInputbox.textbox:setText( "" )
		self.orientationInputbox.textbox:setText( "" )
		self.scaleInputbox.textbox:setText( "" )
		self.addComponentButton.disabled = true
		self.visibleCheckbox.checked = false

		self.createPrefabButton.disabled = true
		self.createPrefabButton:setText( "Create Prefab" )
		self.createPrefabButton.mode = PREFAB_BUTTON_CREATE
		self.revertPrefabButton.disabled = true
	end
end

function info:refresh()
	self.positionInputbox.textbox:setText( stringVec( self.entity.position ) )
	self.orientationInputbox.textbox:setText( stringVec( self.entity.orientation ) )
	self.scaleInputbox.textbox:setText( stringVec( self.entity.scale ) )
end

function info:checkCapture( capture, mousePosition )
	-- check items
	for _,v in pairs(self.items) do
		v:checkCapture( capture, mousePosition )
	end

	-- check sub items
	for _,v in pairs(self.subItems) do
		v:checkCapture( capture, mousePosition )
	end

	-- check prefab name window
	self.prefabNameWindow:checkCapture( capture, mousePosition )

	if capture.depth < self.depth then
		if insideRect( self.position, self.size, mousePosition ) then
			capture.depth = self.depth
			capture.item = self
		end
	end
end

function info:update( deltaTime, mousePosition )
	-- update items
	for _,v in pairs(self.items) do
		v:update( deltaTime, mousePosition )
	end

	-- update sub items
	for _,v in pairs(self.subItems) do
		v:update( deltaTime, mousePosition )
	end

	-- update prefab name window
	self.prefabNameWindow:update( deltaTime, mousePosition )

	--[[
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
	
	return capture--]]
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