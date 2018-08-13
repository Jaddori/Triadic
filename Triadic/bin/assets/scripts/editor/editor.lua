Editor =
{
	name = "Editor",
	
	gui = nil,	
	entities = {},
	selectedEntity = nil,
	selectedEntityIndex = -1,
	
	gizmo = nil
}

function Editor:load()
	doscript( "editor/entity.lua" )

	self.camera = doscript( "editor/editor_camera.lua" )
	self.camera:load()
	
	self.gui = doscript( "editor/editor_gui.lua" )
	self.gui:load()
	
	self.gizmo = doscript( "editor/editor_gizmo.lua" )
	self.gizmo:load()
	self.gizmo:setPosition( Vec3.create() )
	
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
	
	-- gui info panel
	self.gui.panel.tabs.info.nameTextbox.onFinish = function( self )
		if self.text:len() > 0 then
			Editor.selectedEntity.name = self.text
		end
	end
	
	self.gui.panel.tabs.info.positionTextbox.onFinish = function( self )
		if self.text:len() > 0 then
			local components = split( self.text, "," )
			
			local x = tonumber( components[1] )
			local y = tonumber( components[2] )
			local z = tonumber( components[3] )
			
			Editor.selectedEntity.position = {x,y,z}
			Editor.gizmo:setPosition( Editor.selectedEntity.position )
		end
	end
end

function Editor:unload()
end

function Editor:update( deltaTime )
	self.camera:update( deltaTime )
	self.gizmo:update( deltaTime )
	
	local mouseCaptured = self.gui:update( deltaTime )
	
	if not mouseCaptured then
		-- context menu
		if Input.buttonReleased( Buttons.Right ) then
			local mousePosition = Input.getMousePosition()
			self.gui.contextMenu:show( mousePosition )
		end
		
		-- selecting entities
		local ray = self.camera.camera:createRay()
		if Input.buttonReleased( Buttons.Left ) then
			if not self.xcaptured and not self.ycaptured and not self.zcaptured then
				self.selectedEntity = nil
				for _,v in pairs(self.entities) do
					if v:select( ray ) then
						self.selectedEntity = v
						v.selected = true
					else
						v.selected = false
					end
				end
				
				self.gui.panel.tabs.info:setEntity( self.selectedEntity )
				if self.selectedEntity then
					self.gizmo:setPosition( self.selectedEntity.position )
					self.gizmo.visible = true
					self.gizmo.selectedAxis = -1
				else
					self.gizmo.visible = false
				end
			end
		end
		
		if self.selectedEntity then
			local entityMoved = false
			
			if Input.buttonPressed( Buttons.Left ) then
				self.xcaptured = false
				self.ycaptured = false
				self.zcaptured = false
			
				-- translation in x-axis
				if Physics.rayAABB( ray, self.gizmo.xbounds ) then
					self.xcaptured = true
					
					self.xplane = Physics.createPlane( {0,0,1}, self.selectedEntity.position[3] )
					
					local hit = {}
					if Physics.rayPlane( ray, self.xplane, hit ) then
						self.xoffset = hit.position[1] - self.selectedEntity.position[1]
						self.gizmo.selectedAxis = 1
					end
				-- translation in y-axis
				elseif Physics.rayAABB( ray, self.gizmo.ybounds ) then
					self.ycaptured = true
					
					local forward = self.camera.camera:getForward()
					local xnormal = {1,0,0}
					local znormal = {0,0,1}
					
					local xdot = Vec3.dot( xnormal, forward )
					local zdot = Vec3.dot( znormal, forward )
					
					if xdot < zdot then
						self.yplane = Physics.createPlane( xnormal, self.selectedEntity.position[1] )
					else
						self.yplane = Physics.createPlane( znormal, self.selectedEntity.position[3] )
					end
					
					local hit = {}
					if Physics.rayPlane( ray, self.yplane, hit ) then
						self.yoffset = hit.position[2] - self.selectedEntity.position[2]
						self.gizmo.selectedAxis = 2
					end
				-- translation in z-axis
				elseif Physics.rayAABB( ray, self.gizmo.zbounds ) then
					self.zcaptured = true
					
					self.zplane = Physics.createPlane( {1,0,0}, self.selectedEntity.position[1] )
					
					local hit = {}
					if Physics.rayPlane( ray, self.zplane, hit ) then
						self.zoffset = hit.position[3] - self.selectedEntity.position[3]
						self.gizmo.selectedAxis = 3
					end
				end
			elseif Input.buttonDown( Buttons.Left ) then
				if self.xcaptured and self.xplane then
					local hit = {}
					if Physics.rayPlane( ray, self.xplane, hit ) then
						self.selectedEntity.position[1] = hit.position[1] - self.xoffset
						entityMoved = true
					end
				elseif self.ycaptured and self.yplane then
					local hit = {}
					if Physics.rayPlane( ray, self.yplane, hit ) then
						self.selectedEntity.position[2] = hit.position[2] - self.yoffset
						entityMoved = true
					end
				elseif self.zcaptured and self.zplane then
					local hit = {}
					if Physics.rayPlane( ray, self.zplane, hit ) then
						self.selectedEntity.position[3] = hit.position[3] - self.zoffset
						entityMoved = true
					end
				end
			else
				self.gizmo.selectedAxis = -1
			end
			
			-- update gizmo if entity was moved
			if entityMoved then
				self.gizmo:setPosition( self.selectedEntity.position )
			end
		end
	end
	
	-- entities
	for _,v in pairs(self.entities) do
		v:update( deltaTime )
	end
end

function Editor:render()
	self.gui:render()
	self.gizmo:render()
	
	-- entities
	for _,v in pairs(self.entities) do
		v:render()
	end
end

function Editor:createEntity( position )
	local entity = Entity.create( position, "New Entity" )
	--entity:addComponent( ComponentMesh.create( position ) )
	local meshComponent = ComponentMesh.create( entity, position )
	--meshComponent.meshIndex = 3
	meshComponent:loadMesh( "./assets/models/pillar.mesh" )
	entity:addComponent( meshComponent )
	self.entities[#self.entities+1] = entity
	
	self.gui.panel.tabs.info:setEntity( entity )
	self.selectedEntity = entity
	
	self.gui.panel.tabs.entities:addEntity( entity )
end