CommandMove = 
{
	oldPosition = {0,0,0},
	newPosition = {0,0,0},
	entity = nil,
}

function CommandMove.create( oldPosition, newPosition, entity )
	local command = 
	{
		oldPosition = {0,0,0},
		newPosition = {0,0,0},
		entity = entity
	}

	copyVec( oldPosition, command.oldPosition )
	copyVec( newPosition, command.newPosition )

	setmetatable( command, { __index = CommandMove } )

	return command
end

function CommandMove:undo()
	copyVec( self.oldPosition, self.entity.position )
end

function CommandMove:redo()
	copyVec( self.newPosition, self.entity.position )
end