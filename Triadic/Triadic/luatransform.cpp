#include "luatransform.h"
using namespace Rendering;

namespace LuaTransform
{
	static CoreData* g_coreData;

	void bind( lua_State* lua, CoreData* coreData )
	{
		luaL_newmetatable( lua, "transformMeta" );
		luaL_Reg transformRegs[] =
		{
			{ "create", create },
			{ "destroy", destroy },

			{ "addPosition", addPosition },
			{ "addOrientation", addOrientation },
			{ "addScale", addScale },

			{ "setPosition", setPosition },
			{ "setOrientation", setOrientation },
			{ "setScale", setScale },
			{ "setActive", setActive },

			{ "getPosition", getPosition },
			{ "getOrientation", getOrientation },
			{ "getScale", getScale },
			{ "getActive", getActive },
			{ NULL, NULL }
		};

		luaL_setfuncs( lua, transformRegs, 0 );
		lua_pushvalue( lua, -1 );
		lua_setfield( lua, -2, "__index" );
		lua_setglobal( lua, "Transform" );

		g_coreData = coreData;
	}

	LDEC( create )
	{
		Transform* transform = new Transform();

		lua_newtable( lua );
		lua_pushlightuserdata( lua, transform );
		lua_setfield( lua, -2, "__self" );
		luaL_setmetatable( lua, "transformMeta" );

		return 1;
	}

	LDEC( destroy )
	{
		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_TABLE( 1 ) )
			{
				Transform* transform = lua_getuserdata<Transform>( lua, 1 );
				delete transform;
			}
		}

		return 0;
	}

	LDEC( addPosition )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) && LUA_EXPECT_TABLE( 2 ) )
			{
				Transform* transform = lua_getuserdata<Transform>( lua, 1 );

				glm::vec3 addition;
				lua_getvec3( lua, 2, addition );

				transform->addPosition( addition );
			}
		}

		return 0;
	}

	LDEC( addOrientation )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) && LUA_EXPECT_TABLE( 2 ) )
			{
				Transform* transform = lua_getuserdata<Transform>( lua, 1 );

				glm::quat addition;
				lua_getquat( lua, 2, addition );

				transform->addOrientation( addition );
			}
		}

		return 0;
	}

	LDEC( addScale )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) && LUA_EXPECT_TABLE( 2 ) )
			{
				Transform* transform = lua_getuserdata<Transform>( lua, 1 );

				glm::vec3 addition;
				lua_getvec3( lua, 2, addition );

				transform->addScale( addition );
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
				Transform* transform = lua_getuserdata<Transform>( lua, 1 );

				glm::vec3 position;
				lua_getvec3( lua, 2, position );

				transform->setPosition( position );
			}
		}

		return 0;
	}

	LDEC( setOrientation )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) && LUA_EXPECT_TABLE( 2 ) )
			{
				Transform* transform = lua_getuserdata<Transform>( lua, 1 );

				glm::quat orientation;
				lua_getquat( lua, 2, orientation );

				transform->setOrientation( orientation );
			}
		}

		return 0;
	}

	LDEC( setScale )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) )
			{
				Transform* transform = lua_getuserdata<Transform>( lua, 1 );

				glm::vec3 scale;
				if( lua_istable( lua, 2 ) )
				{
					lua_getvec3( lua, 2, scale );
				}
				else if( lua_isnumber( lua, 2 ) )
				{
					float size = lua_tofloat( lua, 2 );
					scale = glm::vec3( size, size, size );
				}

				transform->setScale( scale );
			}
		}

		return 0;
	}

	LDEC( setActive )
	{
		LUA_EXPECT_ARGS( 2 )
		{
			if( LUA_EXPECT_TABLE( 1 ) && LUA_EXPECT_BOOL( 2 ) )
			{
				Transform* transform = lua_getuserdata<Transform>( lua, 1 );

				bool active = lua_tobool( lua, 2 );
				transform->setActive( active );
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
				Transform* transform = lua_getuserdata<Transform>( lua, 1 );

				lua_newtable( lua );
				lua_setvec3( lua, transform->getPosition() );
				result = 1;
			}
		}

		return result;
	}

	LDEC( getOrientation )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_TABLE( 1 ) )
			{
				Transform* transform = lua_getuserdata<Transform>( lua, 1 );

				lua_newtable( lua );
				lua_setquat( lua, transform->getOrientation() );
				result = 1;
			}
		}

		return result;
	}

	LDEC( getScale )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_TABLE( 1 ) )
			{
				Transform* transform = lua_getuserdata<Transform>( lua, 1 );

				lua_newtable( lua );
				lua_setvec3( lua, transform->getScale() );
				result = 1;
			}
		}

		return result;
	}

	LDEC( getActive )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_TABLE( 1 ) )
			{
				Transform* transform = lua_getuserdata<Transform>( lua, 1 );

				lua_pushboolean( lua, transform->getActive() );
				result = 1;
			}
		}

		return result;
	}
}