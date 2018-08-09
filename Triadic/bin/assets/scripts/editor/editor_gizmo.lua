local gizmo = 
{
	position = Vec3.create(),
	visible = false,
	x = {10,0,0},
	y = {0,10,0},
	z = {0,0,10},
	
	red = {1,0,0,1},
	green = {0,1,0,1},
	blue = {0,0,1,1},
	
	selectedAxis = -1,
}

function gizmo:load()
end

function gizmo:unload()
end

function gizmo:update( deltaTime )
end

function gizmo:render()
	if self.visible then
		self.red[4] = 1
		self.green[4] = 1
		self.blue[4] = 1
		
		if self.selectedAxis == 1 then
			self.green[4] = 0.1
			self.blue[4] = 0.1
		elseif self.selectedAxis == 2 then
			self.red[4] = 0.1
			self.blue[4] = 0.1
		elseif self.selectedAxis == 3 then
			self.red[4] = 0.1
			self.green[4] = 0.1
		end
	
		DebugShapes.addLine( self.position, addVec( self.position, self.x ), self.red )
		DebugShapes.addLine( self.position, addVec( self.position, self.y ), self.green )
		DebugShapes.addLine( self.position, addVec( self.position, self.z ), self.blue )
	end
end

function gizmo:setPosition( position )
	self.position = Vec3.copy( position )
end

return gizmo