Entity = 
{
	visible = true,
	name = "",
	components = {},
	selected = false,
	
	position = {0,0,0},
	prevPosition = {0,0,0},
	
	orientation = {0,0,0,1},
	prevOrientation = {0,0,0,1},
	
	scale = {1,1,1},
	prevScale = {1,1,1},

	componentList = {},
	infoList = {},
}

function Entity.create( name, position, orientation, scale)
	local result =
	{
		position = position or {0,0,0},
		prevPosition = {0,0,0},
		
		orientation = orientation or {0,0,0,1},
		prevOrientation = {0,0,0,1},
		
		scale = scale or {1,1,1},
		prevScale = {1,1,1},
	
		visible = true,
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

function Entity:write( file, level )
	level = level or 0

	--writeIndent( file, level, self.name .. " =\n" )
	writeIndent( file, level, "{\n")
	level = level + 1

	writeIndent( file, level, "position = {" .. stringVec(self.position) .. "},\n" )
	writeIndent( file, level, "orientation = {" .. stringVec(self.orientation) .. "},\n" )
	writeIndent( file, level, "scale = {" .. stringVec(self.scale) .. "},\n" )

	writeIndent( file, level, "components =\n" )
	writeIndent( file, level, "{\n" )
	level = level + 1

	for _,v in pairs(self.components) do
		v:write( file, level )
	end

	level = level - 1
	writeIndent( file, level, "}\n" )
	
	level = level - 1
	writeIndent( file, level, "}\n" )
end

function Entity:read( file )
	
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
	if self.visible then
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
end

local componentScripts = Filesystem.getFiles( "./assets/scripts/editor/components/*" )
for _,v in pairs(componentScripts) do
	local component, info = doscript( "editor/components/" .. v )

	Entity.componentList[#Entity.componentList+1] = component
	Entity.infoList[#Entity.infoList+1] = info

	Editor.gui.componentList:addItem( component.name, component )
end