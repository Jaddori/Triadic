#pragma once

#include "common.h"
#include "coredata.h"
#include "rendering.h"

namespace LuaRendering
{
	void bind( lua_State* lua, CoreData* coreData );

	LDEC( queueMesh );
	LDEC( queueText );
}