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
			{ "queuePointLight", queuePointLight },
			{ "queueDirectionalLight", queueDirectionalLight },

			{ "setLightingEnabled", setLightingEnabled },

			{ "getPointLightSize", getPointLightSize },
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
		//int args = lua_gettop( lua );
		//if( args != 5 && args != 7 )
		//{
		//	LOG_ERROR( "Expected 5 or 7 argument(s). Got %d.", args );
		//}
		//else
		LUA_EXPECT_EXPRESSION( args == 5 || args == 7 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) &&
				LUA_EXPECT_TABLE( 2 ) &&
				LUA_EXPECT_TABLE( 3 ) &&
				LUA_EXPECT_NUMBER( 4 ) &&
				LUA_EXPECT_TABLE( 5 ) )
			{
				int textureIndex = lua_toint( lua, 1 );

				glm::vec2 position;
				glm::vec2 size;
				glm::vec4 color;

				lua_getvec2( lua, 2, position );
				lua_getvec2( lua, 3, size );
				float depth = lua_tofloat( lua, 4 );
				lua_getvec4( lua, 5, color );

				glm::vec2 uvStart( 0, 0 ), uvEnd( 1, 1 );
				if( args == 7 &&
					LUA_EXPECT_TABLE( 6 ) &&
					LUA_EXPECT_TABLE( 7 ) )
				{
					lua_getvec2( lua, 6, uvStart );
					lua_getvec2( lua, 7, uvEnd );
				}

				g_coreData->graphics->queueQuad( textureIndex, glm::vec3( position.x, position.y, depth ), size, uvStart, uvEnd, color );
			}
		}

		return 0;
	}

	LDEC( queueText )
	{
		LUA_EXPECT_ARGS( 5 )
		{
			if( LUA_EXPECT_NUMBER( 1 ) &&
				LUA_EXPECT_STRING( 2 ) &&
				LUA_EXPECT_TABLE( 3 ) &&
				LUA_EXPECT_NUMBER( 4 ) &&
				LUA_EXPECT_TABLE( 5 ) )
			{
				glm::vec2 position;
				glm::vec4 color;

				int fontIndex = lua_toint( lua, 1 );
				const char* text = lua_tostring( lua, 2 );
				lua_getvec2( lua, 3, position );
				float depth = lua_tofloat( lua, 4 );
				lua_getvec4( lua, 5, color );

				g_coreData->graphics->queueText( fontIndex, text, glm::vec3( position.x, position.y, depth ), color );
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

	LDEC( queueDirectionalLight )
	{
		LUA_EXPECT_ARGS( 3 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_TABLE( 2 ) &&
				LUA_EXPECT_NUMBER( 3 ) )
			{
				glm::vec3 direction, color;

				lua_getvec3( lua, 1, direction );
				lua_getvec3( lua, 2, color );

				float intensity = lua_tofloat( lua, 3 );

				g_coreData->graphics->queueDirectionalLight( direction, color, intensity );
			}
		}

		return 0;
	}

	LDEC( queuePointLight )
	{
		LUA_EXPECT_ARGS( 6 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_TABLE( 2 ) &&
				LUA_EXPECT_NUMBER( 3 ) &&
				LUA_EXPECT_NUMBER( 4 ) &&
				LUA_EXPECT_NUMBER( 5 ) &&
				LUA_EXPECT_NUMBER( 6 ) )
			{
				glm::vec3 position, color;

				lua_getvec3( lua, 1, position );
				lua_getvec3( lua, 2, color );

				float intensity = lua_tofloat( lua, 3 );
				float linear = lua_tofloat( lua, 4 );
				float constant = lua_tofloat( lua, 5 );
				float exponent = lua_tofloat( lua, 6 );

				g_coreData->graphics->queuePointLight( position, color, intensity, linear, constant, exponent );
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

	LDEC( getPointLightSize )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 5 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_NUMBER( 2 ) &&
				LUA_EXPECT_NUMBER( 3 ) &&
				LUA_EXPECT_NUMBER( 4 ) &&
				LUA_EXPECT_NUMBER( 5 ) )
			{
				glm::vec3 color;
				lua_getvec3( lua, 1, color );

				float intensity = lua_tofloat( lua, 2 );
				float linear = lua_tofloat( lua, 3 );
				float constant = lua_tofloat( lua, 4 );
				float exponent = lua_tofloat( lua, 5 );

				float C = fmax( fmax( color.r, color.g ), color.b );
				float radius = ( -linear + sqrt( powf( linear, 2.0f ) - 4*exponent * ( constant - 256*C*intensity ) ) ) / (2*exponent);

				lua_pushnumber( lua, radius );
				result = 1;
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