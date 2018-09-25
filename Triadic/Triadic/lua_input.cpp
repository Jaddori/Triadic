#include "lua_input.h"

namespace LuaInput
{
	static CoreData* g_coreData;

	void bind( lua_State* lua, CoreData* coreData )
	{
		// set keys
		lua_newtable( lua );

		lua_setnumber( lua, "Zero", SDL_SCANCODE_0 );
		lua_setnumber( lua, "One", SDL_SCANCODE_1 );
		lua_setnumber( lua, "Two", SDL_SCANCODE_2 );
		lua_setnumber( lua, "Three", SDL_SCANCODE_3 );
		lua_setnumber( lua, "Four", SDL_SCANCODE_4 );
		lua_setnumber( lua, "Five", SDL_SCANCODE_5 );
		lua_setnumber( lua, "Six", SDL_SCANCODE_6 );
		lua_setnumber( lua, "Seven", SDL_SCANCODE_7 );
		lua_setnumber( lua, "Eight", SDL_SCANCODE_8 );
		lua_setnumber( lua, "Nine", SDL_SCANCODE_9 );

		lua_setnumber( lua, "KeypadZero", SDL_SCANCODE_KP_0 );
		lua_setnumber( lua, "KeypadOne", SDL_SCANCODE_KP_1 );
		lua_setnumber( lua, "KeypadTwo", SDL_SCANCODE_KP_2 );
		lua_setnumber( lua, "KeypadThree", SDL_SCANCODE_KP_3 );
		lua_setnumber( lua, "KeypadFour", SDL_SCANCODE_KP_4 );
		lua_setnumber( lua, "KeypadFive", SDL_SCANCODE_KP_5 );
		lua_setnumber( lua, "KeypadSix", SDL_SCANCODE_KP_6 );
		lua_setnumber( lua, "KeypadSeven", SDL_SCANCODE_KP_7 );
		lua_setnumber( lua, "KeypadEight", SDL_SCANCODE_KP_8 );
		lua_setnumber( lua, "KeypadNine", SDL_SCANCODE_KP_9 );
		lua_setnumber( lua, "KeypadReturn", SDL_SCANCODE_KP_ENTER );
		lua_setnumber( lua, "KeypadEnter", SDL_SCANCODE_KP_ENTER );
		
		lua_setnumber( lua, "Return", SDL_SCANCODE_RETURN );
		lua_setnumber( lua, "Enter", SDL_SCANCODE_RETURN );
		lua_setnumber( lua, "Backspace", SDL_SCANCODE_BACKSPACE );
		lua_setnumber( lua, "Escape",SDL_SCANCODE_ESCAPE );
		lua_setnumber( lua, "Space", SDL_SCANCODE_SPACE );
		lua_setnumber( lua, "LeftAlt", SDL_SCANCODE_LALT );
		lua_setnumber( lua, "LeftControl", SDL_SCANCODE_LCTRL );
		lua_setnumber( lua, "LeftShift", SDL_SCANCODE_LSHIFT );
		lua_setnumber( lua, "RightAlt", SDL_SCANCODE_RALT );
		lua_setnumber( lua, "RightControl", SDL_SCANCODE_RCTRL );
		lua_setnumber( lua, "RightShift", SDL_SCANCODE_RSHIFT );
		lua_setnumber( lua, "Delete", SDL_SCANCODE_DELETE );
		lua_setnumber( lua, "Tilde", SDL_SCANCODE_GRAVE );
		lua_setnumber( lua, "Home", SDL_SCANCODE_HOME );
		lua_setnumber( lua, "End", SDL_SCANCODE_END );

		lua_setnumber( lua, "Left", SDL_SCANCODE_LEFT );
		lua_setnumber( lua, "Right", SDL_SCANCODE_RIGHT );
		lua_setnumber( lua, "Up", SDL_SCANCODE_UP );
		lua_setnumber( lua, "Down", SDL_SCANCODE_DOWN );

		// set ascii keys
		for( int i=SDL_SCANCODE_A; i<=SDL_SCANCODE_Z; i++ )
		{
			char name[2] = { i - SDL_SCANCODE_A + 'A', 0 };
			lua_setnumber( lua, name, i );
		}

		lua_setglobal( lua, "Keys" );

		// set buttons
		lua_newtable( lua );

		lua_pushnumber( lua, SDL_BUTTON_LEFT );
		lua_setfield( lua, -2, "Left" );

		lua_pushnumber( lua, SDL_BUTTON_RIGHT );
		lua_setfield( lua, -2, "Right" );

		lua_pushnumber( lua, SDL_BUTTON_MIDDLE );
		lua_setfield( lua, -2, "Middle" );

		lua_setglobal( lua, "Buttons" );

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

			{ "setUpdateBound", setUpdateBound },

			{ "getMousePosition", getMousePosition },
			{ "getMouseDelta", getMouseDelta },
			{ "getMouseWheel", getMouseWheel },
			{ "getTextInput", getTextInput },
			{ "getActive", getActive },
			{ "getUpdateBound", getUpdateBound },

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

	LDEC( setUpdateBound )
	{
		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_BOOL( 1 ) )
			{
				bool bound = lua_tobool( lua, 1 );
				g_coreData->input->setUpdateBound( bound );
			}
		}

		return 0;
	}

	LDEC( getMousePosition )
	{
		Point position = g_coreData->input->getMousePosition();
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

	LDEC( getUpdateBound )
	{
		bool bound = g_coreData->input->getUpdateBound();

		lua_pushboolean( lua, bound );

		return 1;
	}
}