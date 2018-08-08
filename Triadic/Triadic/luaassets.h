#pragma once

#include "common.h"
#include "coredata.h"

namespace LuaAssets
{
	void bind( lua_State* lua, CoreData* coreData );

	LDEC( loadTexture );
	LDEC( loadMesh );
	LDEC( loadFont );

	LDEC( getFont );

	// FONT
	LDEC( measureText );
	LDEC( getBitmapSize );
	LDEC( getWidth );
	LDEC( getHeight );
}