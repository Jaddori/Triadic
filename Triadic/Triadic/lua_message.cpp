#include "lua_message.h"
using namespace Network;

namespace LuaMessage
{
	void bind( lua_State* lua )
	{
		luaL_newmetatable( lua, "messageMeta" );
		luaL_Reg serverRegs[] = 
		{
			{ "clear", clear },

			{ "writeChar", writeChar },
			{ "writeBool", writeBool },
			{ "writeInt", writeInt },
			{ "writeFloat", writeFloat },
			{ "writeString", writeString },

			{ "readChar", readChar },
			{ "readBool", readBool },
			{ "readInt", readInt },
			{ "readFloat", readFloat },
			{ "readString", readString },

			{ NULL, NULL }
		};

		luaL_setfuncs( lua, serverRegs, 0 );
		lua_pushvalue( lua, -1 );
		lua_setfield( lua, -2, "__index" );
		lua_setglobal( lua, "Message" );
	}

	LDEC( clear )
	{
		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_TABLE( 1 ) )
			{
				Message* message = lua_getuserdata<Message>( lua, 1 );
				message->clear();
			}
		}

		return 0;
	}

	LDEC( writeChar )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_STRING( 2 ) )
			{
				Message* message = lua_getuserdata<Message>( lua, 1 );
				const char* str = lua_tostring( lua, 2 );

				assert( strlen( str ) > 0 );

				message->write( str[0] );
			}
		}

		return 0;
	}

	LDEC( writeBool )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_BOOL( 2 ) )
			{
				Message* message = lua_getuserdata<Message>( lua, 1 );
				bool b = lua_tobool( lua, 2 );

				message->write( b );
			}
		}

		return 0;
	}

	LDEC( writeInt )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_NUMBER( 2 ) )
			{
				Message* message = lua_getuserdata<Message>( lua, 1 );
				int i = lua_toint( lua, 2 );

				message->write( i );
			}
		}

		return 0;
	}

	LDEC( writeFloat )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_NUMBER( 2 ) )
			{
				Message* message = lua_getuserdata<Message>( lua, 1 );
				float f = lua_tofloat( lua, 2 );

				message->write( f );
			}
		}

		return 0;
	}

	LDEC( writeString )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_STRING( 2 ) )
			{
				Message* message = lua_getuserdata<Message>( lua, 1 );
				const char* str = lua_tostring( lua, 2 );

				message->write( str, strlen( str ) );
			}
		}

		return 0;
	}

	LDEC( readChar )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_TABLE( 1 ) )
			{
				Message* message = lua_getuserdata<Message>( lua, 1 );
				char c[] = { message->read<char>(), 0 };

				lua_pushstring( lua, c );
				result = 1;
			}
		}

		return result;
	}

	LDEC( readBool )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_TABLE( 1 ) )
			{
				Message* message = lua_getuserdata<Message>( lua, 1 );
				bool b = message->read<bool>();

				lua_pushboolean( lua, b );
				result = 1;
			}
		}

		return result;
	}

	LDEC( readInt )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_TABLE( 1 ) )
			{
				Message* message = lua_getuserdata<Message>( lua, 1 );
				int i = message->read<int>();

				lua_pushnumber( lua, i );
				result = 1;
			}
		}

		return result;
	}

	LDEC( readFloat )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_TABLE( 1 ) )
			{
				Message* message = lua_getuserdata<Message>( lua, 1 );
				float f = message->read<float>();

				lua_pushnumber( lua, f );
				result = 1;
			}
		}

		return result;
	}

	LDEC( readString )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_TABLE( 1 ) )
			{
				Message* message = lua_getuserdata<Message>( lua, 1 );
				char text[MESSAGE_SIZE];
				int len = message->read( text, MESSAGE_SIZE );
				text[len] = 0;

				lua_pushstring( lua, text );
				result = 1;
			}
		}

		return result;
	}
}