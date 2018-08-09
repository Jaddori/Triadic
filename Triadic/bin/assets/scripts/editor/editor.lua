Editor =
{
	name = "Editor",
	
	transforms = {},
	meshIndices = {},
	meshBoundingBoxes = {},
	
	selectedTransform = -1,
	lastRay = {},
	
	xplane = 0,
	xcaptured = false,
	
	zplane = 0,
	zcaptured = false,
	
	aabb = nil,
	sphere = nil,
	
	gizmoOffset = {0,0,0},
}

function Editor:load()
	self.camera = doscript( "editor/editor_camera.lua" )
	self.camera:load()
	
	self.gui = doscript( "editor/editor_gui.lua" )
	self.gui:load()
	
	self.gizmo = doscript( "editor/editor_gizmo.lua" )
	self.gizmo:load()
end

function Editor:unload()
	self.gizmo:unload()
end

function Editor:update( deltaTime )
	self.camera:update( deltaTime )
	
	local mouseCaptured = self.gui:update( deltaTime )
	
	if not mouseCaptured and Input.buttonDown( Buttons.Left ) then
		if self.selectedTransform >= 0 then
			local mousePosition = Input.getMousePosition()
			local near = self.camera.camera:unproject( mousePosition, 0.0 )
			local far = self.camera.camera:unproject( mousePosition, 1.0 )
			
			local dif = far:sub( near )
			local length = dif:length()
			local ray = Physics.createRay( near, dif:normalize(), length )
		
			if self.xcaptured then
				local zlength = math.abs( far[3] - near[3] )
				local sublength = math.abs( self.xplane - near[3] )
				local div = sublength / zlength
				
				local hit =
				{
					near[1] + (far[1]-near[1]) * div,
					near[2] + (far[2]-near[2]) * div,
					self.xplane
				}
				
				self.sphere = Physics.createSphere( hit, 1.0 )
				
				local position = self.transforms[self.selectedTransform]:getPosition()
				position[1] = hit[1]
				self.transforms[self.selectedTransform]:setPosition( position )
				
				position = position:add( self.gizmoOffset )
				self.gizmo:setPosition( position )
				self.gizmo.selectedAxis = 1
			elseif self.zcaptured then
				local xlength = math.abs( far[1] - near[1] )
				local sublength = math.abs( self.zplane - near[1] )
				local div = sublength / xlength
				
				local hit =
				{
					self.zplane,
					near[2] + (far[2]-near[2]) * div,
					near[3] + (far[3]-near[3]) * div
				}
				
				self.sphere = Physics.createSphere( hit, 1.0 )
				
				local position = self.transforms[self.selectedTransform]:getPosition()
				position[3] = hit[3]
				self.transforms[self.selectedTransform]:setPosition( position )
				
				position = position:add( self.gizmoOffset )
				self.gizmo:setPosition( position )
				self.gizmo.selectedAxis = 3
			else
				local center = self.gizmo.position
				
				-- x axis
				local x = Physics.createAABB( { center[1]+1, center[2]-1, center[3]-1 },
												{ center[1]+10, center[2]+1, center[3]+1 } )
				
				--self.aabb = x
				
				if Physics.rayAABB( ray.start, ray.direction, ray.length, x.minPosition, x.maxPosition ) then
					mouseCaptured = true
					self.xplane = center[3]
					self.xcaptured = true
				else
					self.xcaptured = false
				end
				
				-- z axis
				if not self.xcaptured then
					local z = Physics.createAABB( { center[1]-1, center[2]-1, center[3]+1 },
													{ center[1]+1, center[2]+1, center[3]+10 } )
					
					--self.aabb = z
					
					if Physics.rayAABB( ray.start, ray.direction, ray.length, z.minPosition, z.maxPosition ) then
						mouseCaptured = true
						self.zplane = center[1]
						self.zcaptured = true
					else
						self.zcaptured = false
					end
				end
			end
		end
	else
		self.xcaptured = false
		self.zcaptured = false
		
		self.gizmo.selectedAxis = -1
	end
	
	if not mouseCaptured then	
		if Input.buttonReleased( Buttons.Left ) then
			if self.gui.meshList.selectedMeshIndex >= 0 then
				local mousePosition = Input.getMousePosition()
				local near = self.camera.camera:unproject( mousePosition, 0.0 )
				local far = self.camera.camera:unproject( mousePosition, 1.0 )
				
				local length = math.max( near[2], far[2] ) - math.min( near[2], far[2] )
				local subLength = math.abs( near[2] )
				local div = subLength / length
				
				local hit =
				{
					near[1] + (far[1]-near[1]) * div,
					0,
					near[3] + (far[3]-near[3]) * div,
				}
		
				self:createMesh( self.gui.meshList.selectedMeshIndex, hit )
				
				if not Input.keyDown( Keys.C ) then
					self.gui.meshList.selectedMeshIndex = -1
				end
			elseif #self.transforms > 0 then
				self.selectedTransform = -1
				self.gizmo.visible = false
				
				for i=1, #self.transforms do
					local mousePosition = Input.getMousePosition()
					local near = self.camera.camera:unproject( mousePosition, 0.0 )
					local far = self.camera.camera:unproject( mousePosition, 1.0 )
					
					local dif = far:sub( near )
					local length = dif:length()
					local ray = Physics.createRay( near, dif:normalize(), length )
					
					local position = self.transforms[i]:getPosition()
					local aabbLocal = self.meshBoundingBoxes[i]
					local aabb = 
					{
						minPosition = aabbLocal.minPosition:add( position ),
						maxPosition = aabbLocal.maxPosition:add( position )
					}
					
					if Physics.rayAABB( ray.start, ray.direction, ray.length, aabb.minPosition, aabb.maxPosition ) then
						self.gizmo.visible = true
						self.gizmoOffset = Physics.getAABBCenter( aabbLocal )
						local position = self.transforms[i]:getPosition()
						local center = self.gizmoOffset:add( position )
						
						self.gizmo:setPosition( center )
						
						self.selectedTransform = i
					end
				end
				
				self.lastRay[1] = near
				self.lastRay[2] = far
			end
		end
	end
	
	if self.selectedTransform >= 0 then
		local movement = {0,0,0}
		
		if Input.keyDown( Keys.Left ) then movement[1] = movement[1] + 1 end
		if Input.keyDown( Keys.Right ) then movement[1] = movement[1] - 1 end
		if Input.keyDown( Keys.Up ) then movement[3] = movement[3] + 1 end
		if Input.keyDown( Keys.Down ) then movement[3] = movement[3] - 1 end
		
		if movement[1] ~= 0 or movement[2] ~= 0 or movement[3] ~= 0 then
			for i=1, 3 do movement[i] = movement[i] * deltaTime end
			
			self.transforms[self.selectedTransform]:addPosition( movement )
			
			local newPosition = self.transforms[self.selectedTransform]:getPosition()
			self.gizmo:setPosition( newPosition )
		end
	end
