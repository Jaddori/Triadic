Player =
{
	name = "Player",
	transform = nil,
	meshIndex = -1,
	camera = nil,
	grid = nil,

	ghostTransform = nil,
	ghostPosition = {0,0,0},
}

function Player:load()
	self.transform = Transform.create()
	
	if isClient then
		self.ghostTransform = Transform.create()

		self.meshIndex = Assets.loadMesh( "./assets/models/cube.mesh" )

		self.camera = Graphics.getPerspectiveCamera()
		self.camera:setDirection( {0,-1,-1} )

		self.grid = doscript( "editor/editor_grid.lua" )

		GameClient:register( self, 1 )
	else
		GameServer:register( self, 1 )
	end
end

function Player:unload()
end

function Player:update( deltaTime )
	if isClient then
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

		local newGhostPosition = self.ghostTransform:getPosition()
		lerpVec( newGhostPosition, self.ghostPosition, 0.02 )
		self.ghostTransform:setPosition( newGhostPosition )
	end
end

function Player:render()
	Graphics.queueMesh( self.meshIndex, self.transform )

	Graphics.queueMesh( self.meshIndex, self.ghostTransform )
	
	local position = self.transform:getPosition()
	DebugShapes.addSphere( position, 2.0, {0.0, 1.0, 0.0, 1.0} )

	self.grid:render()
end

function Player:clientRead( message )
	local position = {0,0,0}

	position[1] = message:readFloat()
	position[2] = message:readFloat()
	position[3] = message:readFloat()

	--self.ghostTransform:setPosition( position )
	self.ghostPosition = position
end

function Player:clientWrite()
	local position = self.transform:getPosition()

	Client.queueFloat( position[1] )
	Client.queueFloat( position[2] )
	Client.queueFloat( position[3] )
end

function Player:serverRead( message )
	local position = {0,0,0}

	position[1] = message:readFloat()
	position[2] = message:readFloat()
	position[3] = message:readFloat()

	self.transform:setPosition( position )
end

function Player:serverWrite()
	local position = self.transform:getPosition()

	Server.queueFloat( position[1] )
	Server.queueFloat( position[2] )
	Server.queueFloat( position[3] )
end

--addScript( Player )