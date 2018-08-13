Entity = 
{
	name = "",
	components = {},
	selected = false,
}

function Entity.create( position, name )
	local result =
	{
		position = position,
		name = name,
		selected = false,
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

function Entity:update( deltaTime )
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