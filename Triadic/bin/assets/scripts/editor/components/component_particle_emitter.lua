local DEFAULT_PARTICLE_TEXTURE = "./assets/textures/cloud.dds"
local DEFAULT_PARTICLE_NORMAL = "./assets/textures/normal.dds"
local DEFAULT_PARTICLE_SPECULAR = "./assets/textures/specular.dds"
local DEFAULT_PARTICLE_MASK = "./assets/textures/mask.dds"

ComponentParticleEmitter =
{
	name = "Particle Emitter",
	textureIndex = -1,
	normalIndex = -1,
	specularIndex = -1,
	maskIndex = -1,

	particles = {},
	parent = nil,
	spherical = true,
	maxParticles = 1,
	minFrequency = 0.1,
	maxFrequency = 0.5,
	curFrequency = 0.1,
	elapsedTime = 0.0,
	minLifetime = 1.5,
	maxLifetime = 2.5,
	--velocity = {1,1,1},
	minDirection = {-1,-1,-1},
	maxDirection = {1,1,1},
	startSpeed = 1.0,
	endSpeed = 0.1,
	scroll = {0,0,0},
	startSize = 5,
	endSize = 4,
}

ComponentParticleEmitterWindow =
{
	window = {},
	component = {},
}

function ComponentParticleEmitter.create( parent )
	if ComponentParticleEmitter.textureIndex < 0 then
		ComponentParticleEmitter.textureIndex = Assets.loadTexture( DEFAULT_PARTICLE_TEXTURE )
		ComponentParticleEmitter.normalIndex = Assets.loadTexture( DEFAULT_PARTICLE_NORMAL )
		ComponentParticleEmitter.specularIndex = Assets.loadTexture( DEFAULT_PARTICLE_SPECULAR )
		ComponentParticleEmitter.maskIndex = Assets.loadTexture( DEFAULT_PARTICLE_MASK )
	end

	local result =
	{
		parent = parent,
		particles = {},
		spherical = true,
		minDirection = {-1,-1,-1},
		maxDirection = {1,1,1},
	}

	setmetatable( result, { __index = ComponentParticleEmitter } )

	result.curFrequency = lerp( result.minFrequency, result.maxFrequency, math.random() )

	for i=1, ComponentParticleEmitter.maxParticles do
		result.particles[i] = 
		{
			alive = false,
			position = {0,0,0},
			velocity = {0,1,0},
			lifetime = 0,
			elapsed = 0,
			size = 0,
		}
	end

	return result
end

function ComponentParticleEmitter:write( file, level, prefabName )
	local location = ""

	if self.parent then -- entity
		location = self.parent.name .. "_component"

		writeIndent( file, level, "local " .. location .. " = ComponentParticleEmitter.create( " .. self.parent.name .. " )\n" )
	else -- prefab
		location = "Prefabs[\"" .. prefabName .. "\"].components[\"" .. self.name .. "\"]"
		writeIndent( file, level, location .. " = ComponentParticleEmitter.create()\n" )
	end

	writeIndent( file, level, location .. ":setMaxParticles( " .. tostring( self.maxParticles ) .. " )\n" )
	writeIndent( file, level, location .. ".spherical = " .. tostring( self.spherical ) .. "\n" )
	writeIndent( file, level, location .. ".minFrequency = " .. tostring( self.minFrequency ) .. "\n" )
	writeIndent( file, level, location .. ".maxFrequency = " .. tostring( self.maxFrequency ) .. "\n" )
	writeIndent( file, level, location .. ".minLifetime = " .. tostring( self.minLifetime ) .. "\n" )
	writeIndent( file, level, location .. ".maxLifetime = " .. tostring( self.maxLifetime ) .. "\n" )
	writeIndent( file, level, location .. ".minDirection = {" .. stringVec( self.minDirection ) .. "}\n" )
	writeIndent( file, level, location .. ".maxDirection = {" .. stringVec( self.maxDirection ) .. "}\n" )
	writeIndent( file, level, location .. ".startSpeed = " .. tostring( self.startSpeed ) .. "\n" )
	writeIndent( file, level, location .. ".endSpeed = " .. tostring( self.endSpeed ) .. "\n" )
	writeIndent( file, level, location .. ".startSize = " .. tostring( self.startSize ) .. "\n" )
	writeIndent( file, level, location .. ".endSize = " .. tostring( self.endSize ) .. "\n" )

	if self.parent then
		writeIndent( file, level, self.parent.name .. ":addComponent( " .. location .. " )\n" )
	end
