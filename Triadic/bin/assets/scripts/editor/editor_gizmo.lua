local gizmo = 
{
	position = {0,0,0},
	visible = false,
	x = {5,0,0},
	y = {0,5,0},
	z = {0,0,5},
	
	red = {1,0,0,1},
	green = {0,1,0,1},
	blue = {0,0,1,1},
}

function gizmo:update( deltaTime )
end

function gizmo:render()
	DebugShapes.addLine( self.position, addVec( self.position, self.x ), self.red )
	DebugShapes.addLine( self.position, addVec( self.position, self.y ), self.green )
	DebugShapes.addLine( self.position, addVec( self.position, self.z ), self.blue )
end

return gizmo