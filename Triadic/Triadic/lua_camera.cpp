#include "lua_camera.h"

namespace LuaCamera
{
	static CoreData* g_coreData;

	void bind( lua_State* lua, CoreData* coreData )
	{
		luaL_newmetatable( lua, "cameraMeta" );
		luaL_Reg cameraRegs[] =
		{
			{ "create", create },
			{ "destroy", destroy },

			{ "project", project },
			{ "unproject", unproject },
			
			{ "relativeMovement", relativeMovement },
			{ "absoluteMovement", absoluteMovement },
			
			{ "updateDirection", updateDirection },
			{ "updatePerspective", updatePerspective },
			{ "updateOrthographic", updateOrthographic },

			{ "setPosition", setPosition },
			{ "setDirection", setDirection },

			{ "getPosition", getPosition },
			{ "getDirection", getDirection },
			{ "getForward", getForward },
			{ "getRight", getRight },
			{ "getUp", getUp },

			{ NULL, NULL }
		};

		luaL_setfuncs( lua, cameraRegs, 0 );
		lua_pushvalue( lua, -1 );
		lua_setfield( lua, -2, "__index" );
		lua_setglobal( lua, "Camera" );

		g_coreData = coreData;
	}

	LDEC( create )
	{
		Camera* camera = new Camera();
		lua_newtable( lua );
		lua_pushlightuserdata( lua, camera );
		lua_setfield( lua, -2, "__self" );
		luaL_setmetatable( lua, "cameraMeta" );

		return 1;
	}

