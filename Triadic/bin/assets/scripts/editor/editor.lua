Editor =
{
	name = "Editor",
	
	transforms = {},
	meshIndices = {},
	
	selectedTransform = -1,
}

function Editor:load()
	self.camera = doscript( "editor/editor_camera.lua" )
	self.camera:load()
	
	self.gui = doscript( "editor/editor_gui.lua" )
	self.gui:load()
	
	self.gizmo = doscript( "editor/editor_gizmo.lua" )
end

function Editor:update( deltaTime )
	self.camera:update( deltaTime )
	
	local mouseCaptured = self.gui:update( deltaTime )
	
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
				self.gui.meshList.selectedMeshIndex = -1
			end
		end
	end
	
	if self.selectedTransform >= 0 then
		local movement = {0,0,0}
		
		if Input.keyDown( Keys.Left ) then movement[1] = movement[1] + 1 end
		if Input.keyDown( Keys.Right ) then movement[1] = movement[1] - 1 end
		if Input.keyDown( Keys.Up ) then movement[3] = movement[3] + 1 end
		if Input.keyDown( Keys.Down ) then movement[3] = movement[3] - 1 end
		
		for i=1, 3 do movement[i] = movement[i] * deltaTime end
		
		self.transforms[self.selectedTransform]:addPosition( movement )
		
		local newPosition = self.transforms[self.selectedTransform]:getPosition()
		copyVec( newPosition, self.gizmo.position )
	end
end

function Editor:render()
	self.gui:render()
	self.gizmo:render()
	
	for i=1, #self.transforms do
		Graphics.queueMesh( self.meshIndices[i], self.transforms[i] )
	end
end

function Editor:createMesh( index, position )
	local transform = Transform.create()
	transform:setPosition( position )
	
	self.transforms[#self.transforms+1] = transform
	self.meshIndices[#self.meshIndices+1] = index
	
	self.selectedTransform = #self.transforms
end