#include "lua_physics.h"
using namespace Physics;

namespace LuaPhysics
{
	static CoreData* g_coreData;

	void bind( lua_State* lua, CoreData* coreData )
	{
		luaL_newmetatable( lua, "physicsMeta" );
		luaL_Reg physicsRegs[] =
		{
			{ "raySphere", raySphere },
			{ "rayAABB", rayAABB },
			{ "sphereSphere", sphereSphere },
			{ "aabbAABB", aabbAABB },

			{ NULL, NULL }
		};

		luaL_setfuncs( lua, physicsRegs, 0 );
		lua_pushvalue( lua, -1 );
		lua_setfield( lua, -2, "__index" );
		lua_setglobal( lua, "Physics" );

		g_coreData = coreData;
	}

	LDEC( raySphere )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 5 )
		{
			if( LUA_EXPECT_TABLE( 1 ) && 
				LUA_EXPECT_TABLE( 2 ) &&
				LUA_EXPECT_NUMBER( 3 ) &&
				LUA_EXPECT_TABLE( 4 ) &&
				LUA_EXPECT_NUMBER( 5 ) )
			{
				Ray ray = {};
				
				lua_getvec3( lua, 1, ray.start );
				lua_getvec3( lua, 2, ray.direction );
				ray.length = lua_tofloat( lua, 3 );

				Sphere sphere = {};

				lua_getvec3( lua, 4, sphere.center );
				sphere.radius = lua_tofloat( lua, 5 );

				bool collision = g_coreData->collisionSolver->ray( ray, sphere );
				lua_pushboolean( lua, collision );
				result = 1;
			}
		}

		return result;
	}

	LDEC( rayAABB )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 5 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_TABLE( 2 ) &&
				LUA_EXPECT_NUMBER( 3 ) &&
				LUA_EXPECT_TABLE( 4 ) &&
				LUA_EXPECT_TABLE( 5 ) )
			{
				Ray ray = {};

				lua_getvec3( lua, 1, ray.start );
				lua_getvec3( lua, 2, ray.direction );
				ray.length = lua_tofloat( lua, 3 );

				AABB aabb = {};

				lua_getvec3( lua, 4, aabb.minPosition );
				lua_getvec3( lua, 5, aabb.maxPosition );

				bool collision = g_coreData->collisionSolver->ray( ray, aabb );
				lua_pushboolean( lua, collision );
				result = 1;
			}
		}

		return result;
	}

	LDEC( sphereSphere )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 4 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_NUMBER( 2 ) &&
				LUA_EXPECT_TABLE( 3 ) &&
				LUA_EXPECT_NUMBER( 4 ) )
			{
				Sphere a = {};

				lua_getvec3( lua, 1, a.center );
				a.radius = lua_tofloat( lua, 2 );

				Sphere b = {};
				lua_getvec3( lua, 3, b.center );
				b.radius = lua_tofloat( lua, 4 );

				bool collision = g_coreData->collisionSolver->sphere( a, b );
				lua_pushboolean( lua, collision );
				result = 1;
			}
		}

		return result;
	}

	LDEC( aabbAABB )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 4 )
		{
			if( LUA_EXPECT_TABLE( 1 ) && 
				LUA_EXPECT_TABLE( 2 ) && 
				LUA_EXPECT_TABLE( 3 ) && 
				LUA_EXPECT_TABLE( 4 ) )
			{
				AABB a = {};

				lua_getvec3( lua, 1, a.minPosition );
				lua_getvec3( lua, 2, a.maxPosition );

				AABB b = {};

				lua_getvec3( lua, 3, b.minPosition );
				lua_getvec3( lua, 4, b.maxPosition );

				bool collision = g_coreData->collisionSolver->aabb( a, b );
				lua_pushboolean( lua, collision );
				result = 1;
			}
		}

		return result;
	}
}