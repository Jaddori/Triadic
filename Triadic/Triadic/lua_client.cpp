#include "lua_client.h"
using namespace Network;

namespace LuaClient
{
	static CoreData* g_coreData;

	void bind( lua_State* lua, CoreData* coreData )
	{
		luaL_newmetatable( lua, "clientMeta" );
		luaL_Reg clientRegs[] = 
		{
			{ "getMessages", getMessages },
			//{ "getConnected", getConnected },
			//{ "getNetworkID", getNetworkID },

			{ "queueInt", queueInt },
			{ "queueUint", queueUint },
			{ "queueFloat", queueFloat },
			{ "queueString", queueString },

			{ NULL, NULL }
		};

		luaL_setfuncs( lua, clientRegs, 0 );
		lua_pushvalue( lua, -1 );
		lua_setfield( lua, -2, "__index" );
		lua_setglobal( lua, "Client" );

		g_coreData = coreData;
	}

	LDEC( getMessages )
	{
		lua_newtable( lua );

		Array<Message>& messages = g_coreData->client->getMessages();
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

	/*LDEC( getConnected )
	{
		lua_pushboolean( lua, g_coreData->client->getConnected() );
		return 1;
	}

	LDEC( getNetworkID )
	{
		lua_pushnumber( lua, g_coreData->client->getNetworkID() );
		return 1;
	}*/

	LDEC( queueInt )
	{
		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) )
			{
				int value = lua_toint( lua, 1 );

				g_coreData->client->queue( value );
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

				g_coreData->client->queue( value );
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

				g_coreData->client->queue( value );
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

				g_coreData->client->queue( text, len );
			}
		}

		return 0;
	}
}