CommandAddEntity =
{
	editor = nil,
	entity = nil,
	position = {0,0,0},
}

function CommandAddEntity.create( editor, entity )
	local command =
	{
		editor = editor,
		entity = entity,
	}

	copyVec( command.position, entity.position )

	setmetatable( command, { __index = CommandAddEntity } )

	return command
end

function CommandAddEntity:undo()
	editor:removeEntity( self.entity )
end

function CommandAddEntity:redo()
	editor:createEntity( self.position )
end