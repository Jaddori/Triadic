local DEFAULT_TEXTURE = "./assets/textures/white.dds"
local MESH_LIST_PANEL_WIDTH = 128

ComponentMesh =
{
	name = "Mesh",
	transform = nil,
	meshIndex = -1,
	parent = nil,
	boundingBox = nil,
}

ComponentMeshInfo =
{
	name = "Mesh",
	position = {0,0},
	size = {0,0},
	expanded = true,
	textureIndex = -1,
	color = { 0.35, 0.35, 0.35, 1.0 },
	titleButton = nil,
	entity = nil,
	meshComponent = nil,
	curInfo = nil,
	items = {},
	
	meshNames = {},
	meshIndices = {},
	meshBoundingBoxes = {},
	meshList =
	{
		visible = false,
		position = {0,0},
		size = {0,0},
		items = {},
	}
}

function ComponentMesh.create( parent )
	local result =
	{
		parent = parent,
		transform = Transform.create(),
		meshIndex = -1,
		boundingBox = nil,
	}

	if #ComponentMeshInfo.meshIndices > 0 then
		result.meshIndex = ComponentMeshInfo.meshIndices[1]
		result.boundingBox = ComponentMeshInfo.meshBoundingBoxes[1]
	end
	
	result.transform:setPosition( parent.position )
	
	setmetatable( result, { __index = ComponentMesh } )
	
	return result
end

function ComponentMesh:write( file, level )
	writeIndent( file, level, "Mesh =\n" )
	writeIndent( file, level, "{\n" )
	level = level + 1

	writeIndent( file, level, "parent = " .. self.parent.name .. ",\n" )
	writeIndent( file, level, "transform = Transform.create(),\n" )
	writeIndent( file, level, "meshIndex = " .. tostring( self.meshIndex ) .. ",\n" )

	level = level - 1
	writeIndent( file, level, "},\n" )
end

function ComponentMesh:read( file )
end

function ComponentMesh:copy( parent )
	local result = self.create( parent )
	
	result.meshIndex = self.meshIndex
	result.boundingBox = self.boundingBox
	
	return result
end

function ComponentMesh:loadMesh( path )
	self.meshIndex = Assets.loadMesh( path )
	if self.meshIndex then
		local mesh = Assets.getMesh( self.meshIndex )
		self.boundingBox = mesh:getBoundingBox()
	else
		self.boundingBox = nil
	end
end

function ComponentMesh:parentMoved()
	self.transform:setPosition( self.parent.position )
end

function ComponentMesh:parentOriented()
	self.transform:setOrientation( self.parent.orientation )
end

function ComponentMesh:parentScaled()
	self.transform:setScale( self.parent.scale )
end

function ComponentMesh:select( ray )
	local result = false

	if self.boundingBox then
		local worldBox =
		{
			minPosition = self.boundingBox.minPosition:mul( self.parent.scale ),
			maxPosition = self.boundingBox.maxPosition:mul( self.parent.scale )
		}

		worldBox.minPosition = worldBox.minPosition:add( self.parent.position )
		worldBox.maxPosition = worldBox.maxPosition:add( self.parent.position )
		
		result = Physics.rayAABB( ray, worldBox )
	end
	
	return result
end

function ComponentMesh:update( deltaTime )
end

function ComponentMesh:render()
	if self.meshIndex >= 0 then
		Graphics.queueMesh( self.meshIndex, self.transform )
		
		if self.boundingBox and self.parent.selected then
			local worldBox =
			{
				minPosition = self.boundingBox.minPosition:mul( self.parent.scale ),
				maxPosition = self.boundingBox.maxPosition:mul( self.parent.scale )
			}

			worldBox.minPosition = worldBox.minPosition:add( self.parent.position )
			worldBox.maxPosition = worldBox.maxPosition:add( self.parent.position )

			DebugShapes.addAABB( worldBox.minPosition, worldBox.maxPosition, {0.0, 1.0, 0.0, 1.0}, false )
		end
	end
	
	return true
end

