local grid = 
{
	showGrid = true,
	size = 100,
	interval = 2,
	color = { 0.25, 0.25, 0.25, 0.5 },
	yoffset = 0,
	
	showOrigo = true,
	origo = {0,0,0},
	x = {10,0,0},
	y = {0,10,0},
	z = {0,0,10},
	
	red = {1,0,0,1},
	green = {0,1,0,1},
	blue = {0,0,1,1},
}

function grid:render()
	-- render grid
	if self.showGrid then
		local len = self.size*self.interval
		for i=-len, len, self.interval do
			local z = { { i, self.yoffset, -len }, { i, self.yoffset, len } }
			local x = { { -len, self.yoffset, i }, { len, self.yoffset, i } }
			
			DebugShapes.addLine( z[1], z[2], self.color )
			DebugShapes.addLine( x[1], x[2], self.color )
		end
	end
	
	-- render origo
	if self.showOrigo then
		DebugShapes.addLine( self.origo, self.x, self.red, true )
		DebugShapes.addLine( self.origo, self.y, self.green, true )
		DebugShapes.addLine( self.origo, self.z, self.blue, true )
	end
end

return grid