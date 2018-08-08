#pragma once

#include "common.h"
#include "coredata.h"

#include "luarendering.h"
#include "luainput.h"
#include "luaassets.h"
#include "luatransform.h"
#include "luasysteminfo.h"
#include "luacamera.h"
#include "lualog.h"
#include "luashapes.h"

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