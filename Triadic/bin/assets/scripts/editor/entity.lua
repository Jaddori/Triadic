Entity = 
{
	name = "",
	components = {},
	selected = false,
	
	position = {0,0,0},
	prevPosition = {0,0,0},
	
	orientation = {0,0,1,0},
	prevOrientation = {0,0,1,0},
	
	scale = {1,1,1},
	prevScale = {1,1,1},
}

function Entity.create( name, position, orientation, scale)
	local result =
	{
		position = position or {0,0,0},
		prevPosition = {0,0,0},
		
		orientation = orientation or {0,0,1,0},
		prevOrientation = {0,0,1,0},
		
		scale = scale or {1,1,1},
		prevScale = {1,1,1},
		
		name = name,
		selected = false,
		components = {},
	}
	
	setmetatable( result, { __index = Entity } )
	
	return result
end

function Entity:addComponent( component )
	if self.components[component.name] then
		Log.debug( "Entity already has a \"" .. component.name .. "\" component." )
	else
		self.components[component.name] = component
	end
end

function Entity:removeComponent( name )
	self.components[name] = nil
end

function Entity:select( ray )
	local result = false
	
	for _,v in pairs(self.components) do
		if v:select( ray ) then
			result = true
		end
	end
	
	if not result then
		local sphere = Physics.createSphere( self.position, 1.0 )
		result = Physics.raySphere( ray, sphere )
	end
	
	return result
end

function Entity:executeOnComponents( functionName )
	for _,v in pairs(self.components) do
		if v[functionName] then
			v[functionName]( v )
		end
	end
end

function Entity:update( deltaTime )
	-- check if position has changed
	--if self.position[1] ~= self.prevPosition[1] or
	--	self.position[2] ~=self.prevPosition[2] or
	--	self.position[3] ~= self.prevPosition[3] then
	--	
	--	for _,v in pairs(self.components) do
	--		if v.parentMoved then
	--			v:parentMoved()
	--		end
	--	end
	--	
	--	self.prevPosition[1] = self.position[1]
	--	self.prevPosition[2] = self.position[2]
	--	self.prevPosition[3] = self.position[3]
	--end
	
	-- check if position has changed
	if not equalsVec( self.position, self.prevPosition ) then
		self:executeOnComponents( "parentMoved" )
		copyVec( self.position, self.prevPosition )
	end
	
	-- check if orientation has changed
	if not equalsVec( self.orientation, self.prevOrientation ) then
		self:executeOnComponents( "parentOriented" )
		copyVec( self.orientation, self.prevOrientation )
	end
	
	-- check if scale has changed
	if not equalsVec( self.scale, self.prevScale ) then
		self:executeOnComponents( "parentScaled" )
		copyVec( self.scale, self.prevScale )
	end

	-- update components
	for _,v in pairs(self.components) do
		v:update( deltaTime )
	end
end

function Entity:render()
	local rendered = false
	
	for _,v in pairs(self.components) do
		if v:render() then
			rendered = true
		end
	end
	
	if not rendered then
		DebugShapes.addSphere( self.position, 1.0, { 0.0, 1.0, 0.0, 1.0 } )
	end
end

local componentScripts = Filesystem.getFiles( "./assets/scripts/editor/components/*" )
for _,v in pairs(componentScripts) do
	doscript( "editor/components/" .. v )
end