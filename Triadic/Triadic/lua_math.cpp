#include "lua_math.h"

namespace LuaMath
{
	void bind( lua_State* lua )
	{
		// VEC2
		luaL_newmetatable( lua, "vec2Meta" );
		luaL_Reg vec2Regs[] =
		{
			{ "create", LuaVec2::create },
			{ "copy", LuaVec2::copy },

			{ "dot", LuaVec2::dot },
			{ "normalize", LuaVec2::normalize },
			{ "length", LuaVec2::length },
			{ "distance", LuaVec2::distance },
			
			{ "add", LuaVec2::add },
			{ "sub", LuaVec2::sub },
			{ "mul", LuaVec2::mul },
			{ "div", LuaVec2::div },

			{ NULL, NULL }
		};

		luaL_setfuncs( lua, vec2Regs, 0 );
		lua_pushvalue( lua, -1 );
		lua_setfield( lua, -2, "__index" );
		lua_setglobal( lua, "Vec2" );

		// VEC3
		luaL_newmetatable( lua, "vec3Meta" );
		luaL_Reg vec3Regs[] =
		{
			{ "create", LuaVec3::create },
			{ "copy", LuaVec3::copy },

			{ "dot", LuaVec3::dot },
			{ "normalize", LuaVec3::normalize },
			{ "length", LuaVec3::length },
			{ "distance", LuaVec3::distance },

			{ "add", LuaVec3::add },
			{ "sub", LuaVec3::sub },
			{ "mul", LuaVec3::mul },
			{ "div", LuaVec3::div },

			{ "mulMat", LuaVec3::mulMat },

			{ NULL, NULL }
		};

		luaL_setfuncs( lua, vec3Regs, 0 );
		lua_pushvalue( lua, -1 );
		lua_setfield( lua, -2, "__index" );
		lua_setglobal( lua, "Vec3" );

		// VEC4
		luaL_newmetatable( lua, "vec4Meta" );
		luaL_Reg vec4Regs[] =
		{
			{ "create", LuaVec4::create },
			{ "copy", LuaVec4::copy },

			{ "dot", LuaVec4::dot },
			{ "normalize", LuaVec4::normalize },
			{ "length", LuaVec4::length },
			{ "distance", LuaVec4::distance },

			{ "add", LuaVec4::add },
			{ "sub", LuaVec4::sub },
			{ "mul", LuaVec4::mul },
			{ "div", LuaVec4::div },

			{ NULL, NULL }
		};

		luaL_setfuncs( lua, vec4Regs, 0 );
		lua_pushvalue( lua, -1 );
		lua_setfield( lua, -2, "__index" );
		lua_setglobal( lua, "Vec4" );

		// QUAT
		lua_register( lua, "eulerQuat", LuaQuat::eulerQuat );
		lua_register( lua, "quatToMat", LuaQuat::quatToMat );
	}

	namespace LuaVec2
	{
		LDEC( create )
		{
			int args = lua_gettop( lua );
			if( args <= 0 )
			{
				lua_newtable( lua );

				lua_pushnumber( lua, 0 );
				lua_rawseti( lua, -2, 1 );

				lua_pushnumber( lua, 0 );
				lua_rawseti( lua, -2, 2 );
			}

			luaL_setmetatable( lua, "vec2Meta" );

			return 1;
		}

		LDEC( copy )
		{
			int result = 0;

			int args = lua_gettop( lua );
			if( args >= 1 )
			{
				if( LUA_EXPECT_TABLE( 1 ) )
				{
					glm::vec2 v;
					lua_getvec2( lua, 1, v );

					int tableIndex = 2;
					if( args < 2 )
					{
						lua_newtable( lua );
						tableIndex = -2;
						result = 1;
					}

					lua_setvec2( lua, tableIndex, v );
					luaL_setmetatable( lua, "vec2Meta" );
				}
			}

			return result;
		}

		LDEC( dot )
		{
			int result = 0;

			LUA_EXPECT_ARGS( 2 )
			{
				if( LUA_EXPECT_TABLE( 1 ) &&
					LUA_EXPECT_TABLE( 2 ) )
				{
					glm::vec2 a, b;

					lua_getvec2( lua, 1, a );
					lua_getvec2( lua, 2, b );

					float dot = glm::dot( a, b );
					lua_pushnumber( lua, dot );
					result = 1;
				}
			}

			return result;
		}

