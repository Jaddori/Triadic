#include "lua_shapes.h"

namespace LuaShapes
{
	static CoreData* g_coreData;

	void bind( lua_State* lua, CoreData* coreData )
	{
		luaL_newmetatable( lua, "shapesMeta" );
		luaL_Reg shapesRegs[] =
		{
			{ "addLine", addLine },
			{ "addSphere", addSphere },
			{ "addAABB", addAABB },
			{ "addOBB", addOBB },

			{ "setIgnoreDepth", setIgnoreDepth },
			{ "setVisible", setVisible },
			
			{ "getIgnoreDepth", getIgnoreDepth },
			{ "getVisible", getVisible },

			{ NULL, NULL }
		};

		luaL_setfuncs( lua, shapesRegs, 0 );
		lua_pushvalue( lua, -1 );
		lua_setfield( lua, -2, "__index" );
		lua_setglobal( lua, "DebugShapes" );

		g_coreData = coreData;
	}

	LDEC( addLine )
	{
		LUA_EXPECT_ARGS( 3 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_TABLE( 2 ) &&
				LUA_EXPECT_TABLE( 3 ) )
			{
				glm::vec3 start, end;
				glm::vec4 color;

				lua_getvec3( lua, 1, start );
				lua_getvec3( lua, 2, end );
				lua_getvec4( lua, 3, color );

				g_coreData->debugShapes->addLine( { start, end, color } );
			}
		}

		return 0;
	}

	LDEC( addSphere )
	{
		LUA_EXPECT_ARGS( 3 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_NUMBER( 2 ) &&
				LUA_EXPECT_TABLE( 3 ) )
			{
				glm::vec3 position;
				glm::vec4 color;

				lua_getvec3( lua, 1, position );
				float radius = lua_tofloat( lua, 2 );
				lua_getvec4( lua, 3, color );

				g_coreData->debugShapes->addSphere( { position, radius, color } );
			}
		}

		return 0;
	}

	LDEC( addAABB )
	{
		LUA_EXPECT_ARGS( 3 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_TABLE( 2 ) &&
				LUA_EXPECT_TABLE( 3 ) )
			{
				glm::vec3 minPosition, maxPosition;
				glm::vec4 color;

				lua_getvec3( lua, 1, minPosition );
				lua_getvec3( lua, 2, maxPosition );
				lua_getvec4( lua, 3, color );

				g_coreData->debugShapes->addAABB( { minPosition, maxPosition, color } );
			}
		}

		return 0;
	}

	LDEC( addOBB )
	{
		LUA_EXPECT_ARGS( 6 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_TABLE( 2 ) &&
				LUA_EXPECT_TABLE( 3 ) &&
				LUA_EXPECT_TABLE( 4 ) &&
				LUA_EXPECT_TABLE( 5 ) &&
				LUA_EXPECT_TABLE( 6 ) )
			{
				glm::vec3 position, x, y, z, extents;
				glm::vec4 color;

				lua_getvec3( lua, 1, position );
				lua_getvec3( lua, 2, x );
				lua_getvec3( lua, 2, y );
				lua_getvec3( lua, 2, z );
				lua_getvec3( lua, 2, extents );
				lua_getvec4( lua, 3, color );

				g_coreData->debugShapes->addOBB( { position, x, y, z, extents, color } );
			}
		}

		return 0;
	}

	LDEC( setIgnoreDepth )
	{
		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_BOOL( 1 ) )
			{
				bool ignore = lua_tobool( lua, 1 );
				g_coreData->debugShapes->setIgnoreDepth( ignore );
			}
		}

		return 0;
	}

	LDEC( setVisible )
	{
		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_BOOL( 1 ) )
			{
				bool visible = lua_tobool( lua, 1 );
				g_coreData->debugShapes->setVisible( visible );
			}
		}

		return 0;
	}

	LDEC( getIgnoreDepth )
	{
		bool ignore = g_coreData->debugShapes->getIgnoreDepth();
		lua_pushboolean( lua, ignore );
		return 1;
	}

	LDEC( getVisible )
	{
		bool visible = g_coreData->debugShapes->getVisible();
		lua_pushboolean( lua, visible );
		return 1;
	}
}