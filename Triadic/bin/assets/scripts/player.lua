Player =
{
	name = "Player",
	transform = nil,
	meshIndex = -1,
	camera = nil,
	grid = nil,
	velocity = {0,0,0},
	prevPosition = {0,0,0},
	nextPosition = {0,0,0},
	elapsedTime = 0,

	ghostTransform = nil,
	ghostPosition = {0,0,0},

	isLocal = false,
	commands = {},

	movementRays = {},
	collisionMargin = 0.1,

	-- DEBUG
	fontIndex = -1,
}

function Player.create( isLocal )
	local player = 
	{
		transform = Transform.create(),
		velocity = {0,0,0},
		prevPosition = {0,0,0},
		nextPosition = {0,0,0},
		elapsedTime = 0,
	
		ghostTransform = nil,
		ghostPosition = {0,0,0},
	
		isLocal = isLocal,
		commands = {},

		movementRays = {},
	}

	if IS_CLIENT then
		player.ghostTransform = Transform.create()

		for i=1, 50 do
			player.movementRays[i] = { first = {0,0,0}, last = {0,0,0}, color = {0,0,0,0} }
		end

		if player.isLocal then
			player.camera = Graphics.getPerspectiveCamera()
			player.camera:setDirection( {0,-1,-1} )

			player.grid = doscript( "editor/editor_grid.lua" )

			player.fontIndex = Assets.loadFont( "./assets/fonts/verdana12.bin", "./assets/fonts/verdana12.dds" )
		end
	end

	setmetatable( player, { __index = Player } )

	return player
end

function Player:load()
	if IS_CLIENT then
		self.meshIndex = Assets.loadMesh( "./assets/models/cube.mesh" )
	end
end

function Player:unload()
end

function Player:update( deltaTime )
	if IS_CLIENT then
		if self.isLocal then
			-- update local players position
			self.elapsedTime = self.elapsedTime + deltaTime
			local timestep = TIMESTEP_MS * 0.001
			local t = self.elapsedTime / timestep

			if t > 1.0 then
				t = 1.0
			end

			local position = lerpVec( self.prevPosition, self.nextPosition, t )

			self.transform:setPosition( position )

			-- update camera position
			self.camera:setPosition( position )
			self.camera:relativeMovement( {0,0,-25} )
		else -- not local
			self.elapsedTime = self.elapsedTime + deltaTime
			local timestep = (GameClient.averageReceiveTime*2) * 0.001

			local t = 0.5
			if timestep > 0 then
				t = self.elapsedTime / timestep
			end
			
			if t > 1.0 then
				t = 1.0
			end

			position = lerpVec( self.prevPosition, self.nextPosition, t )

			self.transform:setPosition( position )
		end
	end
end

