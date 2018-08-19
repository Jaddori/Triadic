local DEFAULT_TEXTURE = "./assets/textures/white.dds"
local MESH_LIST_PANEL_WIDTH = 128

ComponentMesh =
{
	name = "Mesh",
	transform = nil,
	meshIndex = -1,
	meshName = "",
	parent = nil,
	boundingBox = nil,
}

ComponentMeshWindow =
{
	window = {},
	component = {},
}

function ComponentMesh.create( parent )
	local result =
	{
		parent = parent,
		transform = Transform.create(),
		meshIndex = -1,
		boundingBox = nil,
		meshName = "",
	}

	--if #ComponentMeshInfo.meshIndices > 0 then
	--	result.meshIndex = ComponentMeshInfo.meshIndices[1]
	--	result.meshName = "./assets/models/" .. ComponentMeshInfo.meshNames[1]
	--	result.boundingBox = ComponentMeshInfo.meshBoundingBoxes[1]
	--end
	
	result.transform:setPosition( parent.position )
	
	setmetatable( result, { __index = ComponentMesh } )
	
	return result
end

function ComponentMesh:write( file, level )
	local componentName = self.parent.name .. "_component"
	writeIndent( file, level, "local " .. componentName .. " = ComponentMesh.create( " .. self.parent.name .. " )\n" )
	
	writeIndent( file, level, componentName .. ":loadMesh( \"" .. self.meshName .. "\" )\n" )

	writeIndent( file, level, self.parent.name .. ":addComponent( " .. componentName .. " )\n" )
end

function ComponentMesh:read( file )
end

function ComponentMesh:compile( file, level )
	writeIndent( file, level, "Mesh =\n" )
	writeIndent( file, level, "{\n" )
	level = level + 1

	writeIndent( file, level, "parent = " .. self.parent.name .. ",\n" )
	writeIndent( file, level, "transform = Transform.create(),\n" )
	--writeIndent( file, level, "meshIndex = " .. tostring( self.meshIndex ) .. ",\n" )
	writeIndent( file, level, "meshIndex = Assets.loadMesh( \"" .. self.meshName .. "\" ),\n" )

	level = level - 1
	writeIndent( file, level, "},\n" )
end

function ComponentMesh:copy( parent )
	local result = self.create( parent )
	
	result.meshIndex = self.meshIndex
	result.boundingBox = self.boundingBox
	result.meshName = self.meshName
	
	return result
end

function ComponentMesh:loadMesh( path )
	self.meshIndex = Assets.loadMesh( path )
	self.meshName = path
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
	local result = -1

	if self.boundingBox then
		local worldBox =
		{
			minPosition = self.boundingBox.minPosition:mul( self.parent.scale ),
			maxPosition = self.boundingBox.maxPosition:mul( self.parent.scale )
		}

		worldBox.minPosition = worldBox.minPosition:add( self.parent.position )
		worldBox.maxPosition = worldBox.maxPosition:add( self.parent.position )
		
		local hit = {}
		if Physics.rayAABB( ray, worldBox, hit ) then
			result = hit.length
		end
	end
	
	return result
end

function ComponentMesh:update( deltaTime )
end

function ComponentMesh:render()
	if self.meshIndex >= 0 then
		Graphics.queueMesh( self.meshIndex, self.transform )
		
		if self.boundingBox then
			if self.parent.selected or self.parent.hovered then
				local color = {0,1,0,1}
				if self.parent.hovered then
					color[1] = 1
				end

				local worldBox =
				{
					minPosition = self.boundingBox.minPosition:mul( self.parent.scale ),
					maxPosition = self.boundingBox.maxPosition:mul( self.parent.scale )
				}

				worldBox.minPosition = worldBox.minPosition:add( self.parent.position )
				worldBox.maxPosition = worldBox.maxPosition:add( self.parent.position )

				DebugShapes.addAABB( worldBox.minPosition, worldBox.maxPosition, color, false )
			end
		end
	end
	
	return true
end

function ComponentMesh:showInfoWindow()
	ComponentMeshWindow:show( self )
end

-- WINDOW
function ComponentMeshWindow:show( component )
	self.component = component
	self.window.visible = true

	-- update items
	self.window.items[1].textbox:setText( component.meshIndex )
end

function ComponentMeshWindow:load()
	self.window = EditorWindow.create( "Mesh Component" )
	self.window.position[1] = WINDOW_WIDTH - GUI_PANEL_WIDTH - self.window.size[1]
	self.window.visible = false

	local meshIndexInput = EditorInputbox.create( {0,0}, 0, "Mesh index:" )
	self.window:addItem( meshIndexInput )
end

function ComponentMeshWindow:update( deltaTime )
	return self.window:update( deltaTime )
end

function ComponentMeshWindow:render()
	self.window:render()
end

ComponentMeshWindow:load()

return ComponentMesh, ComponentMeshWindow