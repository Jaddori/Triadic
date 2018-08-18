CommandRotate = 
{
	oldOrientation = {0,0,0,1},
	newOrientation = {0,0,0,1},
	entity = nil,
}

function CommandRotate.create( oldOrientation, newOrientation, entity )
	local command = 
	{
		oldOrientation = {0,0,0},
		newOrientation = {0,0,0},
		entity = entity
	}

	copyVec( oldOrientation, command.oldOrientation )
	copyVec( newOrientation, command.newOrientation )

	setmetatable( command, { __index = CommandRotate } )

	return command
end

function CommandRotate:undo()
	copyVec( self.oldOrientation, self.entity.orientation )
end

function CommandRotate:redo()
	copyVec( self.newOrientation, self.entity.orientation )
end