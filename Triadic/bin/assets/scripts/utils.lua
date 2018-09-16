function insideRect( position, size, point )
	assert( position, "Position was nil." )
	assert( size, "Size was nil." )
	assert( point, "Point was nil." )

	assert( istable( position ), "Position must be a table." )
	assert( istable( size ), "Size must be a table." )
	assert( istable( point ), "Point must be a table." )

	assert( #position >= 2, "Position must contain at least 2 elements." )
	assert( #size >= 2, "Size must contain at least 2 elements." )
	assert( #point >= 2, "Point must contain at least 2 elements." )

	return ( point[1] >= position[1] and
				point[2] >= position[2] and
				point[1] <= position[1] + size[1] and
				point[2] <= position[2] + size[2] );
end

function addVec( a, b )
	assert( istable( a ) and istable( b ), "Both arguments must be tables." )
	assert( #a == #b, "Mismatch in table size." )

	local result = {}
	for i=1, #a do
		result[i] = a[i] + b[i]
	end
	
	return result
end

function subVec( a, b )
	assert( istable( a ) and istable( b ), "Both arguments must be tables." )
	assert( #a == #b, "Mismatch in table size." )

	local result = {}
	for i=1, #a do
		result[i] = a[i] - b[i]
	end
	
	return result
end

function copyVec( src, dst )
	assert( istable( src ), "Source must be a table." )
	assert( istable( dst ), "Destination must be a table." )

	for i=1, #src do
		dst[i] = src[i]
	end
end

function normalizeVec( vec )
	assert( istable( vec ), "Input must be a table." )

	local result = {}

	local magnitude = 0
	for i=1, #vec do
		magnitude = magnitude + (vec[i]*vec[i])
	end

	magnitude = math.sqrt( magnitude )

	for i=1, #vec do
		result[i] = vec[i] / magnitude
	end

	return result
end

function lerpVec( a, b, t )
	assert( #a == #b, "Vectors must have same dimension." )

	for i=1, #a do
		a[i] = lerp( a[i], b[i], t )
	end
end

function stringVec( vec )
	assert( istable( vec ), "Input must be a table." )

	local result = tostring( roundTo( vec[1], 2 ) )
	
	for i=2, #vec do
		result = result .. "," .. tostring( roundTo( vec[i], 2 ) )
	end
	
	return result
end

function vecString( str )
	assert( isstring( str ), "Input must be a string." )

	local result = {}
	local components = split( str, "," )

	for i=1, #components do
		result[i] = tonumber( components[i] )
	end

	return result
end

function equalsVec( a, b )
	assert( istable( a ) and istable( b ), "Both arguments must be tables." )

	local result = true
	
	if #a == #b then
		for i=1, #a do
			if a[i] ~= b[i] then
				result = false
			end
		end
	else
		result = false
	end
	
	return result
end

function split( str, delimiter )
	assert( isstring( str ), "Input must be a string." )

	local result = {}
	
	local req = string.format("([^%s]+)", delimiter)
	for word in str:gmatch(req) do
		result[#result+1] = word
	end
	
	return result
end

function roundTo(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function writeIndent( file, level, text )
	file:write( string.rep( "\t", level ) .. text )
end

function lerp( a, b, t )
	return a + (b-a)*t
end

function easeInCubic( t, b, c, d )
	t = t / d
	return c * math.pow(t, 3) + b
end
  
function easeOutCubic( t, b, c, d )
	t = t / d - 1
	return c * (math.pow(t, 3) + 1) + b
end

function tableVal( t, size, default )
	local result = {}

	if t then
		for i=1, #t do
			result[i] = t[i]
		end
	else
		size = size or 2
		default = default or 0
		for i=1, size do
			result[i] = default
		end
	end

	return result
end

function isnumber( a )
	return type(a) == "number"
end

function isstring( a )
	return type(a) == "string"
end

function istable( a )
	return type(a) == "table"
end

function isuserdata( a )
	return type(a) == "userdata"
end

function isfunction( a )
	return type(a) == "function"
end

function isboolean( a )
	return type(a) == "boolean"
end
