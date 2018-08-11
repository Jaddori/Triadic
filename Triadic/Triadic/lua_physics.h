#pragma once

#include "common.h"
#include "collision_solver.h"
#include "core_data.h"

namespace LuaPhysics
{
	void bind( lua_State* lua, CoreData* coreData );

	LDEC( createRay );
	LDEC( createRayFromPoints );
	LDEC( createSphere );
	LDEC( createAABB );
	LDEC( createPlane );

	LDEC( getAABBCenter );

	LDEC( raySphere );
	LDEC( rayAABB );
	LDEC( rayPlane );
	LDEC( sphereSphere );
	LDEC( aabbAABB );

	inline Physics::Ray readRay( lua_State* lua, int tableIndex )
	{
		Physics::Ray result;

		lua_getfield( lua, tableIndex, "start" );
		lua_getvec3( lua, -1, result.start );

		lua_getfield( lua, tableIndex, "direction" );
		lua_getvec3( lua, -1, result.direction );

		lua_getfield( lua, tableIndex, "length" );
		result.length = lua_tofloat( lua, -1 );
		lua_pop( lua, 1 );

		return result;
	}

	inline Physics::AABB readAABB( lua_State* lua, int tableIndex )
	{
		Physics::AABB result;

		lua_getfield( lua, tableIndex, "minPosition" );
		lua_getvec3( lua, -1, result.minPosition );

		lua_getfield( lua, tableIndex, "maxPosition" );
		lua_getvec3( lua, -1, result.maxPosition );

		return result;
	}

	inline Physics::Plane readPlane( lua_State* lua, int tableIndex )
	{
		Physics::Plane result;
		
		lua_getfield( lua, tableIndex, "normal" );
		lua_getvec3( lua, -1, result.normal );

		lua_getfield( lua, tableIndex, "offset" );
		result.offset = lua_tofloat( lua, -1 );
		lua_pop( lua, 1 );

		return result;
	}

	inline void writeRay( lua_State* lua, const Physics::Ray& ray )
	{
		lua_newtable( lua );

		lua_newtable( lua );
		lua_setvec3( lua, ray.start );
		lua_setfield( lua, -2, "start" );

		lua_newtable( lua );
		lua_setvec3( lua, ray.direction );
		lua_setfield( lua, -2, "direction" );

		lua_setnumber( lua, "length", ray.length );
	}

	inline void writePlane( lua_State* lua, const Physics::Plane& plane )
	{
		lua_newtable( lua );
		
		lua_newtable( lua );
		lua_setvec3( lua, plane.normal );
		lua_setfield( lua, -2, "normal" );

		lua_pushnumber( lua, plane.offset );
		lua_setfield( lua, -2, "offset" );
	}
}