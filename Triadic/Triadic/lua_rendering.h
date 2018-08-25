#pragma once

#include "common.h"
#include "core_data.h"
#include "rendering.h"

namespace LuaRendering
{
	void bind( lua_State* lua, CoreData* coreData );

	LDEC( queueMesh );
	LDEC( queueQuad );
	LDEC( queueText );
	LDEC( queueBillboard );

	LDEC( setLightingEnabled );

	LDEC( getPerspectiveCamera );
	LDEC( getOrthographicCamera );
	LDEC( getLightingEnabled );
}