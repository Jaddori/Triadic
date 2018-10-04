Particles =
{
	emitters = {}
}

function Particles:addEmitter( emitter )
	self.emitters[#self.emitters+1] = emitter
end

function Particles:render()
	for _,v in pairs(self.emitters) do
	end
end