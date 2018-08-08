#include "luainput.h"

namespace LuaInput
{
	static CoreData* g_coreData;

	void bind( lua_State* lua, CoreData* coreData )
	{
		// set global variables
		lua_newtable( lua );

		lua_pushnumber( lua, SDL_SCANCODE_LEFT );
		lua_setfield( lua, -2, "Left" );

		lua_pushnumber( lua, SDL_SCANCODE_RIGHT );
		lua_setfield( lua, -2, "Right" );

		lua_pushnumber( lua, SDL_SCANCODE_UP );
		lua_setfield( lua, -2, "Up" );

		lua_pushnumber( lua, SDL_SCANCODE_DOWN );
		lua_setfield( lua, -2, "Down" );

		lua_setglobal( lua, "Keys" );

		// register input metatable
		luaL_newmetatable( lua, "inputMeta" );
		luaL_Reg inputRegs[] =
		{
			{ "keyDown", keyDown },
			{ "keyPressed", keyPressed },
			{ "keyReleased", keyReleased },
			{ "keyRepeated", keyRepeated },

			{ "buttonDown", buttonDown },
			{ "buttonPressed", buttonPressed },
			{ "buttonReleased", buttonReleased },

			{ "getMousePosition", getMousePosition },
			{ "getMouseDelta", getMouseDelta },
			{ "getMouseWheel", getMouseWheel },
			{ "getTextInput", getTextInput },
			{ "getActive", getActive },

			{ NULL, NULL }
		};

		luaL_setfuncs( lua, inputRegs, 0 );
		lua_pushvalue( lua, -1 );
		lua_setfield( lua, -2, "__index" );
		lua_setglobal( lua, "Input" );

		g_coreData = coreData;
	}

	LDEC( keyDown )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) )
			{
				int key = lua_toint( lua, 1 );
				bool down = g_coreData->input->keyDown( key );
				lua_pushboolean( lua, down );
				result = 1;
			}
		}

		return result;
	}

	LDEC( keyPressed )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) )
			{
				int key = lua_toint( lua, 1 );
				bool pressed = g_coreData->input->keyPressed( key );
				lua_pushboolean( lua, pressed );
				result = 1;
			}
		}

		return result;
	}

	LDEC( keyReleased )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) )
			{
				int key = lua_toint( lua, 1 );
				bool released = g_coreData->input->keyReleased( key );
				lua_pushboolean( lua, released );
				result = 1;
			}
		}

		return result;
	}

	LDEC( keyRepeated )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) )
			{
				int key = lua_toint( lua, 1 );
				bool repeated = g_coreData->input->keyRepeated( key );
				lua_pushboolean( lua, repeated );
				result = 1;
			}
		}

		return result;
	}

	LDEC( buttonDown )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) )
			{
				int key = lua_toint( lua, 1 );
				bool down = g_coreData->input->buttonDown( key );
				lua_pushboolean( lua, down );
				result = 1;
			}
		}

		return result;
	}

	LDEC( buttonPressed )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) )
			{
				int key = lua_toint( lua, 1 );
				bool pressed = g_coreData->input->buttonPressed( key );
				lua_pushboolean( lua, pressed );
				result = 1;
			}
		}

		return result;
	}

	LDEC( buttonReleased )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) )
			{
				int key = lua_toint( lua, 1 );
				bool released = g_coreData->input->buttonReleased( key );
				lua_pushboolean( lua, released );
				result = 1;
			}
		}

		return result;
	}

	LDEC( getMousePosition )
	{
		Point position = g_coreData->input->getMouseDelta();
		glm::vec2 value( position.x, position.y );

		lua_newtable( lua );
		lua_setvec2( lua, value );

		return 1;
	}

	LDEC( getMouseDelta )
	{
		Point delta = g_coreData->input->getMouseDelta();
		glm::vec2 value( delta.x, delta.y );

		lua_newtable( lua );
		lua_setvec2( lua, value );

		return 1;
	}

	LDEC( getMouseWheel )
	{
		int wheel = g_coreData->input->getMouseWheel();

		lua_pushnumber( lua, wheel );
		
		return 1;
	}

	LDEC( getTextInput )
	{
		const char* input = g_coreData->input->getTextInput();

		lua_pushstring( lua, input );

		return 1;
	}

	LDEC( getActive )
	{
		bool active = g_coreData->input->getActive();

		lua_pushboolean( lua, active );

		return 1;
	}
}