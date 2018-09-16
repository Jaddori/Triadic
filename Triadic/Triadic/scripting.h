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
#include "lua_math.h"
#include "lua_core.h"
#include "lua_message.h"
#include "lua_client.h"
#include "lua_server.h"

namespace Scripting
{
	class Script
	{
	public:
		Script();
		~Script();

		bool bind( CoreData* coreData, bool isServer );
		void update( float deltaTime );

		inline void load() { run( loadFunctionReference, "mainLoad" ); }
		inline void unload() { run( unloadFunctionReference, "mainUnload" ); }
		inline void render() { run( renderFunctionReference, "mainRender" ); }
		inline void clientWrite() { run( clientWriteFunctionReference, "mainClientWrite" ); }
		inline void serverWrite() { run( serverWriteFunctionReference, "mainServerWrite" ); }

		void setGlobal( const char* name, bool value );
		void setGlobal( const char* name, int value );
		void setGlobal( const char* name, float value );
		void setGlobal( const char* name, const char* value );

	private:
		void run( int functionReference, const char* debugName );
		void reload();

		lua_State* lua;

		int loadFunctionReference, unloadFunctionReference;
		int updateFunctionReference, renderFunctionReference;
		int clientWriteFunctionReference, serverWriteFunctionReference;
		bool valid, isServer;

		CoreData* _coreData;
	};
}