		LDEC( normalize )
		{
			int result = 0;

			LUA_EXPECT_ARGS( 1 )
			{
				if( LUA_EXPECT_TABLE( 1 ) )
				{
					glm::vec2 v;

					lua_getvec2( lua, 1, v );

					v = glm::normalize( v );
					
					lua_newtable( lua );
					lua_pushnumber( lua, v.x );
					lua_rawseti( lua, -2, 1 );
					lua_pushnumber( lua, v.y );
					lua_rawseti( lua, -2, 2 );
					result = 1;
				}
			}

			return result;
		}

		LDEC( length )
		{
			int result = 0;

			LUA_EXPECT_ARGS( 1 )
			{
				if( LUA_EXPECT_TABLE( 1 ) )
				{
					glm::vec2 v;
					lua_getvec2( lua, 1, v );

					float len = glm::length( v );
					lua_pushnumber( lua, len );
					result = 1;
				}
			}

			return result;
		}

		LDEC( distance )
		{
			int result = 0;

			LUA_EXPECT_ARGS( 2 )
			{
				if( LUA_EXPECT_TABLE( 1 ) &&
					LUA_EXPECT_TABLE( 2 ) )
				{
					glm::vec2 a, b;
					lua_getvec2( lua, 1, a );
					lua_getvec2( lua, 2, b );

					float distance = glm::distance( a, b );
					lua_pushnumber( lua, distance );
					result = 1;
				}
			}

			return result;
		}

		LDEC( add )
		{
			int result = 0;

			int args = lua_gettop( lua );
			if( args >= 2 )
			{
				if( LUA_EXPECT_TABLE( 1 ) &&
					LUA_EXPECT_TABLE( 2 ) )
				{
					glm::vec2 a, b;

					lua_getvec2( lua, 1, a );
					lua_getvec2( lua, 2, b );

					int tableIndex = 3;
					if( args < 3 )
					{
						lua_newtable( lua );
						tableIndex = -2;
						result = 1;
					}

					glm::vec2 sum = a+b;
					lua_setvec2( lua, tableIndex, sum );
					luaL_setmetatable( lua, "vec2Meta" );
				}
			}

			return result;
		}

		LDEC( sub )
		{
			int result = 0;

			int args = lua_gettop( lua );
			if( args >= 2 )
			{
				if( LUA_EXPECT_TABLE( 1 ) &&
					LUA_EXPECT_TABLE( 2 ) )
				{
					glm::vec2 a, b;

					lua_getvec2( lua, 1, a );
					lua_getvec2( lua, 2, b );

					int tableIndex = 3;
					if( args < 3 )
					{
						lua_newtable( lua );
						tableIndex = -2;
						result = 1;
					}

					glm::vec2 dif = a-b;
					lua_setvec2( lua, tableIndex, dif );
					luaL_setmetatable( lua, "vec2Meta" );
				}
			}

			return result;
		}

		LDEC( mul )
		{
			int result = 0;

			int args = lua_gettop( lua );
			if( args >= 2 )
			{
				if( lua_istable( lua, 1 ) &&
					lua_istable( lua, 2 ) )
				{
					glm::vec2 a, b;

					lua_getvec2( lua, 1, a );
					lua_getvec2( lua, 2, b );

					int tableIndex = 3;
					if( args < 3 )
					{
						lua_newtable( lua );
						tableIndex = -2;
						result = 1;
					}

					glm::vec2 product = a*b;
					lua_setvec2( lua, tableIndex, product );
					luaL_setmetatable( lua, "vec2Meta" );
				}
				else if( lua_istable( lua, 1 ) &&
						lua_isnumber( lua, 2 ) )
				{
					glm::vec2 v;

					lua_getvec2( lua, 1, v );
					float m = lua_tofloat( lua, 2 );

					int tableIndex = 3;
					if( args < 3 )
					{
						lua_newtable( lua );
						tableIndex = -2;
						result = 1;
					}

					glm::vec2 product = v*m;
					lua_setvec2( lua, tableIndex, product );
					luaL_setmetatable( lua, "vec2Meta" );
				}
			}

			return result;
		}

