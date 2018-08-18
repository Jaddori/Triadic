local DEFAULT_BACKGROUND_TEXTURE = "./assets/textures/white.dds"
local DEFAULT_CHECK_TEXTURE = "./assets/textures/check02.dds"
local DEFAULT_SIZE = 18

EditorCheckbox = 
{
	backgroundTextureIndex = -1,
	checkTextureIndex = -1,
	position = {0,0},
	size = {DEFAULT_SIZE, DEFAULT_SIZE},
	checkColor = {1,1,1,1},
	color = {0.5, 0.5, 0.5, 1.0},
	hoverColor = {0.75, 0.75, 0.75, 1.0},
	pressColor = {0.35, 0.35, 0.35, 1.0},

	hovered = false,
	pressed = false,
	checked = false,

	onCheck = nil,
}

function EditorCheckbox.create( position, size )
	if EditorCheckbox.backgroundTextureIndex < 0 then
		EditorCheckbox.backgroundTextureIndex = Assets.loadTexture( DEFAULT_BACKGROUND_TEXTURE )
	end

	if EditorCheckbox.checkTextureIndex < 0 then
		EditorCheckbox.checkTextureIndex = Assets.loadTexture( DEFAULT_CHECK_TEXTURE )
	end

	local checkbox =
	{
		position = position,
		size = size,
		hovered = false,
		pressed = false,
		checked = false,
	}
	setmetatable( checkbox, { __index = EditorCheckbox } )

	return checkbox
end

function EditorCheckbox:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	local mousePosition = Input.getMousePosition()

	if insideRect( self.position, self.size, mousePosition ) then
		self.hovered = true

		if Input.buttonDown( Buttons.Left ) then
			self.pressed = true
		else
			if self.pressed then
				self.checked = not self.checked

				if self.onCheck then
					self:onCheck()
				end
			end

			self.pressed = false
		end

		capture.mouseCaptured = true
	else
		self.hovered = false
		self.pressed = false
	end

	return capture
end

function EditorCheckbox:render()
	local color = self.color
	if self.pressed then
		color = self.pressColor
	elseif self.hovered then
		color = self.hoverColor
	end

	-- draw background
	Graphics.queueQuad( self.backgroundTextureIndex, self.position, self.size, color )

	-- draw check
	if self.checked then
		Graphics.queueQuad( self.checkTextureIndex, self.position, self.size, self.checkColor )
	end
end