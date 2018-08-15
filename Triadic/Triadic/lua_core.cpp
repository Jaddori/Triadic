#include "lua_core.h"

namespace LuaCore
{
	static CoreData* g_coreData;

	void bind( lua_State* lua, CoreData* coreData )
	{
		luaL_newmetatable( lua, "coreMeta" );
		luaL_Reg assetsRegs[] =
		{
			{ "exit", exit },

			{ NULL, NULL }
		};

		luaL_setfuncs( lua, assetsRegs, 0 );
		lua_pushvalue( lua, -1 );
		lua_setfield( lua, -2, "__index" );
		lua_setglobal( lua, "Core" );

		g_coreData = coreData;
	}

	int exit( lua_State* lua )
	{
		*g_coreData->running = false;
		return 0;
	}
}