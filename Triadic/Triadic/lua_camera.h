#pragma once

#include "common.h"
#include "core_data.h"
#include "rendering.h"

namespace LuaCamera
{
	void bind( lua_State* lua, CoreData* coreData );

	LDEC( create );
	LDEC( destroy );

	LDEC( project );
	LDEC( unproject );

	LDEC( relativeMovement );
	LDEC( absoluteMovement );

	LDEC( updateDirection );
	LDEC( updatePerspective );
	LDEC( updateOrthographic );

	LDEC( setPosition );
	LDEC( setDirection );

	LDEC( getPosition );
	LDEC( getDirection );
	LDEC( getForward );
	LDEC( getRight );
	LDEC( getUp );
}