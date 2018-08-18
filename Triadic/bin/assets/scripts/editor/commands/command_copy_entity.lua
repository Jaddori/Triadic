CommandCopyEntity =
{
	editor = nil,
	entity = nil,
}

function CommandCopyEntity.create( editor, entity )
	local command =
	{
		editor = editor,
		entity = entity,
	}

	setmetatable( command, { __index = CommandCopyEntity } )

	return command
end

function CommandCopyEntity:undo()
	self.editor:removeEntity( self.entity )
end

function CommandCopyEntity:redo()
	self.editor:addEntity( self.entity )
end