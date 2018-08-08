#pragma once

#include "common.h"
#include "core_data.h"
#include "system_info.h"

namespace LuaSystemInfo
{
	void bind( lua_State* lua, CoreData* coreData );

	LDEC( getCores );
	LDEC( getThreads );
	LDEC( getRam );
	LDEC( getVsync );
	LDEC( getUpdateMs );
	LDEC( getRenderMs );
	LDEC( getDeltaTime );
}