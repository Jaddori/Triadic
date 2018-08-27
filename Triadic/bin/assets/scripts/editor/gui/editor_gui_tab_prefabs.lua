local padding = 4

local prefabs = 
{
	textureIndex = -1,

	position = {0,0},
	size = {0,0},
	depth = 0,

	items = {},

	listPosition = {0,0},
	listSize = {0,0},
	listColor = {0.35, 0.35, 0.35, 1.0},
	prefabItems = {},

	onSelect = nil,
}

function prefabs:load( position, size, depth )
	self.textureIndex = Assets.loadTexture( GUI_DEFAULT_BACKGROUND_TEXTURE )

	copyVec( position, self.position )
	copyVec( size, self.size )
	self.depth = depth + GUI_DEPTH_INC

	local yoffset = self.position[2] + padding

	-- name
	local nameInputbox = EditorInputbox.create( {self.position[1] + padding, yoffset}, self.size[1]-padding*2, "Name:" )
	nameInputbox:setDepth( self.depth + GUI_DEPTH_SMALL_INC )
	nameInputbox.textbox.readOnly = true
	self.items[#self.items+1] = nameInputbox
	yoffset = yoffset + nameInputbox.size[2] + padding

	-- prefabs
	local componentsLabel = EditorLabel.create( {self.position[1] + padding, yoffset}, "Prefabs:" )
	componentsLabel:setDepth( self.depth + GUI_DEPTH_SMALL_INC )
	self.items[#self.items+1] = componentsLabel
	yoffset = yoffset + componentsLabel.size[2] + padding

	-- list
	self.listPosition = {self.position[1]+padding, yoffset}
	self.listSize = {self.size[1]-padding*2, self.size[2] - yoffset - padding}
end

function prefabs:onClick( button )
	self.items[1].textbox:setText( button.tag.name )

	if self.onSelect then
		self.onSelect( button )
	end
end

function prefabs:addPrefab( prefab )
	local yoffset = #self.prefabItems * (GUI_BUTTON_HEIGHT + padding)

	local button = EditorButton.create( {self.listPosition[1] + padding, self.listPosition[2] + padding + yoffset}, {self.listSize[1] - padding*2, GUI_BUTTON_HEIGHT}, prefab.name )
	button.depth = self.depth + GUI_DEPTH_SMALL_INC
	button.tag = prefab
	button.onClick = function( button )
		self:onClick( button )
	end

	self.prefabItems[#self.prefabItems+1] = button
end

function prefabs:removePrefab( prefab )
	local index = 0
	for i=1, #self.prefabItems do
		if self.prefabItems[i].tag == entity then
			index = i
			break
		end
	end

	if index > 0 then
		self.prefabItems[index] = nil
	end
end

function prefabs:clear()
	local count = #self.prefabItems
	for i=1, count do
		self.prefabItems[i] = nil
	end
end

function prefabs:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	-- update items
	for _,v in pairs(self.items) do
		local result = v:update( deltaTime )
		setCapture( result, capture )
	end

	-- update prefab items
	for _,v in pairs(self.prefabItems) do
		local result = v:update( deltaTime )
		setCapture( result, capture )
	end

	return capture
end

function prefabs:render()
	-- render items
	for _,v in pairs(self.items) do
		v:render()
	end

	-- render prefab list background
	Graphics.queueQuad( self.textureIndex, self.listPosition, self.listSize, self.depth, self.listColor )

	-- render prefab items
	for _,v in pairs(self.prefabItems) do
		v:render()
	end
end

return prefabs