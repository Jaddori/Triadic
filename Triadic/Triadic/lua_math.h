#pragma once

#include "common.h"

namespace LuaMath
{
	void bind( lua_State* lua );

	namespace LuaVec2
	{
		LDEC( create );

		LDEC( dot );
		LDEC( normalize );
		LDEC( length );
		LDEC( distance );

		LDEC( add );
		LDEC( sub );
		LDEC( mul );
		LDEC( div );
	}

	namespace LuaVec3
	{
		LDEC( create );

		LDEC( dot );
		LDEC( normalize );
		LDEC( length );
		LDEC( distance );

		LDEC( add );
		LDEC( sub );
		LDEC( mul );
		LDEC( div );
	}

	namespace LuaVec4
	{
		LDEC( create );

		LDEC( dot );
		LDEC( normalize );
		LDEC( length );
		LDEC( distance );

		LDEC( add );
		LDEC( sub );
		LDEC( mul );
		LDEC( div );
	}
}