		LDEC( div )
		{
			int result = 0;

			int args = lua_gettop( lua );
			if( args >= 2 )
			{
				if( lua_istable( lua, 1 ) &&
					lua_istable( lua, 2 ) )
				{
					glm::vec2 a, b;

					lua_getvec2( lua, 1, a );
					lua_getvec2( lua, 2, b );

					int tableIndex = 3;
					if( args < 3 )
					{
						lua_newtable( lua );
						tableIndex = -2;
						result = 1;
					}

					glm::vec2 quot = a/b;
					lua_setvec2( lua, tableIndex, quot );
					luaL_setmetatable( lua, "vec2Meta" );
				}
				else if( lua_istable( lua, 1 ) &&
					lua_isnumber( lua, 2 ) )
				{
					glm::vec2 v;

					lua_getvec2( lua, 1, v );
					float m = lua_tofloat( lua, 2 );

					int tableIndex = 3;
					if( args < 3 )
					{
						lua_newtable( lua );
						tableIndex = -2;
						result = 1;
					}

					glm::vec2 product = v/m;
					lua_setvec2( lua, tableIndex, product );
					luaL_setmetatable( lua, "vec2Meta" );
				}
			}

			return result;
		}
	}

	namespace LuaVec3
	{
		LDEC( create )
		{
			int args = lua_gettop( lua );
			if( args <= 0 )
			{
				lua_newtable( lua );

				lua_pushnumber( lua, 0 );
				lua_rawseti( lua, -2, 1 );

				lua_pushnumber( lua, 0 );
				lua_rawseti( lua, -2, 2 );

				lua_pushnumber( lua, 0 );
				lua_rawseti( lua, -2, 3 );
			}

			luaL_setmetatable( lua, "vec3Meta" );

			return 1;
		}

		LDEC( copy )
		{
			int result = 0;

			int args = lua_gettop( lua );
			if( args >= 1 )
			{
				if( LUA_EXPECT_TABLE( 1 ) )
				{
					glm::vec3 v;
					lua_getvec3( lua, 1, v );

					if( args < 2 )
					{
						lua_newtable( lua );

						lua_pushnumber( lua, v.x );
						lua_rawseti( lua, -2, 1 );

						lua_pushnumber( lua, v.y );
						lua_rawseti( lua, -2, 2 );

						lua_pushnumber( lua, v.z );
						lua_rawseti( lua, -2, 3 );

						luaL_setmetatable( lua, "vec3Meta" );

						result = 1;
					}

					//lua_setvec3( lua, 2, v );
					//luaL_setmetatable( lua, "vec3Meta" );
				}
			}

			return result;
		}

		LDEC( dot )
		{
			int result = 0;

			LUA_EXPECT_ARGS( 2 )
			{
				if( LUA_EXPECT_TABLE( 1 ) &&
					LUA_EXPECT_TABLE( 2 ) )
				{
					glm::vec3 a, b;

					lua_getvec3( lua, 1, a );
					lua_getvec3( lua, 2, b );

					float dot = glm::dot( a, b );
					lua_pushnumber( lua, dot );
					result = 1;
				}
			}

			return result;
		}

		LDEC( normalize )
		{
			int result = 0;

			LUA_EXPECT_ARGS( 1 )
			{
				if( LUA_EXPECT_TABLE( 1 ) )
				{
					glm::vec3 v;

					lua_getvec3( lua, 1, v );

					v = glm::normalize( v );

					lua_newtable( lua );
					lua_pushnumber( lua, v.x );
					lua_rawseti( lua, -2, 1 );
					lua_pushnumber( lua, v.y );
					lua_rawseti( lua, -2, 2 );
					lua_pushnumber( lua, v.z );
					lua_rawseti( lua, -2, 3 );
					result = 1;
				}
			}

			return result;
		}

		LDEC( length )
		{
			int result = 0;

			LUA_EXPECT_ARGS( 1 )
			{
				if( LUA_EXPECT_TABLE( 1 ) )
				{
					glm::vec3 v;
					lua_getvec3( lua, 1, v );

					float len = glm::length( v );
					lua_pushnumber( lua, len );
					result = 1;
				}
			}

			return result;
		}

		LDEC( distance )
		{
			int result = 0;

			LUA_EXPECT_ARGS( 2 )
			{
				if( LUA_EXPECT_TABLE( 1 ) &&
					LUA_EXPECT_TABLE( 2 ) )
				{
					glm::vec3 a, b;
					lua_getvec2( lua, 1, a );
					lua_getvec2( lua, 2, b );

					float distance = glm::distance( a, b );
					lua_pushnumber( lua, distance );
					result = 1;
				}
			}

			return result;
		}

