#pragma once

#include "common.h"
#include "core_data.h"

namespace LuaServer
{
	void bind( lua_State* lua, CoreData* coreData );

	LDEC( beginRead );
	LDEC( endRead );
	LDEC( getMessage );
}