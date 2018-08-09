#pragma once

#include "common.h"
#include "collision_solver.h"
#include "core_data.h"

namespace LuaPhysics
{
	void bind( lua_State* lua, CoreData* coreData );

	LDEC( raySphere );
	LDEC( rayAABB );
	LDEC( sphereSphere );
	LDEC( aabbAABB );
}