#include "lua_core.h"

namespace LuaCore
{
	static CoreData* g_coreData;

	void bind( lua_State* lua, CoreData* coreData )
	{
		luaL_newmetatable( lua, "coreMeta" );
		luaL_Reg assetsRegs[] =
		{
			{ "getTicks", getTicks },
			{ "exit", exit },

			{ NULL, NULL }
		};

		luaL_setfuncs( lua, assetsRegs, 0 );
		lua_pushvalue( lua, -1 );
		lua_setfield( lua, -2, "__index" );
		lua_setglobal( lua, "Core" );

		g_coreData = coreData;
	}

	LDEC( getTicks )
	{
		uint32_t ticks = SDL_GetTicks();
		lua_pushnumber( lua, ticks );
		return 1;
	}

	LDEC( exit )
	{
		*g_coreData->running = false;
		return 0;
	}
}