function Player:fixedUpdate()
	if IS_CLIENT and self.isLocal then
		local command = { horizontal = 0, vertical = 0, localAck = GameClient.localAck }

		if Input.keyDown( Keys.Left ) then
			command.horizontal = command.horizontal - 1
		end

		if Input.keyDown( Keys.Right ) then
			command.horizontal = command.horizontal + 1
		end

		if Input.keyDown( Keys.Up ) then
			command.vertical = command.vertical - 1
		end

		if Input.keyDown( Keys.Down ) then
			command.vertical = command.vertical + 1
		end

		self:processCommand( command )
		self.commands[#self.commands+1] = command
	end
end

function Player:processCommand( command )
	if IS_CLIENT and self.isLocal then
		self.prevPosition[1] = self.nextPosition[1]
		self.prevPosition[3] = self.nextPosition[3]

		self.nextPosition[1] = self.nextPosition[1] + command.horizontal*0.5
		self.nextPosition[3] = self.nextPosition[3] + command.vertical*0.5

		self.elapsedTime = 0

		-- check collision
		local movement = subVec( self.nextPosition, self.prevPosition )
		local ray = Physics.createRayFromPoints( self.prevPosition, self.nextPosition )

		local shortest = ray.length
		local collisionHit = {}
		local collisionBox = {}
		for _,v in pairs(BoundingBoxes.aabbs) do
			local hit = {}
			if Physics.rayAABB( ray, v, hit ) then
				if hit.length < shortest then
					shortest = hit.length
					collisionHit = hit
					collisionBox = v
				end
			end
		end

		if collisionHit.position then
			--self.nextPosition[1] = collisionHit.position[1] + collisionHit.normal[1]*0.5
			--self.nextPosition[3] = collisionHit.position[3] + collisionHit.normal[3]*0.5

			if math.abs( collisionHit.normal[1] ) > 0 then
				self.nextPosition[1] = collisionBox.center[1] + (collisionBox.extents[1] + self.collisionMargin) * collisionHit.normal[1]
			else
				self.nextPosition[3] = collisionBox.center[3] + (collisionBox.extents[3] + self.collisionMargin) * collisionHit.normal[3]
			end
		end

		local color = { 0, 1, 0, 1 }
		if shortest < ray.length then
			color = { 1, 0, 0, 1 }
		end

		local movementRay = { first = {0,0,0}, last = {0,0,0}, color = color }
		copyVec( self.prevPosition, movementRay.first )
		copyVec( self.nextPosition, movementRay.last )
		--self:addMovementRay( movementRay )
	else -- IS_SERVER
		--local movement = { command.horizontal * 0.5, 0, command.vertical * 0.5 }
		--self.transform:addPosition( movement )

		local curPosition = self.transform:getPosition()
		local newPosition = addVec( curPosition, { command.horizontal * 0.5, 0, command.vertical * 0.5 } )

		local ray = Physics.createRayFromPoints( curPosition, newPosition )

		local shortest = ray.length
		local collisionHit = {}
		local collisionBox = {}

		for _,v in pairs(BoundingBoxes.aabbs) do
			local hit = {}
			if Physics.rayAABB( ray, v, hit ) then
				if hit.length < shortest then
					shortest = hit.length
					collisionHit = hit
					collisionBox = v
				end
			end
		end

		if collisionHit.normal then
			--newPosition[1] = collisionHit.position[1] + collisionHit.normal[1]*0.5
			--newPosition[3] = collisionHit.position[3] + collisionHit.normal[3]*0.5

			if math.abs( collisionHit.normal[1] ) > 0 then
				newPosition[1] = collisionBox.center[1] + (collisionBox.extents[1] + self.collisionMargin) * collisionHit.normal[1]
			else
				newPosition[3] = collisionBox.center[3] + (collisionBox.extents[3] + self.collisionMargin) * collisionHit.normal[3]
			end
		end

		self.transform:setPosition( newPosition )
	end
end

function Player:addMovementRay( ray )
	for i=#self.movementRays, 2, -1 do
		self.movementRays[i] = self.movementRays[i-1]
	end
	
	self.movementRays[1] = ray
end

function Player:render()
	Graphics.queueMesh( self.meshIndex, self.transform )
	--Graphics.queueMesh( self.meshIndex, self.ghostTransform )

	local position = self.ghostTransform:getPosition()
	local ghostMin = { position[1]-1, position[2]-1, position[3]-1 }
	local ghostMax = { position[1]+1, position[2]+1, position[3]+1 }
	DebugShapes.addAABB( ghostMin, ghostMax, {0,1,0,1}, false )

	-- render movement rays
	for _,v in pairs(self.movementRays) do
		DebugShapes.addLine( v.first, v.last, v.color, true )
	end

	-- render debug information
	if self.isLocal then
		self.grid:render()

		local rttText = "Average RTT: " .. tostring( math.floor( GameClient.averageRTT ) )
		Graphics.queueText( self.fontIndex, rttText, {32,32}, 0, {1,1,1,1} )

		local receiveTimeText = "Average receive time: " .. tostring( math.floor( GameClient.averageReceiveTime ) )
		Graphics.queueText( self.fontIndex, receiveTimeText, {32,32+16}, 0, {1,1,1,1} )
	end
end

function Player:clientWrite()
	local commandCount = 0
	for i=1, #self.commands do
		if self.commands[i].localAck == GameClient.localAck then
			commandCount = commandCount + 1
		end
	end

	GameClient:queue( 1, CLIENT_INT, commandCount )

	for i=1, #self.commands do
		if self.commands[i].localAck == GameClient.localAck then
			GameClient:queue( 1, CLIENT_INT, self.commands[i].horizontal )
			GameClient:queue( 1, CLIENT_INT, self.commands[i].vertical )
		end
	end

	return true
end

function Player:clientRead( message )
	local position = {0,0,0}

	position[1] = message:readFloat()
	position[2] = message:readFloat()
	position[3] = message:readFloat()

	if self.isLocal then
		copyVec( position, self.ghostPosition )
		self.ghostTransform:setPosition( self.ghostPosition )

		copyVec( position, self.prevPosition )
		copyVec( position, self.nextPosition )

		local newCommands = {}
		local count = #self.commands
		for i=1, count do
			if self.commands[i].localAck > message.remoteAck then
				self:processCommand( self.commands[i] )
				newCommands[#newCommands+1] = self.commands[i]
			end
		end

		self.commands = newCommands
	else
		copyVec( position, self.ghostPosition )
		self.ghostTransform:setPosition( self.ghostPosition )

		local currentPosition = self.transform:getPosition()
		copyVec( currentPosition, self.prevPosition )
		copyVec( position, self.nextPosition )

		self.elapsedTime = 0
	end
end

function Player:serverRead( message )
	local commandCount = message:readInt()

	for i=1, commandCount do
		local command =
		{
			horizontal = message:readInt(),
			vertical = message:readInt(),
		}

		self:processCommand( command )
	end
end

function Player:serverWrite( hash )
	local position = self.transform:getPosition()

	GameServer:queue( hash, 1, SERVER_FLOAT, position[1] )
	GameServer:queue( hash, 1, SERVER_FLOAT, position[2] )
	GameServer:queue( hash, 1, SERVER_FLOAT, position[3] )

	return true
end