		LDEC( add )
		{
			int result = 0;

			int args = lua_gettop( lua );
			if( args >= 2 )
			{
				if( LUA_EXPECT_TABLE( 1 ) &&
					LUA_EXPECT_TABLE( 2 ) )
				{
					glm::vec3 a, b;

					lua_getvec3( lua, 1, a );
					lua_getvec3( lua, 2, b );

					glm::vec3 sum = a+b;

					int tableIndex = 3;
					if( args < 3 )
					{
						lua_newtable( lua );
						tableIndex = -2;
						result = 1;
					}

					lua_setvec3( lua, tableIndex, sum );
					luaL_setmetatable( lua, "vec3Meta" );
				}
			}

			return result;
		}

		LDEC( sub )
		{
			int result = 0;

			int args = lua_gettop( lua );
			if( args >= 2 )
			{
				if( LUA_EXPECT_TABLE( 1 ) &&
					LUA_EXPECT_TABLE( 2 ) )
				{
					glm::vec3 a, b;

					lua_getvec3( lua, 1, a );
					lua_getvec3( lua, 2, b );

					int tableIndex = 3;
					if( args < 3 )
					{
						lua_newtable( lua );
						tableIndex = -2;
						result = 1;
					}

					glm::vec3 dif = a-b;
					lua_setvec3( lua, tableIndex, dif );
					luaL_setmetatable( lua, "vec3Meta" );
				}
			}

			return result;
		}

		LDEC( mul )
		{
			int result = 0;

			int args = lua_gettop( lua );
			if( args >= 2 )
			{
				if( lua_istable( lua, 1 ) &&
					lua_istable( lua, 2 ) )
				{
					glm::vec3 a, b;

					lua_getvec3( lua, 1, a );
					lua_getvec3( lua, 2, b );

					int tableIndex = 3;
					if( args < 3 )
					{
						lua_newtable( lua );
						tableIndex = -2;
						result = 1;
					}

					glm::vec3 product = a*b;
					lua_setvec3( lua, tableIndex, product );
					luaL_setmetatable( lua, "vec3Meta" );
				}
				else if( lua_istable( lua, 1 ) &&
					lua_isnumber( lua, 2 ) )
				{
					glm::vec3 v;

					lua_getvec3( lua, 1, v );
					float m = lua_tofloat( lua, 2 );

					int tableIndex = 3;
					if( args < 3 )
					{
						lua_newtable( lua );
						tableIndex = -2;
						result = 1;
					}

					glm::vec3 product = v*m;
					lua_setvec3( lua, tableIndex, product );
					luaL_setmetatable( lua, "vec3Meta" );
				}
			}

			return result;
		}

		LDEC( div )
		{
			int result = 0;

			int args = lua_gettop( lua );
			if( args >= 2 )
			{
				if( lua_istable( lua, 1 ) &&
					lua_istable( lua, 2 ) )
				{
					glm::vec3 a, b;

					lua_getvec3( lua, 1, a );
					lua_getvec3( lua, 2, b );

					int tableIndex = 3;
					if( args < 3 )
					{
						lua_newtable( lua );
						tableIndex = -2;
						result = 1;
					}

					glm::vec3 quot = a/b;
					lua_setvec3( lua, tableIndex, quot );
					luaL_setmetatable( lua, "vec3Meta" );
				}
				else if( lua_istable( lua, 1 ) &&
					lua_isnumber( lua, 2 ) )
				{
					glm::vec3 v;

					lua_getvec3( lua, 1, v );
					float m = lua_tofloat( lua, 2 );

					int tableIndex = 3;
					if( args < 3 )
					{
						lua_newtable( lua );
						tableIndex = -2;
						result = 1;
					}

					glm::vec3 product = v/m;
					lua_setvec3( lua, tableIndex, product );
					luaL_setmetatable( lua, "vec3Meta" );
				}
			}

			return result;
		}

		LDEC( mulMat )
		{
			int result = 0;

			LUA_EXPECT_ARGS( 2 )
			{
				if( LUA_EXPECT_TABLE( 1 ) &&
					LUA_EXPECT_TABLE( 2 ) )
				{
					glm::vec3 v;
					lua_getvec3( lua, 1, v );
					glm::vec4 v4( v.x, v.y, v.z, 1.0 );

					glm::mat4 m;
					for( int i=0; i<4; i++ )
					{
						for( int j=0; j<4; j++ )
						{
							lua_rawgeti( lua, 2, i*4+j+1 );
							float value = lua_tofloat( lua, -1 );
							m[i][j] = value;
						}
					}

					glm::vec4 f = (v4 * m);
					v.x = f.x;
					v.y = f.y;
					v.z = f.z;

					lua_newtable( lua );
					lua_setvec3( lua, v );

					luaL_setmetatable( lua, "vec3Meta" );

					result = 1;
				}
			}

			return result;
		}
	}

