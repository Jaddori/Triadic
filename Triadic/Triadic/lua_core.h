#pragma once

#include "common.h"
#include "core_data.h"

namespace LuaCore
{
	void bind( lua_State* lua, CoreData* coreData );

	LDEC( getTicks );
	LDEC( exit );
}