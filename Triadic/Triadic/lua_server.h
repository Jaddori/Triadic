#pragma once

#include "common.h"
#include "core_data.h"

namespace LuaServer
{
	void bind( lua_State* lua, CoreData* coreData );

	LDEC( getMessages );
	//LDEC( getNetworkID );

	LDEC( queueInt );
	LDEC( queueUint );
	LDEC( queueFloat );
	LDEC( queueString );
}