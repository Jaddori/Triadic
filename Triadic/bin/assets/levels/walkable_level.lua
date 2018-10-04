-- Floor
Props:add( {-10,0,0}, {0,0,0,1}, {4,1,2}, "floor.mesh" )

-- Wall_BottomRight
local boundingBox =
{
	minPosition = {9.5,0,-10},
	maxPosition = {10,10,10}
}
BoundingBoxes:addAABB( boundingBox )

Props:add( {15,0,0}, {0,0,0,1}, {1,1,2}, "wall.mesh" )

-- Wall_TopRight
local boundingBox =
{
	minPosition = {-30,0,-10},
	maxPosition = {10,10,-9.5}
}
BoundingBoxes:addAABB( boundingBox )

Props:add( {-10,0,-15}, {0,0.71,0,0.71}, {1,1,4}, "wall.mesh" )

-- Wall_TopLeft
local boundingBox =
{
	minPosition = {-30,0,-10},
	maxPosition = {-29.5,10,10}
}
BoundingBoxes:addAABB( boundingBox )

Props:add( {-35,0,0}, {0,1,0,0}, {1,1,2}, "wall.mesh" )

-- Wall_BottomLeft
local boundingBox =
{
	minPosition = {-30,0,9.5},
	maxPosition = {10,10,10}
}
BoundingBoxes:addAABB( boundingBox )

Props:add( {-10,0,15}, {0,0.71,0,-0.71}, {1,1,4}, "wall.mesh" )

-- Light
local light =
{
	position = {4.21,4.83,-6.95},
	offset = {0,0,0},
	color = {0.6,1,1},
	intensity = 4,
	linear = 1,
	constant = 1,
	exponent = 1,
	size = 1
}
Lights:addPointLight( light )

-- SunLight
local light =
{
	direction = {-1,-1,-1},
	color = {1,0.7,0.7},
	intensity = 0.1
}
Lights:addDirectionalLight( light )

-- Light2
local light =
{
	position = {-15.12,5.9,4.42},
	offset = {0,0,0},
	color = {0.6,1,1},
	intensity = 4,
	linear = 1,
	constant = 1,
	exponent = 1,
	size = 1
}
--Lights:addPointLight( light )

-- Pillar
local boundingBox =
{
	minPosition = {-16.46,0,3.35},
	maxPosition = {-14.46,4,5.35}
}
BoundingBoxes:addAABB( boundingBox )

Props:add( {-15.46,0,4.35}, {0,0,0,1}, {1,1,1}, "pillar05.mesh" )

-- WalkableSurface

