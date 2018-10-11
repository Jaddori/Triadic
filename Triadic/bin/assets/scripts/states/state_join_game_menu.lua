require( "./assets/scripts/states/state_menu" )

StateJoinGameMenu = StateMenu.create( "JoinGameMenu" )

function StateJoinGameMenu:load()
	self.titleLabel = EditorLabel.create( Vec2.create(), Vec2.create({WINDOW_WIDTH, 128}), "Triadic" )
	self.titleLabel:loadFont( "./assets/fonts/verdana18.bin", "./assets/fonts/verdana18.dds" )
	self.titleLabel:setTextAlignment( ALIGN_MIDDLE, ALIGN_MIDDLE )

	self.ipInput = EditorInputbox.create( Vec2.create({32,128}), 256, "IP:" )
	self.ipInput.textbox:setText( "127.0.0.1" )

	self.connectButton = EditorButton.create( Vec2.create({32+256-128, 128+self.ipInput.size[2]+8}), Vec2.create({128,32}), "Connect" )
	self.connectButton.onClick = function( button )
		doscript( "states/state_gameplay.lua" )
		StateGameplay:load()
		Game:setState( "Gameplay" )
	end

	self.backButton = EditorButton.create( Vec2.create({32,256+32}), Vec2.create({128,24}), "Back" )
	self.backButton.onClick = function( button )
		Game:popState()
	end

	self:addControl( self.titleLabel )
	self:addControl( self.ipInput )
	self:addControl( self.connectButton )
	self:addControl( self.backButton )
end

Game:addState( StateJoinGameMenu )