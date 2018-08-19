MODE_TRANSLATE = 1
MODE_SCALE = 2
MODE_ROTATE = 3

Editor =
{
	name = "Editor",
	
	gui = nil,	
	entities = {},
	selectedEntity = nil,
	selectedEntityIndex = -1,
	hoveredEntity = nil,
	
	gizmo = nil,
	console = nil,
	grid = nil,
	commandHistory = nil,

	mode = MODE_TRANSLATE,
	command = { old = {}, new = {} },
}

function Editor:load()
	self.camera = doscript( "editor/editor_camera.lua" )
	self.camera:load()
	
	self.gui = doscript( "editor/editor_gui.lua" )
	self.gui:load()
	self.gui.menu.file.onNew = function() self:reset() end
	self.gui.menu.file.onOpen = function() self:openLevel() end
	self.gui.menu.file.onSave = function() self:saveLevel() end
	self.gui.menu.file.onSaveAs = function() self:saveAsLevel() end
	self.gui.menu.file.onCompile = function() self:compileLevel() end
	self.gui.menu.file.onExit = function() Core.exit() end
	self.gui.menu.settings.onShowGrid = function() self.grid.showGrid = not self.grid.showGrid end
	self.gui.menu.settings.onShowOrigo = function() self.grid.showOrigo = not self.grid.showOrigo end
	
	self.gizmo = doscript( "editor/editor_gizmo.lua" )
	self.gizmo:load()
	self.gizmo:setPosition( Vec3.create() )
	
	self.console = doscript( "editor/editor_console.lua" )
	self.console:load()
	
	self.grid = doscript( "editor/editor_grid.lua" )

	self.commandHistory = doscript( "editor/editor_command_history.lua" )
	self.commandHistory:load()
	
	doscript( "editor/entity.lua" )

	-- gui component list
	self.gui.componentList.onClick = function( button )
		local component = button.tag

		if self.selectedEntity then
			local newComponent = component.create( self.selectedEntity )
			self.selectedEntity:addComponent( newComponent )
			self.gui.panel.tabs.info:setEntity( self.selectedEntity )
		end
	end
	
	-- gui context menu
	self.gui.contextMenu:addItem( "New Entity", { index = 1 } )
	self.gui.contextMenu.onClick = function( button )
		if button.tag.index == 1 then
			local ray = self.camera.camera:createRay()
			local plane = Physics.createPlane( {0,1,0}, 0 )
			
			local hit = {}
			if Physics.rayPlane( ray, plane, hit ) then
				hit.position[2] = 0
				self:createEntity( hit.position )
			end
		end
	end
	
	-- gui info panel
	self.gui.panel.tabs.info.visibleCheckbox.onCheck = function( checkbox )
		if self.selectedEntity then
			self.selectedEntity.visible = checkbox.checked
		end
	end

	self.gui.panel.tabs.info.nameTextbox.onFinish = function( self )
		if self.text:len() > 0 then
			Editor.selectedEntity.name = self.text
		end
	end
	
	self.gui.panel.tabs.info.positionTextbox.onFinish = function( textbox )
		if textbox.text:len() > 0 then
			local components = split( textbox.text, "," )
			
			local x = tonumber( components[1] )
			local y = tonumber( components[2] )
			local z = tonumber( components[3] )

			copyVec( self.selectedEntity.position, self.command.old)
			copyVec( {x,y,z}, self.command.new )

			local moveCommand = CommandMove.create( self.command.old, self.command.new, self.selectedEntity )
			self.commandHistory:addCommand( moveCommand )
			
			self.selectedEntity.position = {x,y,z}
			self.gizmo:setPosition( self.selectedEntity.position )
		end
	end

	self.gui.panel.tabs.info.orientationTextbox.onFinish = function( textbox )
		if textbox.text:len() > 0 then
			local components = split( textbox.text, "," )

			local x = tonumber( components[1] )
			local y = tonumber( components[2] )
			local z = tonumber( components[3] )
			local w = tonumber( components[4] )

			copyVec( self.selectedEntity.orientation, self.command.old )
			copyVec( {x,y,z,w}, self.command.new )

			local rotateCommand = CommandRotate.create( self.command.old, self.command.new, self.selectedEntity )
			self.commandHistory:addCommand( rotateCommand )

			self.selectedEntity.orientation = {x,y,z,w}
			self.gizmo:setOrientation( self.selectedEntity.orientation )
		end
	end

	self.gui.panel.tabs.info.scaleTextbox.onFinish = function( textbox )
		if textbox.text:len() > 0 then
			local components = split( textbox.text, "," )

			local x = tonumber( components[1] )
			local y = tonumber( components[2] )
			local z = tonumber( components[3] )

			copyVec( self.selectedEntity.scale, self.command.old )
			copyVec( {x,y,z}, self.command.new )

			local scaleCommand = CommandScale.create( self.command.old, self.command.new, self.selectedEntity )
			self.commandHistory:addCommand( scaleCommand )

			self.selectedEntity.scale = {x,y,z}
			self.gizmo:setScale( self.selectedEntity.scale )
		end
	end
