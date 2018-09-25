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
			{ "getMessages", getMessages },
			{ "getNetworkID", getNetworkID },

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

	LDEC( getMessages )
	{
		lua_newtable( lua );

		Array<Message>& messages = g_coreData->server->getMessages();
		const int MESSAGE_COUNT = messages.getSize();
		for( int i=0; i<MESSAGE_COUNT; i++ )
		{
			lua_newtable( lua );
			lua_pushlightuserdata( lua, &messages[i] );
			lua_setfield( lua, -2, "__self" );
			luaL_setmetatable( lua, "messageMeta" );

			lua_rawseti( lua, -2, i+1 );
		}

		return 1;
	}

	LDEC( getNetworkID )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) )
			{
				uint32_t hash = lua_touint( lua, 1 );

				uint32_t networkID = g_coreData->server->getNetworkID( hash );

				lua_pushnumber( lua, networkID );
				result = 1;
			}
		}

		return result;
	}

	LDEC( queueInt )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) &&
				LUA_EXPECT_NUMBER( 2 ) )
			{
				uint32_t hash = lua_touint( lua, 1 );
				int value = lua_toint( lua, 2 );

				g_coreData->server->queue( hash, value );
			}
		}

		return 0;
	}

	LDEC( queueUint )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) &&
				LUA_EXPECT_NUMBER( 2 ) )
			{
				uint32_t hash = lua_touint( lua, 1 );
				uint32_t value = lua_touint( lua, 2 );

				g_coreData->server->queue( hash, value );
			}
		}

		return 0;
	}

	LDEC( queueFloat )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) &&
				LUA_EXPECT_NUMBER( 2 ) )
			{
				uint32_t hash = lua_touint( lua, 1 );
				float value = lua_tofloat( lua, 2 );

				g_coreData->server->queue( hash, value );
			}
		}

		return 0;
	}

	LDEC( queueString )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) &&
				LUA_EXPECT_STRING( 2 ) )
			{
				uint32_t hash = lua_touint( lua, 1 );
				const char* text = lua_tostring( lua, 2 );
				int len = strlen( text );
				
				g_coreData->server->queue( hash, text, len );
			}
		}

		return 0;
	}
}