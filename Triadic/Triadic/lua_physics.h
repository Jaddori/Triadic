#pragma once

#include "common.h"
#include "collision_solver.h"
#include "core_data.h"

namespace LuaPhysics
{
	void bind( lua_State* lua, CoreData* coreData );

	LDEC( createRay );
	LDEC( createSphere );
	LDEC( createAABB );

	LDEC( getAABBCenter );

	LDEC( raySphere );
	LDEC( rayAABB );
	LDEC( sphereSphere );
	LDEC( aabbAABB );

	inline Physics::AABB readAABB( lua_State* lua, int tableIndex )
	{
		Physics::AABB result;

		lua_getfield( lua, tableIndex, "minPosition" );
		//lua_getvec3( lua, -1, result.minPosition );
		lua_rawgeti( lua, -1, 1 );
		result.minPosition.x = lua_tofloat( lua, -1 );
		lua_pop( lua, 1 );

		lua_rawgeti( lua, -1, 2 );
		result.minPosition.y = lua_tofloat( lua, -1 );
		lua_pop( lua, 1 );

		lua_rawgeti( lua, -1, 3 );
		result.minPosition.z = lua_tofloat( lua, -1 );
		lua_pop( lua, 1 );
		lua_pop( lua, 1 );

		lua_getfield( lua, tableIndex, "maxPosition" );
		//lua_getvec3( lua, -1, result.maxPosition );
		lua_rawgeti( lua, -1, 1 );
		result.maxPosition.x = lua_tofloat( lua, -1 );
		lua_pop( lua, 1 );

		lua_rawgeti( lua, -1, 2 );
		result.maxPosition.y = lua_tofloat( lua, -1 );
		lua_pop( lua, 1 );

		lua_rawgeti( lua, -1, 3 );
		result.maxPosition.z = lua_tofloat( lua, -1 );
		lua_pop( lua, 1 );

		return result;
	}
}