Entity = 
{
	components = {},
}

function Entity.create( position )
	local result =
	{
		position = position
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