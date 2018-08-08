#include "lua_systeminfo.h"

namespace LuaSystemInfo
{
	static CoreData* g_coreData;

	void bind( lua_State* lua, CoreData* coreData )
	{
		luaL_newmetatable( lua, "systemInfoMeta" );
		luaL_Reg systemInfoRegs[] =
		{
			{ "getCores", getCores },
			{ "getThreads", getThreads },
			{ "getRam", getRam },
			{ "getVsync", getVsync },
			{ "getUpdateMs", getUpdateMs },
			{ "getRenderMs", getRenderMs },
			{ "getDeltaTime", getDeltaTime },

			{ NULL, NULL }
		};

		luaL_setfuncs( lua, systemInfoRegs, 0 );
		lua_pushvalue( lua, -1 );
		lua_setfield( lua, -2, "__index" );
		lua_setglobal( lua, "SystemInfo" );

		g_coreData = coreData;
	}

	LDEC( getCores )
	{
		int cores = g_coreData->systemInfo->getCores();
		lua_pushnumber( lua, cores );
		return 1;
	}

	LDEC( getThreads )
	{
		int threads = g_coreData->systemInfo->getThreads();
		lua_pushnumber( lua, threads );
		return 1;
	}
	
	LDEC( getRam )
	{
		int ram = g_coreData->systemInfo->getRam();
		lua_pushnumber( lua, ram );
		return 1;
	}

	LDEC( getVsync )
	{
		bool vsync = g_coreData->systemInfo->getVsync();
		lua_pushboolean( lua, vsync );
		return 1;
	}

	LDEC( getUpdateMs )
	{
		int ms = g_coreData->systemInfo->getUpdateMs();
		lua_pushnumber( lua, ms );
		return 1;
	}

	LDEC( getRenderMs )
	{
		int ms = g_coreData->systemInfo->getRenderMs();
		lua_pushnumber( lua, ms );
		return 1;
	}

	LDEC( getDeltaTime )
	{
		float deltaTime = g_coreData->systemInfo->getDeltaTime();
		lua_pushnumber( lua, deltaTime );
		return 1;
	}
}