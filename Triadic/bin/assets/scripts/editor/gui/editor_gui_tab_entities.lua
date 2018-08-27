local ent = 
{
	items = {},
	position = {0,0},
	size = {0,0},
	depth = 0,

	onSelect = nil,
}

function ent:load( position, size, depth )
	copyVec( position, self.position )
	copyVec( size, self.size )
	self.depth = depth + GUI_DEPTH_INC
end

function ent:onShow()
	for _,v in pairs(self.items) do
		v.text = v.tag.name
	end
end

function ent:addEntity( entity )
	local padding = 4
	local yoffset = #self.items * (GUI_BUTTON_HEIGHT + padding)

	local button = EditorButton.create( {self.position[1] + padding, self.position[2] + padding + yoffset}, {self.size[1] - padding*2, GUI_BUTTON_HEIGHT}, entity.name )
	button.depth = self.depth + GUI_DEPTH_SMALL_INC
	button.tag = entity
	button.onClick = self.onSelect
	
	self.items[#self.items+1] = button
end

function ent:removeEntity( entity )
	local index = 0
	for i=1, #self.items do
		if self.items[i].tag == entity then
			index = i
			break
		end
	end

	if index > 0 then
		self.items[index] = nil
	end
end

function ent:clear()
	local count = #self.items
	for i=1, count do
		self.items[i] = nil
	end
end

function ent:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCaptured = false }
	
	for _,v in pairs(self.items) do
		local result = v:update( deltaTime )
		setCapture( result, capture )
	end
	
	return capture
end

function ent:render()
	for _,v in pairs(self.items) do
		v:render()
	end
end

return ent