#include "lua_assets.h"
using namespace Rendering;

namespace LuaAssets
{
	static CoreData* g_coreData;

	void bind( lua_State* lua, CoreData* coreData )
	{
		// assets metatable
		luaL_newmetatable( lua, "assetsMeta" );
		luaL_Reg assetsRegs[] =
		{
			{ "loadTexture", loadTexture },
			{ "loadMesh", loadMesh },
			{ "loadFont", loadFont },

			{ "getFont", getFont },

			{ NULL, NULL }
		};

		luaL_setfuncs( lua, assetsRegs, 0 );
		lua_pushvalue( lua, -1 );
		lua_setfield( lua, -2, "__index" );
		lua_setglobal( lua, "Assets" );

		// font metatable
		luaL_newmetatable( lua, "fontMeta" );
		luaL_Reg fontRegs[] =
		{
			{ "measureText", measureText },
			{ "getBitmapSize", getBitmapSize },
			{ "getWidth", getWidth },
			{ "getHeight", getHeight },
		};

		luaL_setfuncs( lua, assetsRegs, 0 );
		lua_pushvalue( lua, -1 );
		lua_setfield( lua, -2, "__index" );

		g_coreData = coreData;
	}

	LDEC( loadTexture )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_STRING( 1 ) )
			{
				const char* path = lua_tostring( lua, 1 );

				int index = g_coreData->assets->loadTexture( path );
				if( index >= 0 )
				{
					lua_pushnumber( lua, index );
					result = 1;
				}
			}
		}

		return result;
	}

	LDEC( loadMesh )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_STRING( 1 ) )
			{
				const char* path = lua_tostring( lua, 1 );

				int index = g_coreData->assets->loadMesh( path );
				if( index >= 0 )
				{
					lua_pushnumber( lua, index );
					result = 1;
				}
			}
		}

		return result;
	}

	LDEC( loadFont )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_STRING( 1 ) && LUA_EXPECT_STRING( 2 ) )
			{
				const char* info = lua_tostring( lua, 1 );
				const char* texture = lua_tostring( lua, 2 );

				int index = g_coreData->assets->loadFont( info, texture );
				if( index >= 0 )
				{
					lua_pushnumber( lua, index );
					result = 1;
				}
			}
		}

		return result;
	}

	LDEC( getFont )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) )
			{
				int index = lua_toint( lua, 1 );

				const Font* font = g_coreData->assets->getFont( index );

				lua_newtable( lua );
				lua_pushlightuserdata( lua, (void*)font );
				lua_setfield( lua, -2, "__self" );
				luaL_setmetatable( lua, "fontMeta" );
			}
		}

		return result;
	}

	// FONT
	LDEC( measureText )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) && LUA_EXPECT_STRING( 2 ) )
			{
				Font* font = lua_getuserdata<Font>( lua, 1 );
				const char* text = lua_tostring( lua, 2 );

				glm::vec2 measurement;
				font->measureText( text, &measurement );

				lua_newtable( lua );
				lua_setvec2( lua, measurement );
				result = 1;
			}
		}

		return result;
	}

	LDEC( getBitmapSize )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_TABLE( 1 ) )
			{
				Font* font = lua_getuserdata<Font>( lua, 1 );

				int bitmapSize = font->getBitmapSize();
				lua_pushnumber( lua, bitmapSize );
				result = 1;
			}
		}

		return result;
	}

	LDEC( getWidth )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) && LUA_EXPECT_STRING( 2 ) )
			{
				Font* font = lua_getuserdata<Font>( lua, 1 );
				const char* text = lua_tostring( lua, 2 );
				char c = text[0];

				int width = font->getWidth( c );
				lua_pushnumber( lua, width );
				result = 1;
			}
		}

		return result;
	}

	LDEC( getHeight )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_TABLE( 1 ) )
			{
				Font* font = lua_getuserdata<Font>( lua, 1 );

				int height = font->getHeight();
				lua_pushnumber( lua, height );
				result = 1;
			}
		}

		return result;
	}
}