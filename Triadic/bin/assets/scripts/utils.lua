function insideRect( position, size, point )
	return ( point[1] >= position[1] and
				point[2] >= position[2] and
				point[1] <= position[1] + size[1] and
				point[2] <= position[2] + size[2] );
end

function addVec( a, b )
	if #a ~= #b then return error( "Mismatch in table size." ) end

	local result = {}
	for i=1, #a do
		result[i] = a[i] + b[i]
	end
	
	return result
end

function subVec( a, b )
	if #a ~= #b then error( "Mismatch in table size." ) end

	local result = {}
	for i=1, #a do
		result[i] = a[i] - b[i]
	end
	
	return result
end

function copyVec( src, dst )
	for i=1, #src do
		dst[i] = src[i]
	end
end

function normalizeVec( vec )
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

function stringVec( vec )
	local result = tostring( roundTo( vec[1], 2 ) )
	
	for i=2, #vec do
		result = result .. "," .. tostring( roundTo( vec[i], 2 ) )
	end
	
	return result
end

function vecString( str )
	local result = {}
	local components = split( str, "," )

	for i=1, #components do
		result[i] = tonumber( components[i] )
	end

	return result
end

function equalsVec( a, b )
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

function setCapture( src, dst )
	if src.mouseCaptured then dst.mouseCaptured = true end
	if src.keyboardCaptured then dst.keyboardCaptured = true end
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