	namespace LuaVec4
	{
		LDEC( create )
		{
			int args = lua_gettop( lua );
			if( args <= 0 )
			{
				lua_newtable( lua );

				lua_pushnumber( lua, 0 );
				lua_rawseti( lua, -2, 1 );

				lua_pushnumber( lua, 0 );
				lua_rawseti( lua, -2, 2 );

				lua_pushnumber( lua, 0 );
				lua_rawseti( lua, -2, 3 );

				lua_pushnumber( lua, 0 );
				lua_rawseti( lua, -2, 4 );
			}

			luaL_setmetatable( lua, "vec4Meta" );

			return 1;
		}

		LDEC( copy )
		{
			int result = 0;

			int args = lua_gettop( lua );
			if( args >= 1 )
			{
				if( LUA_EXPECT_TABLE( 1 ) )
				{
					glm::vec4 v;
					lua_getvec4( lua, 1, v );

					int tableIndex = 2;
					if( args < 2 )
					{
						lua_newtable( lua );
						tableIndex = -2;
						result = 1;
					}

					lua_setvec4( lua, tableIndex, v );
					luaL_setmetatable( lua, "vec4Meta" );
				}
			}

			return result;
		}

		LDEC( dot )
		{
			int result = 0;

			LUA_EXPECT_ARGS( 2 )
			{
				if( LUA_EXPECT_TABLE( 1 ) &&
					LUA_EXPECT_TABLE( 2 ) )
				{
					glm::vec4 a, b;

					lua_getvec4( lua, 1, a );
					lua_getvec4( lua, 2, b );

					float dot = glm::dot( a, b );
					lua_pushnumber( lua, dot );
					result = 1;
				}
			}

			return result;
		}

		LDEC( normalize )
		{
			int result = 0;

			LUA_EXPECT_ARGS( 1 )
			{
				if( LUA_EXPECT_TABLE( 1 ) )
				{
					glm::vec4 v;

					lua_getvec4( lua, 1, v );

					v = glm::normalize( v );

					lua_newtable( lua );
					lua_pushnumber( lua, v.x );
					lua_rawseti( lua, -2, 1 );
					lua_pushnumber( lua, v.y );
					lua_rawseti( lua, -2, 2 );
					lua_pushnumber( lua, v.z );
					lua_rawseti( lua, -2, 3 );
					lua_pushnumber( lua, v.w );
					lua_rawseti( lua, -2, 4 );
					result = 1;
				}
			}

			return result;
		}

		LDEC( length )
		{
			int result = 0;

			LUA_EXPECT_ARGS( 1 )
			{
				if( LUA_EXPECT_TABLE( 1 ) )
				{
					glm::vec4 v;
					lua_getvec4( lua, 1, v );

					float len = glm::length( v );
					lua_pushnumber( lua, len );
					result = 1;
				}
			}

			return result;
		}

		LDEC( distance )
		{
			int result = 0;

			LUA_EXPECT_ARGS( 2 )
			{
				if( LUA_EXPECT_TABLE( 1 ) &&
					LUA_EXPECT_TABLE( 2 ) )
				{
					glm::vec4 a, b;
					lua_getvec4( lua, 1, a );
					lua_getvec4( lua, 2, b );

					float distance = glm::distance( a, b );
					lua_pushnumber( lua, distance );
					result = 1;
				}
			}

			return result;
		}

		LDEC( add )
		{
			int result = 0;

			int args = lua_gettop( lua );
			if( args >= 2 )
			{
				if( LUA_EXPECT_TABLE( 1 ) &&
					LUA_EXPECT_TABLE( 2 ) )
				{
					glm::vec4 a, b;

					lua_getvec4( lua, 1, a );
					lua_getvec4( lua, 2, b );

					int tableIndex = 3;
					if( args < 3 )
					{
						lua_newtable( lua );
						tableIndex = -2;
						result = 1;
					}

					glm::vec4 sum = a+b;
					lua_setvec4( lua, tableIndex, sum );
					luaL_setmetatable( lua, "vec4Meta" );
				}
			}

			return result;
		}

