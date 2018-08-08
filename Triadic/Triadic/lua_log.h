#pragma once

#include "common.h"
#include "core_data.h"

namespace LuaLog
{
	void bind( lua_State* lua, CoreData* coreData );

	LDEC( logInfo );
	LDEC( logWarning );
	LDEC( logError );
	LDEC( logDebug );

	LDEC( getMessages );
}