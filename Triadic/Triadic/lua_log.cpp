#include "lua_log.h"

namespace LuaLog
{
	static CoreData* g_coreData;

	void bind( lua_State* lua, CoreData* coreData )
	{
		luaL_newmetatable( lua, "logMeta" );
		luaL_Reg logRegs[] =
		{
			{ "logInfo", logInfo },
			{ "logWarning", logWarning },
			{ "logError", logError },
			{ "logDebug", logDebug },

			{ NULL, NULL }
		};

		luaL_setfuncs( lua, logRegs, 0 );
		lua_pushvalue( lua, -1 );
		lua_setfield( lua, -2, "__index" );
		lua_setglobal( lua, "Log" );

		g_coreData = coreData;
	}

	int log( lua_State* lua, int verbosity )
	{
		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_STRING( 1 ) )
			{
				const char* text = lua_tostring( lua, 1 );

				Log::instance().addMessage( verbosity, text );
			}
		}

		return 0;
	}

	LDEC( logInfo )
	{
		return log( lua, VERBOSITY_INFORMATION );
	}

	LDEC( logWarning )
	{
		return log( lua, VERBOSITY_WARNING );
	}

	LDEC( logError )
	{
		return log( lua, VERBOSITY_ERROR);
	}

	LDEC( logDebug )
	{
		return log( lua, VERBOSITY_DEBUG);
	}
	
	LDEC( getMessages )
	{
		Array<LogMessage> messages;
		Log::instance().copyMessages( messages );

		lua_newtable( lua );
		lua_newtable( lua );
		
		const int MESSAGE_COUNT = messages.getSize();
		for( int i=0; i<MESSAGE_COUNT; i++ )
		{
			lua_pushstring( lua, messages[i].message );
			lua_rawseti( lua, -3, i+1 );

			lua_pushnumber( lua, messages[i].verbosity );
			lua_rawseti( lua, -2, i+1 );
		}

		return 2;
	}
}