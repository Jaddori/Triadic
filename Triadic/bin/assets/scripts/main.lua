local scripts = {}

function run( func, ... )
	for k,v in pairs(scripts) do
		if v[func] then
			v[func]( v, ... )
		end
	end
end

function mainLoad()
	doscript( "utils.lua" )
	doscript( "debug/info.lua" )
	doscript( "debug/axis_gizmo.lua" )
	doscript( "game.lua" )
	
	run( "load" )
end

function mainUnload()
	run( "unload" )
end

function mainUpdate( deltaTime )
	run( "update", deltaTime )
end

function mainRender()
	run( "render" )
end

function addScript( script )
	scripts[script.name] = script
end

function doscript( name )
	return dofile( "./assets/scripts/" .. name )
end