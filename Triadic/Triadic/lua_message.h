#pragma once

#include "common.h"
#include "message.h"

namespace LuaMessage
{
	void bind( lua_State* lua );

	LDEC( clear );

	LDEC( writeChar );
	LDEC( writeBool );
	LDEC( writeInt );
	LDEC( writeFloat );
	LDEC( writeString );

	LDEC( readChar );
	LDEC( readBool );
	LDEC( readInt );
	LDEC( readFloat );
	LDEC( readString );
}