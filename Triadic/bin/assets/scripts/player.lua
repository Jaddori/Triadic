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
	sinval = 0,

	ghostTransform = nil,
	ghostPosition = {0,0,0},

	commands = {},
}

function Player:load()
	self.transform = Transform.create()
	
	if IS_CLIENT then
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
	if IS_CLIENT then
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

		-- update ghost
		self.ghostTransform:setPosition( self.ghostPosition )
	end
end

function Player:fixedUpdate()
	if IS_CLIENT then
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
	if IS_CLIENT then
		self.prevPosition[1] = self.nextPosition[1]
		self.prevPosition[3] = self.nextPosition[3]

		self.nextPosition[1] = self.nextPosition[1] + command.horizontal*0.5
		self.nextPosition[3] = self.nextPosition[3] + command.vertical*0.5

		self.elapsedTime = 0
	else -- IS_SERVER
		local movement = { command.horizontal * 0.5, 0, command.vertical * 0.5 }
		self.transform:addPosition( movement )
	end
end

function Player:render()
	Graphics.queueMesh( self.meshIndex, self.transform )

	Graphics.queueMesh( self.meshIndex, self.ghostTransform )

	self.grid:render()
end

function Player:clientRead( message )
	local position = {0,0,0}

	position[1] = message:readFloat()
	position[2] = message:readFloat()
	position[3] = message:readFloat()

	copyVec( position, self.ghostPosition )
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
end

function Player:clientWrite()
	local commandCount = 0
	for i=1, #self.commands do
		if self.commands[i].localAck == GameClient.localAck then
			commandCount = commandCount + 1
		end
	end

	--Client.queueInt( commandCount )
	GameClient:queue( 1, CLIENT_INT, commandCount )

	for i=1, #self.commands do
		if self.commands[i].localAck == GameClient.localAck then
			--Client.queueInt( self.commands[i].horizontal )
			--Client.queueInt( self.commands[i].vertical )

			GameClient:queue( 1, CLIENT_INT, self.commands[i].horizontal )
			GameClient:queue( 1, CLIENT_INT, self.commands[i].vertical )
		end
	end

	return true
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

function Player:serverWrite()
	local position = self.transform:getPosition()

	--Server.queueFloat( position[1] )
	--Server.queueFloat( position[2] )
	--Server.queueFloat( position[3] )

	GameServer:queue( 1, SERVER_FLOAT, position[1] )
	GameServer:queue( 1, SERVER_FLOAT, position[2] )
	GameServer:queue( 1, SERVER_FLOAT, position[3] )

	return true
end

--addScript( Player )