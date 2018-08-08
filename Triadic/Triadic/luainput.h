#pragma once

#include "common.h"
#include "coredata.h"

namespace LuaInput
{
	void bind( lua_State* lua, CoreData* coreData );

	LDEC( keyDown );
	LDEC( keyPressed );
	LDEC( keyReleased );
	LDEC( keyRepeated );

	LDEC( buttonDown );
	LDEC( buttonPressed );
	LDEC( buttonReleased );

	LDEC( getMousePosition );
	LDEC( getMouseDelta );
	LDEC( getMouseWheel );
	LDEC( getTextInput );
	LDEC( getActive );
}