function ComponentMesh:addInfo( position, size, items )
	local info =
	{
		name = "Mesh",
		position = {0,0},
		size = {0,0},
		items = {},
	}
	setmetatable( info, { __index = ComponentMeshInfo } )
		
	local padding = 4
	local inset = 8
	local xoffset = position[1] + padding
	local yoffset = position[2]
	
	-- add title button
	info.titleButton = EditorButton.create( {xoffset, yoffset}, {size[1]-padding*2, 24}, "Mesh:" )
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
	local meshNameLabel = EditorLabel.create( {xoffset+padding, yoffset}, "Mesh name:" )
	yoffset = yoffset + meshNameLabel:getHeight()
	
	local meshName = "N/A"
	if self.meshIndex >= 0 then
		for i=1, #info.meshIndices do
			if info.meshIndices[i] == self.meshIndex then
				meshName = info.meshNames[i]
				break
			end
		end
	end
	
	local meshNameButton = EditorButton.create( {xoffset+padding, yoffset}, {info.size[1]-padding*2, GUI_BUTTON_HEIGHT}, meshName )
	meshNameButton.onClick = function( self )
		ComponentMeshInfo.meshList.visible = true
	end
	--yoffset = yoffset + GUI_BUTTON_HEIGHT
	yoffset = yoffset + padding
	
	info.items[#info.items+1] = meshNameLabel
	info.items[#info.items+1] = meshNameButton
	
	-- set size	
	info.size[2] = yoffset - position[2]
	ComponentMeshInfo.entity = self.parent
	ComponentMeshInfo.meshComponent = self
	ComponentMeshInfo.curInfo = info
	
	-- add to callers list of items
	items[#items+1] = info
	
	return info.size[2]
end

-- INFO
function ComponentMeshInfo:meshSelected( index )
	self.meshComponent.meshIndex = self.meshIndices[index]
	self.meshComponent.boundingBox = self.meshBoundingBoxes[index]
	
	self.curInfo.items[2].text = self.meshNames[index]
end

function ComponentMeshInfo:load()
	ComponentMeshInfo.textureIndex = Assets.loadTexture( DEFAULT_TEXTURE )

	-- create mesh-selection-panel
	self.meshList.position = { WINDOW_WIDTH - GUI_PANEL_WIDTH - MESH_LIST_PANEL_WIDTH, GUI_MENU_HEIGHT }
	self.meshList.size = { MESH_LIST_PANEL_WIDTH, WINDOW_HEIGHT - GUI_MENU_HEIGHT }
	
	-- load meshes
	self.meshNames = Filesystem.getFiles( "./assets/models/*" )
	for i=1, #self.meshNames do
		self.meshIndices[i] = Assets.loadMesh( "./assets/models/" .. self.meshNames[i] )
		self.meshBoundingBoxes[i] = Assets.getMesh( self.meshIndices[i] ):getBoundingBox()
		
		-- create button for mesh index
		local padding = 4
		local position = { self.meshList.position[1]+padding, i*(GUI_BUTTON_HEIGHT + padding) }
		local size = { MESH_LIST_PANEL_WIDTH - padding*2, GUI_BUTTON_HEIGHT }
		local button = EditorButton.create( position, size, self.meshNames[i] )
		button.onClick = function( self )
			ComponentMeshInfo.meshList.visible = false
			ComponentMeshInfo:meshSelected( i )
		end
		
		self.meshList.items[i] = button
	end
end

function ComponentMeshInfo:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	local result = self.titleButton:update( deltaTime )
	setCapture( result, capture )

	if self.expanded then
		-- update mesh list
		if self.meshList.visible then
			for _,v in pairs(self.meshList.items) do
				result = v:update( deltaTime )
				setCapture( result, capture )
			end
			
			if Input.buttonReleased( Buttons.Left ) then
				local mousePosition = Input.getMousePosition()
				if insideRect( self.meshList.position, self.meshList.size, mousePosition ) then
					capture.mouseCaptured = true
				else
					self.meshList.visible = false
				end
			end
		end
		
		-- update items
		for _,v in pairs(self.items) do
			result = v:update( deltaTime )
			setCapture( result, capture )
		end
	end
	
	return capture
end

function ComponentMeshInfo:render()
	self.titleButton:render()
	
	if self.expanded then
		-- render background
		Graphics.queueQuad( self.textureIndex, self.position, self.size, self.color )

		-- render items
		for _,v in pairs(self.items) do
			v:render()
		end
		
		-- render mesh list
		if self.meshList.visible then
			Graphics.queueQuad( self.textureIndex, self.meshList.position, self.meshList.size, self.color )
		
			for _,v in pairs(self.meshList.items) do
				v:render()
			end
		end
	end
end

ComponentMeshInfo:load()

return ComponentMesh, ComponentMeshInfo