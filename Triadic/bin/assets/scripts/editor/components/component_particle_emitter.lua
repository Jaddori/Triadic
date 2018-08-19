local DEFAULT_TEXTURE = "./assets/textures/white.dds"
local DEFAULT_PARTICLE_TEXTURE = "./assets/textures/cloud.dds"
local DEFAULT_PARTICLE_MASK = "./assets/textures/mask.dds"

ComponentParticleEmitter =
{
	name = "Particle Emitter",
	textureIndex = -1,
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

ComponentParticleEmitterInfo =
{
	name = "Particle Emitter",
	position = {0,0},
	size = {0,0},
	expanded = true,
	textureIndex = -1,
	color = { 0.35, 0.35, 0.35, 1.0 },
	titleButton = nil,
	entity = nil,
	component = nil,
	curInfo = nil,
	items = {},
}

function ComponentParticleEmitter.create( parent )
	if ComponentParticleEmitter.textureIndex < 0 then
		ComponentParticleEmitter.textureIndex = Assets.loadTexture( DEFAULT_PARTICLE_TEXTURE )
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

function ComponentParticleEmitter:write( file, level )
	local componentName = self.parent.name .. "_component"

	writeIndent( file, level, "local " .. componentName .. " = ComponentParticleEmitter.create( " .. self.parent.name .. " )\n" )

	writeIndent( file, level, componentName .. ".maxParticles = " .. tostring( self.maxParticles ) .. "\n" )
	writeIndent( file, level, componentName .. ".spherical = " .. tostring( self.spherical ) .. "\n" )
	writeIndent( file, level, componentName .. ".minFrequency = " .. tostring( self.minFrequency ) .. "\n" )
	writeIndent( file, level, componentName .. ".maxFrequency = " .. tostring( self.maxFrequency ) .. "\n" )
	writeIndent( file, level, componentName .. ".minLifetime = " .. tostring( self.minLifetime ) .. "\n" )
	writeIndent( file, level, componentName .. ".maxLifetime = " .. tostring( self.maxLifetime ) .. "\n" )
	writeIndent( file, level, componentName .. ".minDirection = {" .. stringVec( self.minDirection ) .. "}\n" )
	writeIndent( file, level, componentName .. ".maxDirection = {" .. stringVec( self.maxDirection ) .. "}\n" )
	writeIndent( file, level, componentName .. ".startSpeed = " .. tostring( self.startSpeed ) .. "\n" )
	writeIndent( file, level, componentName .. ".endSpeed = " .. tostring( self.endSpeed ) .. "\n" )
	writeIndent( file, level, componentName .. ".startSize = " .. tostring( self.startSize ) .. "\n" )
	writeIndent( file, level, componentName .. ".endSize = " .. tostring( self.endSize ) .. "\n" )

	writeIndent( file, level, self.parent.name .. ":addComponent( " .. componentName .. " )\n" )
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
			Graphics.queueBillboard( self.textureIndex, self.maskIndex, v.position, {v.size,v.size}, {0,0,1,1}, self.spherical, v.scroll )
		end
	end
end

function ComponentParticleEmitter:addInfo( position, size, items )
	local info =
	{
		name = "Particle Emitter",
		position = {0,0},
		size = {0,0},
		items = {},
	}

	setmetatable( info, { __index = ComponentParticleEmitterInfo } )

	local padding = 4
	local inset = 8
	local xoffset = position[1] + padding
	local yoffset = position[2]

	-- add title button
	info.titleButton = EditorButton.create( {xoffset, yoffset}, {size[1]-padding*2, 24}, "Particle Emitter:" )
	info.titleButton.tag = info
	yoffset = yoffset + 24

	info.titleButton.onClick = function( button )
		info.expanded = not info.expanded
	end

	-- set position
	info.position[1] = position[1] + padding
	info.position[2] = yoffset
	info.size[1] = size[1] - padding * 2

	-- add sub items
	local maxParticlesInput = EditorInputbox.create( {xoffset+padding, yoffset}, info.size[1]-padding*2, "Max particles:" )
	maxParticlesInput.textbox:setText( tostring( self.maxParticles ) )
	maxParticlesInput.textbox.onFinish = function( textbox )
		self.maxParticles = tonumber( textbox.text )

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
	yoffset = yoffset + maxParticlesInput.size[2]

	local frequencyInput = EditorInputbox.create( {xoffset+padding, yoffset}, info.size[1]-padding*2, "Frequency:" )
	frequencyInput.textbox:setText( tostring( self.minFrequency ) .. " : " .. tostring( self.maxFrequency ) )
	frequencyInput.textbox.onFinish = function( textbox )
		local components = split( textbox.text, ":" )
		
		self.minFrequency = tonumber( components[1] )
		self.maxFrequency = tonumber( components[2] )
		self.curFrequency = lerp( self.minFrequency, self.maxFrequency, math.random() )
	end
	yoffset = yoffset + frequencyInput.size[2]

	local lifetimeInput = EditorInputbox.create( {xoffset+padding, yoffset}, info.size[1]-padding*2, "Lifetime:" )
	lifetimeInput.textbox:setText( tostring( self.minLifetime ) .. " : " .. tostring( self.maxLifetime ) )
	lifetimeInput.textbox.onFinish = function( textbox )
		local components = split( textbox.text, ":" )

		self.minLifetime = tonumber( components[1] )
		self.maxLifetime = tonumber( components[2] )
	end
	yoffset = yoffset + lifetimeInput.size[2]

	local directionInput = EditorInputbox.create( {xoffset+padding, yoffset}, info.size[1]-padding*2, "Direction:" )
	directionInput.textbox:setText( stringVec( self.minDirection ) .. " : " .. stringVec( self.maxDirection ) )
	directionInput.textbox.onFinish = function( textbox )
		local words = split( textbox.text, ":" )

		local components = split( words[1], "," )

		local x = tonumber( components[1] )
		local y = tonumber( components[2] )
		local z = tonumber( components[3] )

		self.minDirection = {x,y,z}

		components = split( words[2], "," )

		x = tonumber( components[1] )
		y = tonumber( components[2] )
		z = tonumber( components[3] )

		self.maxDirection = {x,y,z}
	end
	yoffset = yoffset + directionInput.size[2]

	local speedInput = EditorInputbox.create( {xoffset+padding, yoffset}, info.size[1]-padding*2, "Speed:" )
	speedInput.textbox:setText( tostring( self.startSpeed ) .. " : " .. tostring( self.endSpeed ) )
	speedInput.textbox.onFinish = function( textbox )
		local components = split( textbox.text, ":" )

		self.startSpeed = tonumber( components[1] )
		self.endSpeed = tonumber( components[2] )
	end
	yoffset = yoffset + speedInput.size[2]

	local sizeInput = EditorInputbox.create( {xoffset+padding, yoffset}, info.size[1]-padding*2, "Size:" )
	sizeInput.textbox:setText( tostring( self.startSize ) .. " : " .. tostring( self.endSize ) )
	sizeInput.textbox.onFinish = function( textbox )
		local components = split( textbox.text, ":" )

		self.startSize = tonumber( components[1] )
		self.endSize = tonumber( components[2] )
	end
	yoffset = yoffset + sizeInput.size[2]

	local sphericalLabel = EditorLabel.create( {xoffset+padding, yoffset}, "Spherical:" )
	yoffset = yoffset + sphericalLabel:getHeight() + padding

	local sphericalCheckbox = EditorCheckbox.create( {xoffset+padding, yoffset} )
	sphericalCheckbox.checked = self.spherical
	sphericalCheckbox.onCheck = function( checkbox )
		self.spherical = checkbox.checked
	end
	--yoffset = yoffset + sphericalCheckbox.size[2] + padding
	yoffset = yoffset + padding

	info.items[#info.items+1] = maxParticlesInput
	info.items[#info.items+1] = frequencyInput
	info.items[#info.items+1] = lifetimeInput
	info.items[#info.items+1] = directionInput
	info.items[#info.items+1] = speedInput
	info.items[#info.items+2] = sizeInput
	info.items[#info.items+1] = sphericalLabel
	info.items[#info.items+1] = sphericalCheckbox

	-- set size
	info.size[2] = yoffset - position[2]
	ComponentParticleEmitter.entity = self.parent
	ComponentParticleEmitter.component = self
	ComponentParticleEmitter.curInfo = info

	-- add to callers list of items
	items[#items+1] = info

	return info.size[2]
end

-- INFO
function ComponentParticleEmitterInfo:load()
	ComponentParticleEmitterInfo.textureIndex = Assets.loadTexture( DEFAULT_TEXTURE )
end

function ComponentParticleEmitterInfo:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	local result = self.titleButton:update( deltaTime )
	setCapture( result, capture )

	if self.expanded then
		-- update items
		for _,v in pairs(self.items) do
			result = v:update( deltaTime )
			setCapture( result, capture )
		end
	end

	return capture
end

function ComponentParticleEmitterInfo:render()
	self.titleButton:render()

	if self.expanded then
		-- render background
		Graphics.queueQuad( self.textureIndex, self.position, self.size, self.color )

		-- render items
		for _,v in pairs(self.items) do
			v:render()
		end
	end
end

ComponentParticleEmitterInfo:load()

return ComponentParticleEmitter, ComponentParticleEmitterInfo