local prefabs = 
{
	position = {0,0},
	size = {0,0},
}

function prefabs:load( position, size )
end

function prefabs:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	return capture
end

function prefabs:render()
end

return prefabs