end

function ComponentParticleEmitter:read( file )
end

function ComponentParticleEmitter:compile( file, level )
end

function ComponentParticleEmitter:copy( parent )
	local result = self.create( parent )

	result.textureIndex = self.textureIndex
	result.spherical = self.spherical

	return result
end

function ComponentParticleEmitter:select( ray )
	return -1
end

function ComponentParticleEmitter:setMaxParticles( amount )
	self.maxParticles = amount

	local count = #self.particles
	if count < self.maxParticles then
		for i=count+1, self.maxParticles do
			self.particles[i] = 
			{
				alive = false,
				size = {1,1},
				position = {0,0,0},
			}
		end
	elseif count > self.maxParticles then
		for i=self.maxParticles+1, count do
			self.particles[i] = nil
		end
	end
end

function ComponentParticleEmitter:update( deltaTime )
	self.elapsedTime = self.elapsedTime + deltaTime

	-- spawn new particles
	if self.elapsedTime >= self.curFrequency then
		self.elapsedTime = self.elapsedTime - self.curFrequency
		self.curFrequency = lerp( self.minFrequency, self.maxFrequency, math.random() )

		for _,v in pairs(self.particles) do
			if not v.alive then
				v.alive = true
				copyVec( self.parent.position, v.position )
				v.direction = 
				{
					lerp( self.minDirection[1], self.maxDirection[1], math.random() ),
					lerp( self.minDirection[2], self.maxDirection[2], math.random() ),
					lerp( self.minDirection[3], self.maxDirection[3], math.random() ),
				}
				v.lifetime = lerp( self.minLifetime, self.maxLifetime, math.random() )
				v.elapsed = 0
				v.scroll = 
				{
					math.random(),
					math.random(),
					lerp( 0.25, 0.5, math.random() )
				}

				if math.random() < 0.5 then
					v.scroll[3] = -v.scroll[3]
				end

				break
			end
		end
	end

	-- update particles
	for _,v in pairs(self.particles) do
		if v.alive then
			v.elapsed = v.elapsed + deltaTime
			if v.elapsed >= v.lifetime then
				v.alive = false
			else
				local speed = easeOutCubic( v.elapsed, self.startSpeed, self.endSpeed - self.startSpeed, v.lifetime )

				v.position[1] = v.position[1] + v.direction[1] * speed * deltaTime
				v.position[2] = v.position[2] + v.direction[2] * speed * deltaTime
				v.position[3] = v.position[3] + v.direction[3] * speed * deltaTime

				v.size = easeOutCubic( v.elapsed, self.startSize, self.endSize - self.startSize, v.lifetime )
			end
		end
	end
end

function ComponentParticleEmitter:render()
	for _,v in pairs(self.particles) do
		if v.alive then
			Graphics.queueBillboard( self.textureIndex, self.normalIndex, self.specularIndex, self.maskIndex, v.position, {v.size,v.size}, {0,0,1,1}, self.spherical, v.scroll )
		end
	end

	return true
end

function ComponentParticleEmitter:showInfoWindow()
	if ComponentParticleEmitterWindow.window.visible then
		ComponentParticleEmitterWindow:hide()
	else
		ComponentParticleEmitterWindow:show( self )
	end
end

-- WINDOW
function ComponentParticleEmitterWindow:show( component )
	self.component = component
	self.window.visible = true
	self.window.focused = true
	if self.window.onFocus then self.window:onFocus() end

	-- update items
	self.window.items[1].textbox:setText( component.maxParticles )
	self.window.items[2].textbox:setText( component.minFrequency )
	self.window.items[3].textbox:setText( component.maxFrequency )
	self.window.items[4].textbox:setText( component.minLifetime )
	self.window.items[5].textbox:setText( component.maxLifetime )
	self.window.items[6].textbox:setText( stringVec( component.minDirection ) )
	self.window.items[7].textbox:setText( stringVec( component.maxDirection ) )
	self.window.items[8].textbox:setText( component.startSpeed )
	self.window.items[9].textbox:setText( component.endSpeed )
	self.window.items[10].textbox:setText( component.startSize )
	self.window.items[11].textbox:setText( component.endSize )
	self.window.items[13].checked = component.spherical