end

function Editor:unload()
end

function Editor:update( deltaTime )
	local capture = { mouseCaptured = false, keyboardCaptured = false }

	local captureResult = self.camera:update( deltaTime )
	setCapture( captureResult, capture )

	self.gizmo:update( deltaTime )

	captureResult = self.console:update( deltaTime )
	setCapture( captureResult, capture )
	
	captureResult = self.gui:update( deltaTime )
	setCapture( captureResult, capture )

	if not capture.mouseCaptured then
		-- context menu
		if Input.buttonReleased( Buttons.Right ) then
			local mousePosition = Input.getMousePosition()
			self.gui.contextMenu:show( mousePosition )
		end

		-- hovering and selecting entities
		if self.hoveredEntity then
			self.hoveredEntity.hovered = false
		end

		local ray = self.camera.camera:createRay()
		if not self.xcaptured and not self.ycaptured and not self.zcaptured then
			self.hoveredEntity = self:findEntity( ray )

			if self.hoveredEntity then
				self.hoveredEntity.hovered = true
			end

			if Input.buttonReleased( Buttons.Left ) then
				if self.selectedEntity then
					self.selectedEntity.selected = false
				end

				self.selectedEntity = self.hoveredEntity
				self.gui.panel.tabs.info:setEntity( self.selectedEntity )

				if self.selectedEntity then
					self.selectedEntity.selected = true
					self.gizmo:setPosition( self.selectedEntity.position )
					self.gizmo.visible = true
					self.gizmo.selectedAxis = -1
				else
					self.gizmo.visible = false
				end
			end
		end
		
		-- manipulating entities
		if self.selectedEntity then
			local entityMoved = false
			local entityOriented = false
			local entityScaled = false
			
			if Input.buttonPressed( Buttons.Left ) then
				self.xcaptured = false
				self.ycaptured = false
				self.zcaptured = false
			
				-- translation in x-axis
				if Physics.rayAABB( ray, self.gizmo.xbounds ) then
					self.xcaptured = true
					
					self.xplane = Physics.createPlane( {0,0,1}, self.selectedEntity.position[3] )
					
					local hit = {}
					if Physics.rayPlane( ray, self.xplane, hit ) then
						self.xoffset = hit.position[1] - self.selectedEntity.position[1]
						self.xscale = hit.position[1] - self.selectedEntity.scale[1]
						self.gizmo.selectedAxis = 1

						if self.mode == MODE_TRANSLATE then
							copyVec( self.selectedEntity.position, self.command.old )
						elseif self.mode == MODE_ROTATE then
						elseif self.mode == MODE_SCALE then
							copyVec( self.selectedEntity.scale, self.command.old )
						end
					end
				-- translation in y-axis
				elseif Physics.rayAABB( ray, self.gizmo.ybounds ) then
					self.ycaptured = true
					
					local forward = self.camera.camera:getForward()
					local xnormal = {1,0,0}
					local znormal = {0,0,1}
					
					local xdot = Vec3.dot( xnormal, forward )
					local zdot = Vec3.dot( znormal, forward )
					
					if xdot < zdot then
						self.yplane = Physics.createPlane( xnormal, self.selectedEntity.position[1] )
					else
						self.yplane = Physics.createPlane( znormal, self.selectedEntity.position[3] )
					end
					
					local hit = {}
					if Physics.rayPlane( ray, self.yplane, hit ) then
						self.yoffset = hit.position[2] - self.selectedEntity.position[2]
						self.yscale = hit.position[2] - self.selectedEntity.scale[2]
						self.gizmo.selectedAxis = 2

						if self.mode == MODE_TRANSLATE then
							copyVec( self.selectedEntity.position, self.command.old )
						elseif self.mode == MODE_ROTATE then
						elseif self.mode == MODE_SCALE then
							copyVec( self.selectedEntity.scale, self.command.old )
						end
					end
				-- translation in z-axis
				elseif Physics.rayAABB( ray, self.gizmo.zbounds ) then
					self.zcaptured = true
					
					self.zplane = Physics.createPlane( {1,0,0}, self.selectedEntity.position[1] )
					
					local hit = {}
					if Physics.rayPlane( ray, self.zplane, hit ) then
						self.zoffset = hit.position[3] - self.selectedEntity.position[3]
						self.zscale = hit.position[3] - self.selectedEntity.scale[3]
						self.gizmo.selectedAxis = 3

						if self.mode == MODE_TRANSLATE then
							copyVec( self.selectedEntity.position, self.command.old )
						elseif self.mode == MODE_ROTATE then
						elseif self.mode == MODE_SCALE then
							copyVec( self.selectedEntity.scale, self.command.old )
						end
					end
				end
			elseif Input.buttonDown( Buttons.Left ) then
				local snap = Input.keyDown( Keys.LeftControl )
				
				if self.xcaptured and self.xplane then
					local hit = {}
					if Physics.rayPlane( ray, self.xplane, hit ) then
						if self.mode == MODE_TRANSLATE then
							self.selectedEntity.position[1] = hit.position[1] - self.xoffset
							
							if snap then
								self.selectedEntity.position[1] = math.floor( self.selectedEntity.position[1] + 0.5 )
							end
							
							entityMoved = true
						elseif self.mode == MODE_ROTATE then
						elseif self.mode == MODE_SCALE then
							self.selectedEntity.scale[1] = hit.position[1] - self.xscale

							if snap then
								self.selectedEntity.scale[1] = math.floor( self.selectedEntity.scale[1] + 0.5 )
							end

							entityScaled = true
						end
					end
				elseif self.ycaptured and self.yplane then
					local hit = {}
					if Physics.rayPlane( ray, self.yplane, hit ) then
						if self.mode == MODE_TRANSLATE then
							self.selectedEntity.position[2] = hit.position[2] - self.yoffset
							
							if snap then
								self.selectedEntity.position[2] = math.floor( self.selectedEntity.position[2] + 0.5 )
							end
							
							entityMoved = true
						elseif self.mode == MODE_ROTATE then
						elseif self.mode == MODE_SCALE then
							self.selectedEntity.scale[2] = hit.position[2] - self.yscale

							if snap then
								self.selectedEntity.scale[2] = math.floor( self.selectedEntity.scale[2] + 0.5 )
							end

							entityScaled = true
						end
					end
				elseif self.zcaptured and self.zplane then
					local hit = {}
					if Physics.rayPlane( ray, self.zplane, hit ) then
						if self.mode == MODE_TRANSLATE then
							self.selectedEntity.position[3] = hit.position[3] - self.zoffset
							
							if snap then
								self.selectedEntity.position[3] = math.floor( self.selectedEntity.position[3] + 0.5 )
							end
							
							entityMoved = true
						elseif self.mode == MODE_ROTATE then
						elseif self.mode == MODE_SCALE then
							self.selectedEntity.scale[3] = hit.position[3] - self.zscale

							if snap then
								self.selectedEntity.scale[3] = math.floor( self.selectedEntity.scale[3] + 0.5 )
							end

							entityScaled = true
						end
					end
				end
			elseif Input.buttonReleased( Buttons.Left ) then
				if self.xcaptured or self.ycaptured or self.zcaptured then
					if self.mode == MODE_TRANSLATE then
						copyVec( self.selectedEntity.position, self.command.new )

						local moveCommand = CommandMove.create( self.command.old, self.command.new, self.selectedEntity )
						self.commandHistory:addCommand( moveCommand )
					elseif self.mode == MODE_ROTATE then
					elseif self.mode == MODE_SCALE then
						copyVec( self.selectedEntity.scale, self.command.new )

						local scaleCommand = CommandScale.create( self.command.old, self.command.new, self.selectedEntity )
						self.commandHistory:addCommand( scaleCommand )
					end
				end
			else
				self.gizmo.selectedAxis = -1
			end
			
			-- update gizmo if entity was moved
			if entityMoved then
				self.gizmo:setPosition( self.selectedEntity.position )
				self.gui.panel.tabs.info:refresh()
			elseif entityOriented then
			elseif entityScaled then
				self.gizmo:setScale( self.selectedEntity.scale )
				self.gui.panel.tabs.info:refresh()
			end
		end
	end
	
	if not capture.keyboardCaptured then
		-- copy current entity
		if self.selectedEntity then
			if Input.keyReleased( Keys.D ) and Input.keyDown( Keys.LeftControl ) then
				local entity = self:copyEntity()

				local command = CommandCopyEntity.create( self, entity )
				self.commandHistory:addCommand( command )
			end
		end

		-- remove current entity
		if self.selectedEntity then
			if Input.keyReleased( Keys.Delete ) then
				--self:removeEntity( self.selectedEntity )

				local command = CommandRemoveEntity.create( self, self.selectedEntity )
				self.commandHistory:addCommand( command )

				self:removeEntity( self.selectedEntity )
			end
		end

		-- undo/redo
		if Input.keyDown( Keys.LeftControl ) then
			local undoRedo = false
			if Input.keyRepeated( Keys.Z ) then
				self.commandHistory:undo()
				undoRedo = true
			elseif Input.keyRepeated( Keys.Y ) then
				self.commandHistory:redo()
				undoRedo = true
			end

			if self.selectedEntity and undoRedo then
				self.gizmo:setPosition( self.selectedEntity.position )
				self.gui.panel.tabs.info:refresh()
			end
		end

		-- select mode
		if Input.keyPressed( Keys.W ) then
			self.mode = MODE_TRANSLATE
		elseif Input.keyPressed( Keys.E ) then
			self.mode = MODE_SCALE
		elseif Input.keyPressed( Keys.R ) then
			self.mode = MODE_ROTATE
		end
	end
	
	-- entities
	for _,v in pairs(self.entities) do
		v:update( deltaTime )
	end