end

function Editor:render()
	self.gui:render()
	self.gizmo:render()
	
	if self.aabb then
		DebugShapes.addAABB( self.aabb.minPosition, self.aabb.maxPosition, {0,1,1,1} )
	end
	
	if self.sphere then
		DebugShapes.addSphere( self.sphere.center, self.sphere.radius, {1,1,0,1} )
	end
	
	for i=1, #self.transforms do
		Graphics.queueMesh( self.meshIndices[i], self.transforms[i] )
		
		local position = self.transforms[i]:getPosition()
		
		local bounds = self.meshBoundingBoxes[i]
		local minPosition = Vec3.copy( bounds.minPosition )
		local maxPosition = Vec3.copy( bounds.maxPosition )
		
		minPosition = minPosition:add( position )
		maxPosition = maxPosition:add( position )
		
		DebugShapes.addAABB( minPosition, maxPosition, {0,1,0,1} )
	end
	
	if #self.lastRay > 0 then
		DebugShapes.addLine( self.lastRay[1], self.lastRay[2], {1,1,0,1} )
	end
end

function Editor:createMesh( index, position )
	local transform = Transform.create()
	transform:setPosition( position )
	
	self.transforms[#self.transforms+1] = transform
	self.meshIndices[#self.meshIndices+1] = index
	self.meshBoundingBoxes[#self.meshBoundingBoxes+1] = self.gui.meshList.meshBoundingBoxes[self.gui.meshList.selectedButton]
	
	self.selectedTransform = #self.transforms
end