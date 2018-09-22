#include "lua_server.h"
using namespace Network;

namespace LuaServer
{
	static CoreData* g_coreData;

	void bind( lua_State* lua, CoreData* coreData )
	{
		luaL_newmetatable( lua, "serverMeta" );
		luaL_Reg serverRegs[] = 
		{
			{ "beginRead", beginRead },
			{ "endRead", endRead },
			{ "getMessage", getMessage },

			{ "queueInt", queueInt },
			{ "queueUint", queueUint },
			{ "queueFloat", queueFloat },
			{ "queueString", queueString },

			{ NULL, NULL }
		};

		luaL_setfuncs( lua, serverRegs, 0 );
		lua_pushvalue( lua, -1 );
		lua_setfield( lua, -2, "__index" );
		lua_setglobal( lua, "Server" );

		g_coreData = coreData;
	}

	LDEC( beginRead )
	{
		int count = g_coreData->server->beginRead();
		lua_pushnumber( lua, count );

		return 1;
	}

	LDEC( endRead )
	{
		g_coreData->server->endRead();
		return 0;
	}

	LDEC( getMessage )
	{
		int result = 0;

		Message* message = g_coreData->server->getMessage();
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

	LDEC( queueInt )
	{
		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) )
			{
				int value = lua_toint( lua, 1 );

				g_coreData->server->queue( value );
			}
		}

		return 0;
	}

	LDEC( queueUint )
	{
		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) )
			{
				uint32_t value = (uint32_t)lua_tonumber( lua, 1 );

				g_coreData->server->queue( value );
			}
		}

		return 0;
	}

	LDEC( queueFloat )
	{
		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) )
			{
				float value = lua_tofloat( lua, 1 );

				g_coreData->server->queue( value );
			}
		}

		return 0;
	}

	LDEC( queueString )
	{
		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_STRING( 1 ) )
			{
				const char* text = lua_tostring( lua, 1 );
				int len = strlen( text );
				
				g_coreData->server->queue( text, len );
			}
		}

		return 0;
	}
}