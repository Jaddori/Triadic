function insideRect( position, size, point )
	return ( point[1] >= position[1] and
				point[2] >= position[2] and
				point[1] <= position[1] + size[1] and
				point[2] <= position[2] + size[2] );
end

function addVec( a, b )
	if #a ~= #b then return nil end

	local result = {}
	for i=1, #a do
		result[i] = a[i] + b[i]
	end
	
	return result
end

function copyVec( src, dst )
	for i=1, #src do
		dst[i] = src[i]
	end
end