#pragma once

#include "common.h"
#include "core_data.h"

namespace LuaAssets
{
	void bind( lua_State* lua, CoreData* coreData );

	LDEC( loadTexture );
	LDEC( loadMesh );
	LDEC( loadFont );

	LDEC( getMesh );
	LDEC( getFont );

	// MESH
	LDEC( getBoundingBox );

	// FONT
	LDEC( measureText );
	LDEC( getBitmapSize );
	LDEC( getWidth );
	LDEC( getHeight );
}