	LDEC( destroy )
	{
		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_TABLE( 1 ) )
			{
				Camera* camera = lua_getuserdata<Camera>( lua, 1 );
				delete camera;

				lua_pushnil( lua );
				lua_setfield( lua, 1, "__self" );
			}
		}

		return 0;
	}

	LDEC( project )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_TABLE( 2 ) )
			{
				Camera* camera = lua_getuserdata<Camera>( lua, 1 );

				glm::vec3 worldCoordinates;
				lua_getvec3( lua, 2, worldCoordinates );

				Point windowCoordinates = {};
				camera->project( worldCoordinates, windowCoordinates );

				lua_newtable( lua );
				lua_pushnumber( lua, windowCoordinates.x );
				lua_rawseti( lua, -2, 1 );
				lua_pushnumber( lua, windowCoordinates.y );
				lua_rawseti( lua, -2, 2 );

				luaL_setmetatable( lua, "vec2Meta" );

				result = 1;
			}
		}

		return result;
	}

	LDEC( unproject )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 3 )
		{
			if( LUA_EXPECT_TABLE( 1 ) &&
				LUA_EXPECT_TABLE( 2 ) &&
				LUA_EXPECT_NUMBER( 3 ) )
			{
				Camera* camera = lua_getuserdata<Camera>( lua, 1 );

				Point windowCoordinates;
				lua_rawgeti( lua, 2, 1 );
				windowCoordinates.x = lua_toint( lua, -1 );
				lua_rawgeti( lua, 2, 2 );
				windowCoordinates.y = lua_toint( lua, -1 );

				float depth = lua_tofloat( lua, 3 );

				glm::vec3 worldCoordinates;
				camera->unproject( windowCoordinates, depth, worldCoordinates );

				lua_newtable( lua );
				lua_setvec3( lua, worldCoordinates );
				luaL_setmetatable( lua, "vec3Meta" );
				result = 1;
			}
		}

		return result;
	}

	LDEC( relativeMovement )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) && LUA_EXPECT_TABLE( 2 ) )
			{
				Camera* camera = lua_getuserdata<Camera>( lua, 1 );

				glm::vec3 localMovement;
				lua_getvec3( lua, 2, localMovement );

				camera->relativeMovement( localMovement );
			}
		}

		return 0;
	}

	LDEC( absoluteMovement )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) && LUA_EXPECT_TABLE( 2 ) )
			{
				Camera* camera = lua_getuserdata<Camera>( lua, 1 );

				glm::vec3 absoluteMovement;
				lua_getvec3( lua, 2, absoluteMovement );

				camera->absoluteMovement( absoluteMovement );
			}
		}

		return 0;
	}

	LDEC( updateDirection )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) && LUA_EXPECT_TABLE( 2 ) )
			{
				Camera* camera = lua_getuserdata<Camera>( lua, 1 );

				lua_rawgeti( lua, 2, 1 );
				int deltaX = lua_toint( lua, -1 );
				lua_rawgeti( lua, 2, 2 );
				int deltaY = lua_toint( lua, -1 );

				camera->updateDirection( deltaX, deltaY );
			}
		}

		return 0;
	}

	LDEC( updatePerspective )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) && LUA_EXPECT_TABLE( 2 ) )
			{
				Camera* camera = lua_getuserdata<Camera>( lua, 1 );

				glm::vec2 dimensions;
				lua_getvec2( lua, 2, dimensions );

				camera->updatePerspective( dimensions.x, dimensions.y );
			}
		}

		return 0;
	}

	LDEC( updateOrthographic )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) && LUA_EXPECT_TABLE( 2 ) )
			{
				Camera* camera = lua_getuserdata<Camera>( lua, 1 );

				glm::vec2 dimensions;
				lua_getvec2( lua, 2, dimensions );

				camera->updateOrthographic( dimensions.x, dimensions.y );
			}
		}

		return 0;
	}

	LDEC( setPosition )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) && LUA_EXPECT_TABLE( 2 ) )
			{
				Camera* camera = lua_getuserdata<Camera>( lua, 1 );

				glm::vec3 position;
				lua_getvec3( lua, 2, position );

				camera->setPosition( position );
			}
		}

		return 0;
	}

	LDEC( setDirection )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) && LUA_EXPECT_TABLE( 2 ) )
			{
				Camera* camera = lua_getuserdata<Camera>( lua, 1 );

				glm::vec3 direction;
				lua_getvec3( lua, 2, direction );

				camera->setDirection( direction );
			}
		}

		return 0;
	}

	LDEC( getPosition )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_TABLE( 1 ) )
			{
				Camera* camera = lua_getuserdata<Camera>( lua, 1 );

				glm::vec3 position = camera->getPosition();

				lua_newtable( lua );
				lua_setvec3( lua, position );
				luaL_setmetatable( lua, "vec3Meta" );
				result = 1;
			}
		}

		return result;
	}

	LDEC( getDirection )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_TABLE( 1 ) )
			{
				Camera* camera = lua_getuserdata<Camera>( lua, 1 );

				glm::vec3 direction = camera->getDirection();

				lua_newtable( lua );
				lua_setvec3( lua, direction );
				luaL_setmetatable( lua, "vec3Meta" );
				result = 1;
			}
		}

		return result;
	}

	LDEC( getForward )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_TABLE( 1 ) )
			{
				Camera* camera = lua_getuserdata<Camera>( lua, 1 );

				glm::vec3 forward = camera->getForward();

				lua_newtable( lua );
				lua_setvec3( lua, forward );
				luaL_setmetatable( lua, "vec3Meta" );
				result = 1;
			}
		}

		return result;
	}

	LDEC( getRight )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_TABLE( 1 ) )
			{
				Camera* camera = lua_getuserdata<Camera>( lua, 1 );

				glm::vec3 right = camera->getRight();

				lua_newtable( lua );
				lua_setvec3( lua, right );
				luaL_setmetatable( lua, "vec3Meta" );
				result = 1;
			}
		}

		return result;
	}

	LDEC( getUp )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_TABLE( 1 ) )
			{
				Camera* camera = lua_getuserdata<Camera>( lua, 1 );

				glm::vec3 up = camera->getUp();

				lua_newtable( lua );
				lua_setvec3( lua, up );
				luaL_setmetatable( lua, "vec3Meta" );
				result = 1;
			}
		}

		return result;
	}
}