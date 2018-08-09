#pragma once

#include "common.h"
#include "core_data.h"

#include "lua_rendering.h"
#include "lua_input.h"
#include "lua_assets.h"
#include "lua_transform.h"
#include "lua_systeminfo.h"
#include "lua_camera.h"
#include "lua_log.h"
#include "lua_shapes.h"
#include "lua_filesystem.h"
#include "lua_physics.h"

namespace Scripting
{
	class Script
	{
	public:
		Script();
		~Script();

		bool bind( CoreData* coreData );
		void update( float deltaTime );

		inline void load() { run( loadFunctionReference, "mainLoad" ); }
		inline void unload() { run( unloadFunctionReference, "mainUnload" ); }
		inline void render() { run( renderFunctionReference, "mainRender" ); }

	private:
		void run( int functionReference, const char* debugName );

		lua_State* lua;

		int loadFunctionReference, unloadFunctionReference;
		int updateFunctionReference, renderFunctionReference;
		bool valid;
	};
}