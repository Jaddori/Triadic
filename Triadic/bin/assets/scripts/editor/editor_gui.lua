local gui = 
{
	meshList =
	{
		fontIndex = -1,
		fontHeight = 0,
		meshNames = {},
		meshButtons = {},
		meshIndices = {},
		selectedButton = -1,
		selectedMeshIndex = -1,
	},
}

function gui:load()
	doscript( "editor/editor_button.lua" )
	
	self.meshList.fontIndex = Assets.loadFont( "./assets/fonts/verdana12.bin", "./assets/fonts/verdana12.dds" )
	self.meshList.fontHeight = Assets.getFont( self.meshList.fontIndex ):getHeight()
	
	local buttonHeight = self.meshList.fontHeight + 4
	
	self.meshList.meshNames = Filesystem.getFiles( "./assets/models/*" )
	for i=1, #self.meshList.meshNames do
		-- load mesh
		self.meshList.meshIndices[i] = Assets.loadMesh( "./assets/models/" .. self.meshList.meshNames[i] )
	
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
	
	return result
end

function gui:render()
	for _,v in pairs(self.meshList.meshButtons) do
		v:render()
	end
end

return gui