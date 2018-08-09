Player =
{
	name = "Player",
	transform = nil,
	meshIndex = -1,
}

function Player:load()
	self.transform = Transform.create()
	self.meshIndex = Assets.loadMesh( "./assets/models/box.mesh" )
end

function Player:update( deltaTime )
	local movement = {0,0,0}
	
	if Input.keyDown( Keys.Left ) then
		movement[1] = movement[1] - 1
	end
	
	if Input.keyDown( Keys.Right ) then
		movement[1] = movement[1] + 1
	end
	
	if Input.keyDown( Keys.Up ) then
		movement[3] = movement[3] - 1
	end
	
	if Input.keyDown( Keys.Down ) then
		movement[3] = movement[3] + 1
	end
	
	movement[1] = movement[1] * deltaTime
	movement[3] = movement[3] * deltaTime
	
	self.transform:addPosition( movement )
end

function Player:render()
	Graphics.queueMesh( self.meshIndex, self.transform )
	
	local position = self.transform:getPosition()
	DebugShapes.addSphere( position, 2.0, {0.0, 1.0, 0.0, 1.0} )
end

addScript( Player )