Player =
{
	name = "Player",
	transform = nil,
	meshIndex = -1,
	camera = nil,
	grid = nil,
}

function Player:load()
	self.transform = Transform.create()
	self.meshIndex = Assets.loadMesh( "./assets/models/cube.mesh" )

	self.camera = Graphics.getPerspectiveCamera()
	self.camera:setDirection( {0,-1,-1} )

	self.grid = doscript( "editor/editor_grid.lua" )
end

function Player:update( deltaTime )
	local movement = {0,0,0}
	
	if Input.keyDown( Keys.Left ) then
		movement[1] = movement[1] - 10
	end
	
	if Input.keyDown( Keys.Right ) then
		movement[1] = movement[1] + 10
	end
	
	if Input.keyDown( Keys.Up ) then
		movement[3] = movement[3] - 10
	end
	
	if Input.keyDown( Keys.Down ) then
		movement[3] = movement[3] + 10
	end
	
	movement[1] = movement[1] * deltaTime
	movement[3] = movement[3] * deltaTime
	
	self.transform:addPosition( movement )

	local position = self.transform:getPosition()
	self.camera:setPosition( position )
	self.camera:relativeMovement( {0,0,-25} )
end

function Player:render()
	Graphics.queueMesh( self.meshIndex, self.transform )
	
	local position = self.transform:getPosition()
	DebugShapes.addSphere( position, 2.0, {0.0, 1.0, 0.0, 1.0} )

	self.grid:render()
end

--addScript( Player )