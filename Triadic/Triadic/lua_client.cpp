#include "lua_client.h"

namespace LuaClient
{
	static CoreData* g_coreData;

	void bind( lua_State* lua, CoreData* coreData )
	{
		luaL_newmetatable( lua, "clientMeta" );
		luaL_Reg clientRegs[] = 
		{
			{ "beginRead", beginRead },
			{ "endRead", endRead },
			{ "getMessage", getMessage },

			{ NULL, NULL }
		};

		luaL_setfuncs( lua, clientRegs, 0 );
		lua_pushvalue( lua, -1 );
		lua_setfield( lua, -2, "__index" );
		lua_setglobal( lua, "Client" );

		g_coreData = coreData;
	}

	LDEC( beginRead )
	{
		int count = g_coreData->client->beginRead();
		lua_pushnumber( lua, count );

		return 1;
	}

	LDEC( endRead )
	{
		g_coreData->client->endRead();
		return 0;
	}

	LDEC( getMessage )
	{
		int result = 0;

		Network::Message* message = g_coreData->client->getMessage();
		if( message )
		{
			lua_newtable( lua );
			lua_pushlightuserdata( lua, message );
			lua_setfield( lua, -2, "__self" );
			luaL_setmetatable( lua, "messageMeta" );

			result = 1;
		}

		return result;
	}
}