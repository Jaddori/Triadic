CommandScale = 
{
	oldScale = {0,0,0},
	newScale = {0,0,0},
	entity = nil,
}

function CommandScale.create( oldScale, newScale, entity )
	local command = 
	{
		oldScale = {0,0,0},
		newScale = {0,0,0},
		entity = entity
	}

	copyVec( oldScale, command.oldScale )
	copyVec( newScale, command.newScale )

	setmetatable( command, { __index = CommandScale } )

	return command
end

function CommandScale:undo()
	copyVec( self.oldScale, self.entity.scale )
end

function CommandScale:redo()
	copyVec( self.newScale, self.entity.scale )
end