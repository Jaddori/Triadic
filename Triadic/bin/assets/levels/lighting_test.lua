local entities = {}

-- floor
local floor = Entity.create( "floor", {0,0,0}, {0,0,0,1}, {10,1,10} )
floor.visible = true
local floor_component = ComponentMesh.create( floor )
floor_component:loadMesh( "plane.mesh" )
floor:addComponent( floor_component )
local floor_component = nil
entities[#entities+1] = floor
-- floor

-- pillar1
local pillar1 = Entity.create( "pillar1", {-2.62,0,0.1}, {0,0,0,1}, {1,1,1} )
pillar1.visible = true
local pillar1_component = ComponentMesh.create( pillar1 )
pillar1_component:loadMesh( "pillar.mesh" )
pillar1:addComponent( pillar1_component )
local pillar1_component = nil
entities[#entities+1] = pillar1
-- pillar1

-- NewEntity
local NewEntity = Entity.create( "NewEntity", {8.61,0,13.35}, {0,0,0,1}, {1,1,1} )
NewEntity.visible = true
local NewEntity_component = ComponentMesh.create( NewEntity )
NewEntity_component:loadMesh( "pillar.mesh" )
NewEntity:addComponent( NewEntity_component )
local NewEntity_component = nil
entities[#entities+1] = NewEntity
-- NewEntity

return entities
