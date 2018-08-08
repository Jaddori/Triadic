#pragma once

#include "common.h"
#include "core_data.h"
#include "transform.h"

namespace LuaTransform
{
	void bind( lua_State* lua, CoreData* coreData );

	LDEC( create );
	LDEC( destroy );

	LDEC( addPosition );
	LDEC( addOrientation );
	LDEC( addScale );

	LDEC( setPosition );
	LDEC( setOrientation );
	LDEC( setScale );
	LDEC( setActive );

	LDEC( getPosition );
	LDEC( getOrientation );
	LDEC( getScale );
	LDEC( getActive );
}