end

function Editor:render()
	self.gui:render()
	self.gizmo:render()
	self.console:render()
	self.grid:render()
	
	-- entities
	for _,v in pairs(self.entities) do
		v:render()
	end
end

function Editor:findEntity( ray )
	local closestEntity = nil
	local closestDistance = 999999
	for _,v in pairs(self.entities) do
		local distance = v:select( ray )
		if distance > 0 then
			if distance < closestDistance then
				closestDistance = distance
				closestEntity = v
			end
		end
	end

	return closestEntity
end

function Editor:selectEntity( entity )
	if self.selectedEntity then
		self.selectedEntity.selected = false
	end

	self.gui.panel.tabs.info:setEntity( entity )
	self.selectedEntity = entity
	entity.selected = true
	
	self.gizmo:setPosition( Editor.selectedEntity.position )
	self.gizmo.visible = true
	self.gizmo.selectedAxis = -1
end

function Editor.onEntitySelected( button )
	local entity = button.tag
	
	if Editor.selectedEntity ~= entity then
		Editor:selectEntity( entity )
	end
end

function Editor:copyEntity()
	local position = self.selectedEntity.position
	local entity = Entity.create( "NewEntity", {position[1]+1, position[2], position[3]+1} )
	
	for _,v in pairs(self.selectedEntity.components) do
		local component = v:copy( entity )
		entity:addComponent( component )
	end
	
	self.entities[#self.entities+1] = entity
	
	self.gui.panel.tabs.entities:addEntity( entity, self.onEntitySelected )

	self:selectEntity( entity )

	return entity
end

function Editor:createEntity( position )
	local entity = Entity.create( "NewEntity", position )
	self.entities[#self.entities+1] = entity
	
	self.gui.panel.tabs.entities:addEntity( entity, self.onEntitySelected )

	self:selectEntity( entity )
end

function Editor:addEntity( entity )
	self.entities[#self.entities+1] = entity

	self:selectEntity( entity )
end

function Editor:removeEntity( entity )
	local index = 0
	for i=1, #self.entities do
		if self.entities[i] == entity then
			index = i
			break
		end
	end

	if index > 0 then
		self.selectedEntity = nil
		self.gui.panel.tabs.info:setEntity( self.selectedEntity )
		self.gizmo.visible = false
		self.gui.panel.tabs.entities:removeEntity( entity )

		self.entities[index] = nil
	end
end

function Editor:reset()
	local count = #self.entities
	for i=1, count do self.entities[i] = nil end

	self.selectedEntity = nil
	self.gizmo.visible = false

	self.gui.panel.tabs.entities:clear()
end

function Editor:openLevel()
	self:reset()

	local filepath = Filesystem.openFileDialog()
	if filepath and filepath:len() > 0 then
		local chunk, error = loadfile( filepath )
		if chunk then
			local status, value = pcall(chunk)
			if status then
				self.entities = value

				for _,v in pairs(self.entities) do
					self.gui.panel.tabs.entities:addEntity( v, self.onEntitySelected )
				end
			else
				Log.error( "Failed to load entities:" )
				Log.error( value )
			end
		else
			Log.error( "Failed to load level:" )
			Log.error( error )
		end
	end
end

function Editor:saveLevel()
	if self.currentLevelPath then
		local file = io.open( self.currentLevelPath, "w" )
		if file then
			writeIndent( file, 0, "local entities = {}\n\n" )

			for _,v in pairs(self.entities) do
				v:write( file )
			end

			writeIndent( file, 0, "return entities\n" )

			file:close()
		end
	else
		self:saveAsLevel()
	end
end

function Editor:saveAsLevel()
	local filepath = Filesystem.saveFileDialog()
	if filepath and filepath:len() > 0 then
		self.currentLevelPath = filepath

		self:saveLevel()
	end
end

function Editor:compileLevel()
	local filepath = Filesystem.saveFileDialog()
	if filepath and filepath:len() > 0 then
		local file = io.open( filepath, "w" )
		if file then
			for _,v in pairs(self.entities) do
				v:compile( file )
			end

			file:close()
		end
	end
end