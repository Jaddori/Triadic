GUI_CONTEXT_MENU_WIDTH = 128
GUI_CONTEXT_MENU_DEPTH = 0.7

local menu =
{
	textureIndex = -1,
	position = {0,0},
	size = {GUI_CONTEXT_MENU_WIDTH,0},
	depth = GUI_CONTEXT_MENU_DEPTH,
	color = {0.5, 0.5, 0.5, 1.0},
	visible = false,
	
	items = {},

	onClick = nil,
}

function menu:load()
end

function menu:addItem( text, tag )
	local count = #self.items
	
	local button = EditorButton.create( {0, count*GUI_BUTTON_HEIGHT}, {self.size[1], GUI_BUTTON_HEIGHT}, text )
	button:setDepth( self.depth + GUI_DEPTH_SMALL_INC )
	button.tag = tag
	button.onClick = function( button )
		if self.onClick then
			self.onClick( button )
		end
	end
	
	self.items[count+1] = button
	self.size[2] = #self.items * GUI_BUTTON_HEIGHT
	
	return button
end

function menu:show( position )
	self.position[1] = position[1]
	self.position[2] = position[2]
	self.visible = true
	
	for i=1, #self.items do
		self.items[i].position[1] = self.position[1]
		self.items[i].position[2] = self.position[2] + (i-1) * GUI_BUTTON_HEIGHT
	end
end

function menu:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	for _,v in pairs(self.items) do
		local result = v:update( deltaTime )
		setCapture( result, capture )
	end
	
	if Input.buttonReleased( Buttons.Left ) then
		self.visible = false
	end
	
	return capture
end

function menu:render()
	for _,v in pairs(self.items) do
		v:render()
	end
end

return menu