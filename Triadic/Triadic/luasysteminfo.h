#pragma once

#include "common.h"
#include "coredata.h"
#include "systeminfo.h"

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