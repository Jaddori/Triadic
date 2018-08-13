local gizmo = 
{
	position = Vec3.create(),
	visible = false,
	x = {10,0,0},
	y = {0,10,0},
	z = {0,0,10},
	
	xbounds = nil,
	ybounds = nil,
	zbounds = nil,
	
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
	if self.position[2] > -0.1 and self.position[2] < 0.1 then
		self.position[2] = 0.1
	end
	
	local x = position[1]
	local y = position[2]
	local z = position[3]
	
	self.xbounds = Physics.createAABB( {x+1,y-1,z-1}, {x+10,y+1,z+1} )
	self.ybounds = Physics.createAABB( {x-1,y+1,z-1}, {x+1,y+10,z+1} )
	self.zbounds = Physics.createAABB( {x-1,y-1,z+1}, {x+1,y+1,z+10} )
end

return gizmo