#include "lua_physics.h"
using namespace Physics;

namespace LuaPhysics
{
	static CoreData* g_coreData;

	void bind( lua_State* lua, CoreData* coreData )
	{
		// physics
		luaL_newmetatable( lua, "physicsMeta" );
		luaL_Reg physicsRegs[] =
		{
			{ "createRay", createRay },
			{ "createRayFromPoints", createRayFromPoints },
			{ "createSphere", createSphere },
			{ "createAABB", createAABB },
			{ "createPlane", createPlane },

			{ "getAABBCenter", getAABBCenter },

			{ "raySphere", raySphere },
			{ "rayAABB", rayAABB },
			{ "rayPlane", rayPlane },
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

	LDEC( createRay )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 3 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_TABLE( 2 ) &&
				LUA_EXPECT_NUMBER( 3 ) )
			{
				glm::vec3 start, direction;

				lua_getvec3( lua, 1, start );
				lua_getvec3( lua, 2, direction );

				float length = lua_tofloat( lua, 3 );

				lua_newtable( lua );

				lua_newtable( lua );
				lua_setvec3( lua, start );
				lua_setfield( lua, -2, "start" );

				lua_newtable( lua );
				lua_setvec3( lua, direction );
				lua_setfield( lua, -2, "direction" );

				lua_setnumber( lua, "length", length );

				result = 1;
			}
		}

		return result;
	}

	LDEC( createRayFromPoints )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_TABLE( 2 ) )
			{
				glm::vec3 start, end;

				lua_getvec3( lua, 1, start );
				lua_getvec3( lua, 2, end );

				glm::vec3 direction = end - start;
				float length = glm::length( direction );
				direction = glm::normalize( direction );

				writeRay( lua, { start, direction, length } );
				result = 1;
			}
		}

		return result;
	}

	LDEC( createSphere )
	{
		int result = 0;
		
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_NUMBER( 2 ) )
			{
				glm::vec3 center;
				lua_getvec3( lua, 1, center );

				float radius = lua_tofloat( lua, 2 );

				lua_newtable( lua );
				
				lua_newtable( lua );
				lua_setvec3( lua, center );
				lua_setfield( lua, -2, "center" );

				lua_setnumber( lua, "radius", radius );

				result = 1;
			}
		}

		return result;
	}

	LDEC( createAABB )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_TABLE( 2 ) )
			{
				glm::vec3 minPosition, maxPosition;

				lua_getvec3( lua, 1, minPosition );
				lua_getvec3( lua, 2, maxPosition );

				lua_newtable( lua );

				lua_newtable( lua );
				lua_setvec3( lua, minPosition );
				lua_setfield( lua, -2, "minPosition" );

				lua_newtable( lua );
				lua_setvec3( lua, maxPosition );
				lua_setfield( lua, -2, "maxPosition" );

				result = 1;
			}
		}

		return result;
	}

	LDEC( createPlane )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_NUMBER( 2 ) )
			{
				glm::vec3 normal;
				lua_getvec3( lua, 1, normal );

				float offset = lua_tofloat( lua, 2 );

				writePlane( lua, { normal, offset } );
				result = 1;
			}
		}

		return result;
	}

	LDEC( getAABBCenter )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_TABLE( 1 ) )
			{
				AABB aabb = readAABB( lua, 1 );

				glm::vec3 center = aabb.minPosition;
				glm::vec3 dif = aabb.maxPosition - center;

				center += dif * 0.5f;

				lua_newtable( lua );
				lua_setvec3( lua, center );
				luaL_setmetatable( lua, "vec3Meta" );

				result = 1;
			}
		}

		return result;
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

		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_TABLE( 2 ) )
			{
				//Ray ray = {};
				//
				//lua_getvec3( lua, 1, ray.start );
				//lua_getvec3( lua, 2, ray.direction );
				//ray.length = lua_tofloat( lua, 3 );
				//
				//AABB aabb = {};
				//
				//lua_getvec3( lua, 4, aabb.minPosition );
				//lua_getvec3( lua, 5, aabb.maxPosition );

				Ray ray = readRay( lua, 1 );
				AABB aabb = readAABB( lua, 2 );

				bool collision = g_coreData->collisionSolver->ray( ray, aabb );
				lua_pushboolean( lua, collision );
				result = 1;
			}
		}

		return result;
	}

	LDEC( rayPlane )
	{
		int result = 0;

		int args = lua_gettop( lua );
		if( args >= 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_TABLE( 2 ) )
			{
				Ray ray = readRay( lua, 1 );
				Plane plane = readPlane( lua, 2 );

				Hit hit = {};
				Hit* hitp = NULL;
				if( args == 3 && LUA_EXPECT_TABLE( 3 ) )
				{
					hitp = &hit;
				}

				bool collision = g_coreData->collisionSolver->ray( ray, plane, hitp );

				if( hitp )
				{
					lua_newtable( lua );
					lua_setvec3( lua, hit.position );
					lua_setfield( lua, 3, "position" );

					lua_pushnumber( lua, hit.length );
					lua_setfield( lua, 3, "length" );
				}

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