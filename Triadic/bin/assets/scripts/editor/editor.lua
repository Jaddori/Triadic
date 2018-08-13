Editor =
{
	name = "Editor",
	
	gui = nil,	
	entities = {},
	selectedEntity = -1,
}

function Editor:load()
	doscript( "editor/entity.lua" )

	self.camera = doscript( "editor/editor_camera.lua" )
	self.camera:load()
	
	self.gui = doscript( "editor/editor_gui.lua" )
	self.gui:load()
	
	-- gui meshes
	local meshNames = Filesystem.getFiles( "./assets/models/*" )
	for i=1, #meshNames do
		-- load mesh
		local meshIndex = Assets.loadMesh( "./assets/models/" .. meshNames[i] )
		
		--local mesh = Assets.getMesh( meshIndex )
		--local boundingBox = mesh:getBoundingBox()
		
		-- create button
		--local tag = { index = i, meshName = meshNames[i], meshIndex = meshIndex, boundingBox = boundingBox }
		--self.gui.panel.tabs.meshes:addMesh( meshNames[i], tag )
	end
	
	-- gui context menu
	self.gui.contextMenu:addItem( "New Entity", { index = 1 } )
	self.gui.contextMenu.onClick = function( button )
		if button.tag.index == 1 then
			local ray = self.camera.camera:createRay()
			local plane = Physics.createPlane( {0,1,0}, 0 )
			
			local hit = {}
			if Physics.rayPlane( ray, plane, hit ) then
				hit.position[2] = 0
				self:createEntity( hit.position )
			end
		end
	end
end

function Editor:unload()
end

function Editor:update( deltaTime )
	self.camera:update( deltaTime )
	
	local mouseCaptured = self.gui:update( deltaTime )
	
	if not mouseCaptured then
		if Input.buttonReleased( Buttons.Right ) then
			local mousePosition = Input.getMousePosition()
			self.gui.contextMenu:show( mousePosition )
		end
	end
	
	-- entities
	for _,v in pairs(self.entities) do
		v:update( deltaTime )
	end
end

function Editor:render()
	self.gui:render()
	
	-- entities
	for _,v in pairs(self.entities) do
		v:render()
	end
end

function Editor:createEntity( position )
	local entity = Entity.create( position )
	--entity:addComponent( ComponentMesh.create( position ) )
	local meshComponent = ComponentMesh.create( position )
	meshComponent.meshIndex = 3
	entity:addComponent( meshComponent )
	self.entities[#self.entities+1] = entity
	
	self.gui.panel.tabs.info:setEntity( entity )
end