#pragma once

#include "common.h"
#include "coredata.h"
#include "rendering.h"

namespace LuaShapes
{
	void bind( lua_State* lua, CoreData* coreData );

	LDEC( addLine );
	LDEC( addSphere );
	LDEC( addAABB );
	LDEC( addOBB );

	LDEC( setIgnoreDepth );
	LDEC( setVisible );

	LDEC( getIgnoreDepth );
	LDEC( getVisible );
}