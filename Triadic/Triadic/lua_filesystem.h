#pragma once

#include "common.h"

namespace LuaFilesystem
{
	void bind( lua_State* lua );

	LDEC( getFiles );
	LDEC( messageBox );
}