#include "lua_rendering.h"

namespace LuaRendering
{
	static CoreData* g_coreData;

	void bind( lua_State* lua, CoreData* coreData )
	{
		luaL_newmetatable( lua, "renderingMeta" );
		luaL_Reg renderingRegs[] =
		{
			{ "queueMesh", queueMesh },
			{ "queueQuad", queueQuad },
			{ "queueText", queueText },
			{ "queueBillboard", queueBillboard },

			{ "setLightingEnabled", setLightingEnabled },

			{ "getPerspectiveCamera", getPerspectiveCamera },
			{ "getOrthographicCamera", getOrthographicCamera },
			{ "getLightingEnabled", getLightingEnabled },

			{ NULL, NULL }
		};

		luaL_setfuncs( lua, renderingRegs, 0 );
		lua_pushvalue( lua, -1 );
		lua_setfield( lua, -2, "__index" );
		lua_setglobal( lua, "Graphics" );

		g_coreData = coreData;
	}

	LDEC( queueMesh )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) && LUA_EXPECT_TABLE( 2 ) )
			{
				int meshIndex = lua_toint( lua, 1 );
				Transform* transform = lua_getuserdata<Transform>( lua, 2 );

				g_coreData->graphics->queueMesh( meshIndex, transform );
			}
		}

		return 0;
	}

	LDEC( queueQuad )
	{
		int args = lua_gettop( lua );
		if( args != 4 && args != 6 )
		{
			LOG_ERROR( "Expected 3 or 5 argument(s). Got %d.", args );
		}
		else
		{
			if( LUA_EXPECT_NUMBER( 1 ) &&
				LUA_EXPECT_TABLE( 2 ) &&
				LUA_EXPECT_TABLE( 3 ) &&
				LUA_EXPECT_TABLE( 4 ) )
			{
				int textureIndex = lua_toint( lua, 1 );

				glm::vec2 position, size;
				glm::vec4 color;

				lua_getvec2( lua, 2, position );
				lua_getvec2( lua, 3, size );
				lua_getvec4( lua, 4, color );

				glm::vec2 uvStart( 0, 0 ), uvEnd( 1, 1 );
				if( args == 6 &&
					LUA_EXPECT_TABLE( 5 ) &&
					LUA_EXPECT_TABLE( 6 ) )
				{
					lua_getvec2( lua, 5, uvStart );
					lua_getvec2( lua, 6, uvEnd );
				}

				g_coreData->graphics->queueQuad( textureIndex, position, size, uvStart, uvEnd, color );
			}
		}

		return 0;
	}

	LDEC( queueText )
	{
		LUA_EXPECT_ARGS( 4 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) &&
				LUA_EXPECT_STRING( 2 ) &&
				LUA_EXPECT_TABLE( 3 ) &&
				LUA_EXPECT_TABLE( 4 ) )
			{
				glm::vec2 position;
				glm::vec4 color;

				int fontIndex = lua_toint( lua, 1 );
				const char* text = lua_tostring( lua, 2 );
				lua_getvec2( lua, 3, position );
				lua_getvec4( lua, 4, color );

				g_coreData->graphics->queueText( fontIndex, text, position, color );
			}
		}

		return 0;
	}

	LDEC( queueBillboard )
	{
		LUA_EXPECT_ARGS( 7 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) &&
				LUA_EXPECT_NUMBER( 2 ) &&
				LUA_EXPECT_TABLE( 3 ) &&
				LUA_EXPECT_TABLE( 4 ) &&
				LUA_EXPECT_TABLE( 5 ) &&
				LUA_EXPECT_BOOL( 6 ) && 
				LUA_EXPECT_TABLE( 7 ) )
			{
				glm::vec3 position, scroll;
				glm::vec2 size;
				glm::vec4 uv;

				int textureIndex = lua_toint( lua, 1 );
				int maskIndex = lua_toint( lua, 2 );
				lua_getvec3( lua, 3, position );
				lua_getvec2( lua, 4, size );
				lua_getvec4( lua, 5, uv );
				bool spherical = lua_tobool( lua, 6 );
				lua_getvec3( lua, 7, scroll );

				g_coreData->graphics->queueBillboard( textureIndex, maskIndex, position, size, uv, spherical, scroll );
			}
		}

		return 0;
	}

	LDEC( setLightingEnabled )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_BOOL( 1 ) )
			{
				bool enabled = lua_tobool( lua, 1 );

				g_coreData->graphics->setLightingEnabled( enabled );
			}
		}

		return result;
	}

	LDEC( getPerspectiveCamera )
	{
		Camera* camera = g_coreData->graphics->getPerspectiveCamera();

		lua_newtable( lua );
		lua_setuserdata( lua, "__self", camera );
		luaL_setmetatable( lua, "cameraMeta" );

		return 1;
	}

	LDEC( getOrthographicCamera )
	{
		Camera* camera = g_coreData->graphics->getOrthographicCamera();

		lua_newtable( lua );
		lua_setuserdata( lua, "__self", camera );
		luaL_setmetatable( lua, "cameraMeta" );

		return 1;
	}

	LDEC( getLightingEnabled )
	{
		bool enabled = g_coreData->graphics->getLightingEnabled();
		lua_pushboolean( lua, enabled );

		return 1;
	}
}