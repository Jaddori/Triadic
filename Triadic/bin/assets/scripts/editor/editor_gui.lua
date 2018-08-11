local gui = 
{
	fontIndex = -1,
	fontHeight = 0,
	
	meshList =
	{
		meshNames = {},
		meshButtons = {},
		meshIndices = {},
		meshBoundingBoxes = {},
		selectedButton = -1,
		selectedMeshIndex = -1,
	},
	entityList =
	{
		entities = {},
		selectedEntitiy = -1,
	}
}

function gui:load()
	doscript( "editor/editor_button.lua" )
	
	self.fontIndex = Assets.loadFont( "./assets/fonts/verdana12.bin", "./assets/fonts/verdana12.dds" )
	self.fontHeight = Assets.getFont( self.fontIndex ):getHeight()
	
	local buttonHeight = self.fontHeight + 4
	
	self.meshList.meshNames = Filesystem.getFiles( "./assets/models/*" )
	for i=1, #self.meshList.meshNames do
		-- load mesh
		self.meshList.meshIndices[i] = Assets.loadMesh( "./assets/models/" .. self.meshList.meshNames[i] )
		
		local mesh = Assets.getMesh( self.meshList.meshIndices[i] )
		self.meshList.meshBoundingBoxes[i] = mesh:getBoundingBox()
	
		-- create button
		self.meshList.meshButtons[i] = EditorButton.create( {WINDOW_WIDTH-128-8, 8 + i*buttonHeight}, {128, buttonHeight}, self.meshList.meshNames[i] )
		
		self.meshList.meshButtons[i].onClick = function( self )
			gui.meshList.selectedButton = i
			gui.meshList.selectedMeshIndex = gui.meshList.meshIndices[i]
			self.color = {1, 1, 0, 1}
			self.hoverColor = {1,1,0,1}
		end
		
		self.meshList.meshButtons[i].onUnclicked = function( self )
			self.color = nil
			self.hoverColor = nil
		end
	end
end

function gui:update( deltaTime )
	local result = false

	for _,v in pairs(self.meshList.meshButtons) do
		if v:update( deltaTime ) then
			result = true
		end
	end
	
	for _,v in pairs(self.entityList.entities) do
		if v:update( deltaTime ) then
			result = true
		end
	end
		
	return result
end

function gui:render()
	for _,v in pairs(self.meshList.meshButtons) do
		v:render()
	end
	
	for _,v in pairs(self.entityList.entities) do
		v:render()
	end
end

function gui:addEntity( name )
	local buttonHeight = self.fontHeight + 4
	
	local count = #self.entityList.entities
	self.entityList.entities[count+1] = EditorButton.create( {32, 8 + count*buttonHeight}, {128, buttonHeight}, name )
end

return gui