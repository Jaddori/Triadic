local DEFAULT_TEXTURE = "./assets/textures/white.dds"

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
	items = {},
}

function ComponentMesh.create( parent, position )
	local result =
	{
		parent = parent,
		transform = Transform.create(),
		meshIndex = -1,
		boundingBox = nil,
	}
	
	if position then result.transform:setPosition( position ) end
	
	setmetatable( result, { __index = ComponentMesh } )
	
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

function ComponentMesh:select( ray )
	local result = false

	if self.boundingBox then
		local worldBox =
		{
			minPosition = self.boundingBox.minPosition:add( self.parent.position ),
			maxPosition = self.boundingBox.maxPosition:add( self.parent.position )
		}
		
		result = Physics.rayAABB( ray, worldBox )
	end
	
	return result
end

function ComponentMesh:update( deltaTime )
	self.transform:setPosition( self.parent.position )
end

function ComponentMesh:render()
	if self.meshIndex >= 0 then
		Graphics.queueMesh( self.meshIndex, self.transform )
		
		if self.boundingBox and self.parent.selected then
			local worldBox =
			{
				minPosition = self.boundingBox.minPosition:add( self.parent.position ),
				maxPosition = self.boundingBox.maxPosition:add( self.parent.position )
			}
			DebugShapes.addAABB( worldBox.minPosition, worldBox.maxPosition, {0.0, 1.0, 0.0, 1.0} )
		end
	end
	
	return true
end

function ComponentMesh:addInfo( position, size, items )
	if ComponentMeshInfo.textureIndex < 0 then
		ComponentMeshInfo.textureIndex = Assets.loadTexture( DEFAULT_TEXTURE )
	end

	local info = {}
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
	
	local meshNameTextbox = EditorTextbox.create( {xoffset+padding, yoffset}, {info.size[1]-padding*2, 24} )
	meshNameTextbox.readOnly = true
	meshNameTextbox.text = "pillar.mesh"
	yoffset = yoffset + meshNameTextbox.size[2]
	
	info.items[#info.items+1] = meshNameLabel
	info.items[#info.items+1] = meshNameTextbox
	
	-- set size	
	info.size[2] = yoffset - position[2]
	
	-- add to callers list of items
	items[#items+1] = info
	
	return info.size[2]
end

function ComponentMeshInfo:update( deltatTime )
	local result = self.titleButton:update( deltaTime )

	if self.expanded then
		for _,v in pairs(self.items) do
			if v:update( deltaTime ) then
				result = true
			end
		end
	end
	
	return result
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
	end
end