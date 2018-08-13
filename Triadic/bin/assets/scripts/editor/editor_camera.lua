local camera = 
{
}

function camera:load()
	self.camera = Graphics.getPerspectiveCamera()
end

function camera:update( deltaTime )
	local result = false
	
	local mouseDelta = Input.getMouseDelta()
	
	if Input.buttonDown( Buttons.Middle ) then
		self.camera:updateDirection( mouseDelta )
		
		local movement = {0,0,0}
		if Input.keyDown( Keys.A ) then
			movement[1] = movement[1] - 1
		end

		if Input.keyDown( Keys.D ) then
			movement[1] = movement[1] + 1
		end

		if Input.keyDown( Keys.S ) then
			movement[3] = movement[3] - 1
		end

		if Input.keyDown( Keys.W ) then
			movement[3] = movement[3] + 1
		end

		self.camera:relativeMovement( movement )
		
		result = true
	end
	
	return result
end

return camera