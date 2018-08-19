local entities = {}
-- NewEntity
local NewEntity = Entity.create( "NewEntity", {17.03,0,22.31}, {0,0,0,1}, {1,1,1} )
local NewEntity_component = ComponentMesh.create( NewEntity )
NewEntity_component:loadMesh( "./assets/models/arrow.mesh" )
NewEntity:addComponent( NewEntity_component )
local NewEntity_component = nil
entities[#entities+1] = NewEntity-- NewEntity

-- NewEntity
local NewEntity = Entity.create( "NewEntity", {27.36,0,14.06}, {0,0,0,1}, {1,1,1} )
local NewEntity_component = ComponentMesh.create( NewEntity )
NewEntity_component:loadMesh( "./assets/models/pillar.mesh" )
NewEntity:addComponent( NewEntity_component )
local NewEntity_component = nil
entities[#entities+1] = NewEntity-- NewEntity

-- NewEntity
local NewEntity = Entity.create( "NewEntity", {35.53,0,26.73}, {0,0,0,1}, {1,1,1} )
local NewEntity_component = ComponentParticleEmitter.create( NewEntity )
NewEntity_component.spherical = true
NewEntity_component.minFrequency = 0.1
NewEntity_component.maxFrequency = 0.5
NewEntity_component.minLifetime = 1.5
NewEntity_component.maxLifetime = 2.5
NewEntity_component.minDirection = {-1,-1,-1}
NewEntity_component.maxDirection = {1,1,1}
NewEntity_component.startSpeed = 1
NewEntity_component.endSpeed = 0.1
NewEntity_component.startSize = 5
NewEntity_component.endSize = 4
NewEntity:addComponent( NewEntity_component )
local NewEntity_component = nil
entities[#entities+1] = NewEntity-- NewEntity

-- NewEntity
local NewEntity = Entity.create( "NewEntity", {24.08,0,37.38}, {0,0,0,1}, {1,1,1} )
local NewEntity_component = ComponentWalkable.create( NewEntity )
NewEntity_component.size = {20,20}
NewEntity_component.interval = 1
NewEntity:addComponent( NewEntity_component )
local NewEntity_component = nil
entities[#entities+1] = NewEntity-- NewEntity

return entities