		LDEC( sub )
		{
			int result = 0;

			int args = lua_gettop( lua );
			if( args >= 2 )
			{
				if( LUA_EXPECT_TABLE( 1 ) &&
					LUA_EXPECT_TABLE( 2 ) )
				{
					glm::vec4 a, b;

					lua_getvec4( lua, 1, a );
					lua_getvec4( lua, 2, b );

					int tableIndex = 3;
					if( args < 3 )
					{
						lua_newtable( lua );
						tableIndex = -2;
						result = 1;
					}

					glm::vec4 dif = a-b;
					lua_setvec4( lua, tableIndex, dif );
					luaL_setmetatable( lua, "vec4Meta" );
				}
			}

			return result;
		}

		LDEC( mul )
		{
			int result = 0;

			int args = lua_gettop( lua );
			if( args >= 2 )
			{
				if( lua_istable( lua, 1 ) &&
					lua_istable( lua, 2 ) )
				{
					glm::vec4 a, b;

					lua_getvec4( lua, 1, a );
					lua_getvec4( lua, 2, b );

					int tableIndex = 3;
					if( args < 3 )
					{
						lua_newtable( lua );
						tableIndex = -2;
						result = 1;
					}

					glm::vec4 product = a*b;
					lua_setvec4( lua, tableIndex, product );
					luaL_setmetatable( lua, "vec4Meta" );
				}
				else if( lua_istable( lua, 1 ) &&
					lua_isnumber( lua, 2 ) )
				{
					glm::vec4 v;

					lua_getvec4( lua, 1, v );
					float m = lua_tofloat( lua, 2 );

					int tableIndex = 3;
					if( args < 3 )
					{
						lua_newtable( lua );
						tableIndex = -2;
						result = 1;
					}

					glm::vec4 product = v*m;
					lua_setvec4( lua, tableIndex, product );
					luaL_setmetatable( lua, "vec4Meta" );
				}
			}

			return result;
		}

		LDEC( div )
		{
			int result = 0;

			int args = lua_gettop( lua );
			if( args >= 2 )
			{
				if( lua_istable( lua, 1 ) &&
					lua_istable( lua, 2 ) )
				{
					glm::vec4 a, b;

					lua_getvec4( lua, 1, a );
					lua_getvec4( lua, 2, b );

					int tableIndex = 3;
					if( args < 3 )
					{
						lua_newtable( lua );
						tableIndex = -2;
						result = 1;
					}

					glm::vec4 quot = a/b;
					lua_setvec4( lua, tableIndex, quot );
					luaL_setmetatable( lua, "vec4Meta" );
				}
				else if( lua_istable( lua, 1 ) &&
					lua_isnumber( lua, 2 ) )
				{
					glm::vec4 v;

					lua_getvec4( lua, 1, v );
					float m = lua_tofloat( lua, 2 );

					int tableIndex = 3;
					if( args < 3 )
					{
						lua_newtable( lua );
						tableIndex = -2;
						result = 1;
					}

					glm::vec4 product = v/m;
					lua_setvec4( lua, tableIndex, product );
					luaL_setmetatable( lua, "vec4Meta" );
				}
			}

			return result;
		}
	}

	namespace LuaQuat
	{
		LDEC( eulerQuat )
		{
			int result = 0;

			LUA_EXPECT_ARGS( 1 )
			{
				if( LUA_EXPECT_TABLE( 1 ) )
				{
					glm::vec3 vec;
					lua_getvec3( lua, 1, vec );

					glm::quat q( vec );
					lua_newtable( lua );
					lua_setquat( lua, q );
					result = 1;
				}
			}

			return result;
		}

		LDEC( quatToMat )
		{
			int result = 0;

			LUA_EXPECT_ARGS( 1 )
			{
				if( LUA_EXPECT_TABLE( 1 ) )
				{
					glm::quat q;
					lua_getquat( lua, 1, q );

					glm::mat4 m = glm::toMat4( q );
					lua_newtable( lua );
					for( int i=0; i<4; i++ )
					{
						for( int j=0; j<4; j++ )
						{
							lua_pushnumber( lua, m[i][j] );
							lua_rawseti( lua, -2, i*4+j+1 );
						}
					}

					result = 1;
				}
			}

			return result;
		}
	}
}