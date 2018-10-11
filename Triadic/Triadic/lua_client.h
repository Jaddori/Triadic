#pragma once

#include "common.h"
#include "core_data.h"

namespace LuaClient
{
	void bind( lua_State* lua, CoreData* coreData );

	LDEC( connect );

	LDEC( getMessages );
	//LDEC( getConnected );
	//LDEC( getNetworkID );

	LDEC( queueInt );
	LDEC( queueUint );
	LDEC( queueFloat );
	LDEC( queueString );
}