end

function ComponentParticleEmitterWindow:hide()
	self.window.visible = false
end

function ComponentParticleEmitterWindow:refresh( entity )
	if self.window.visible then
		if entity.components[ComponentParticleEmitter.name] then
			self:show( entity.components[ComponentParticleEmitter.name] )
		else
			self.window.visible = false
		end
	end
end

function ComponentParticleEmitterWindow:load()
	self.window = EditorWindow.create( "Particle Emitter Component" )
	self.window.position[1] = WINDOW_WIDTH - GUI_PANEL_WIDTH - self.window.size[1] - 8
	self.window.position[2] = GUI_MENU_HEIGHT + 8
	self.window.visible = false
	
	-- max particles
	local maxParticles = EditorInputbox.create( nil, nil, "Max particles:" )
	maxParticles.textbox.onFinish = function( textbox )
		self.component:setMaxParticles( tonumber( textbox.text ) )
	end
	self.window:addItem( maxParticles )

	-- frequency
	local minFrequency = EditorInputbox.create( nil, nil, "Min. frequency:" )
	minFrequency.textbox.onFinish = function( textbox )
		self.component.minFrequency = tonumber( textbox.text )
	end
	self.window:addItem( minFrequency )

	local maxFrequency = EditorInputbox.create( nil, nil, "Max. frequency:" )
	maxFrequency.textbox.onFinish = function( textbox )
		self.component.maxFrequency = tonumber( textbox.text )
	end
	self.window:addItem( maxFrequency )

	-- lifetime
	local minLifetime = EditorInputbox.create( nil, nil, "Min. lifetime:" )
	minLifetime.textbox.onFinish = function( textbox )
		self.component.minLifetime = tonumber( textbox.text )
	end
	self.window:addItem( minLifetime )

	local maxLifetime = EditorInputbox.create( nil, nil, "Max. lifetime:" )
	maxLifetime.textbox.onFinish = function( textbox )
		self.component.maxLifetime = tonumber( textbox.text )
	end
	self.window:addItem( maxLifetime )

	-- direction
	local minDirection = EditorInputbox.create( nil, nil, "Min. direction:" )
	minDirection.textbox.onFinish = function( textbox )
		self.component.minDirection = vecString( textbox.text )
	end
	self.window:addItem( minDirection )

	local maxDirection = EditorInputbox.create( nil, nil, "Max. direction:" )
	maxDirection.textbox.onFinish = function( textbox )
		self.component.maxDirection = vecString( textbox.text )
	end
	self.window:addItem( maxDirection )

	-- speed
	local startSpeed = EditorInputbox.create( nil, nil, "Start speed:" )
	startSpeed.textbox.onFinish = function( textbox )
		self.component.startSpeed = tonumber( textbox.text )
	end
	self.window:addItem( startSpeed )

	local endSpeed = EditorInputbox.create( nil, nil, "End speed:" )
	endSpeed.textbox.onFinish = function( textbox )
		self.component.endSpeed = tonumber( textbox.text )
	end
	self.window:addItem( endSpeed )

	-- size
	local startSize = EditorInputbox.create( nil, nil, "Start size:" )
	startSize.textbox.onFinish = function( textbox )
		self.component.startSize = tonumber( textbox.text )
	end
	self.window:addItem( startSize )

	local endSize = EditorInputbox.create( nil, nil, "End size:" )
	endSize.textbox.onFinish = function( textbox )
		self.component.endSize = tonumber( textbox.text )
	end
	self.window:addItem( endSize )

	-- spherical
	local sphericalLabel = EditorLabel.create( {0,0}, {0, GUI_BUTTON_HEIGHT}, "Spherical:" )
	self.window:addItem( sphericalLabel )

	local sphericalCheckbox = EditorCheckbox.create()
	sphericalCheckbox.onCheck = function( checkbox )
		self.component.spherical = checkbox.checked
	end
	self.window:addItem( sphericalCheckbox )
end

function ComponentParticleEmitterWindow:update( deltaTime )
	return self.window:update( deltaTime )
end

function ComponentParticleEmitterWindow:render()
	self.window:render()
end

ComponentParticleEmitterWindow:load()

return ComponentParticleEmitter, ComponentParticleEmitterWindow