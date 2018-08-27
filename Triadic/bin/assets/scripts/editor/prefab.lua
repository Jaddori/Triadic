Prefab =
{
	name = "Prefab",
	components = {},
}

Prefabs = {}

function Prefab.create( name, entity )
	assert( name, "Prefab must have a name." )
	assert( name:len() > 0, "Prefab name must not be empty." )
	assert( entity, "Prefab must be created with a template entity." )
	assert( entity.components, "Template entity must have components." )
	assert( Prefabs[name] == nil, "Prefab name must be unique" )

	local result =
	{
		name = name,
		components = {},
	}

	for k,v in pairs(entity.components) do
		result.components[k] = v:copy()
	end

	setmetatable( result, { __index = Prefab } )

	Prefabs[name] = result

	return result
end

function Prefab:instantiate( position )
	local entity = Entity.create( self.name, position )

	for _,v in pairs(self.components) do
		local component = v:copy( entity )
		entity:addComponent( component )
	end

	return entity
end