#pragma once

#include "Log.h"
#include "GLM\glm.hpp"
#include "LUA\lua.hpp"

#define LDEC( name ) int name( lua_State* lua )

#define LUA_EXPECT_ARGS( expected ) \
	int args = lua_gettop( lua ); \
	if( args != expected ) \
	{ \
		LOG_ERROR( "Expected " #expected " argument(s). Got %d.", args ); \
	} \
	else

#define LUA_EXPECT_BOOL( index ) isbool( lua, index )
#define LUA_EXPECT_NUMBER( index ) isnumber( lua, index )
#define LUA_EXPECT_STRING( index ) isstring( lua, index )
#define LUA_EXPECT_USERDATA( index ) isuserdata( lua, index )
#define LUA_EXPECT_TABLE( index ) istable( lua, index )

inline bool isbool( lua_State* lua, int index )
{
	bool result = ( lua_isboolean( lua, index ) != 0 );
	if( !result )
	{
		LOG_ERROR( "Expected bool as argument #%d.", index );
	}
	return result;
}

inline bool isnumber( lua_State* lua, int index )
{
	bool result = ( lua_isnumber( lua, index ) != 0 );
	if( !result )
	{
		LOG_ERROR( "Expected number as argument #%d.", index );
	}
	return result;
}

inline bool isstring( lua_State* lua, int index )
{
	bool result = ( lua_isstring( lua, index ) != 0 );
	if( !result )
	{
		LOG_ERROR( "Expected string as argument #%d.", index );
	}
	return result;
}

inline bool isuserdata( lua_State* lua, int index )
{
	bool result = ( lua_isuserdata( lua, index ) != 0 );
	if( !result )
	{
		LOG_ERROR( "Expected userdata as argument #%d.", index );
	}
	return result;
}

inline bool istable( lua_State* lua, int index )
{
	bool result = ( lua_istable( lua, index ) != 0 );
	if( !result )
	{
		LOG_ERROR( "Expected table as argument #%d.", index );
	}
	return result;
}

#define lua_tofloat( state, index ) (float)lua_tonumber( state, index )
#define lua_toint( state, index) (int)lua_tonumber( state, index )
#define lua_tobool( state, index ) (lua_toboolean( state, index ) > 0)

inline float lua_getfloat( lua_State* lua, int tableIndex, int fieldIndex )
{
	lua_rawgeti( lua, tableIndex, fieldIndex );
	LUA_EXPECT_NUMBER( -1 );
	return lua_tofloat( lua, -1 );
}

inline float lua_getfloat( lua_State* lua, int tableIndex, const char* field )
{
	lua_getfield( lua, tableIndex, field );
	LUA_EXPECT_NUMBER( -1 );
	return lua_tofloat( lua, -1 );
}

inline int lua_getint( lua_State* lua, int tableIndex, int fieldIndex )
{
	lua_rawgeti( lua, tableIndex, fieldIndex );
	LUA_EXPECT_NUMBER( -1 );
	return lua_toint( lua, -1 );
}

inline int lua_getint( lua_State* lua, int tableIndex, const char* field )
{
	lua_getfield( lua, tableIndex, field );
	LUA_EXPECT_NUMBER( -1 );
	return lua_toint( lua, -1 );
}

inline const char* lua_getstring( lua_State* lua, int tableIndex, int fieldIndex )
{
	lua_rawgeti( lua, tableIndex, fieldIndex );
	LUA_EXPECT_STRING( -1 );
	return lua_tostring( lua, -1 );
}

inline const char* lua_getstring( lua_State* lua, int tableIndex, const char* field )
{
	lua_getfield( lua, tableIndex, field );
	LUA_EXPECT_STRING( -1 );
	return lua_tostring( lua, -1 );
}

#define lua_getvec2( state, index, vec ) \
	vec.x = lua_getfloat( state, index, 1 ); \
	vec.y = lua_getfloat( state, index, 2 )

#define lua_getvec3( state, index, vec ) \
	lua_getvec2( state, index, vec ); \
	vec.z = lua_getfloat( state, index, 3 )

#define lua_getvec4( state, index, vec ) \
	lua_getvec3( state, index, vec ); \
	vec.w = lua_getfloat( state, index, 4 )

#define lua_getquat( state, index, q ) lua_getvec4( state, index, q )

template<typename T>
inline T* lua_getuserdata( lua_State* lua, int index )
{
	lua_getfield( lua, index, "__self" );
	LUA_EXPECT_USERDATA( -1 );
	return (T*)lua_touserdata( lua, -1 );
}

inline void lua_setnumber( lua_State* lua, int tableIndex, int fieldIndex, float value )
{
	lua_pushnumber( lua, value );
	lua_rawseti( lua, tableIndex, fieldIndex );
}

inline void lua_setnumber( lua_State* lua, int fieldIndex, float value )
{
	lua_pushnumber( lua, value );
	lua_rawseti( lua, -2, fieldIndex );
}

inline void lua_setnumber( lua_State* lua, int tableIndex, const char* field, float value )
{
	lua_pushnumber( lua, value );
	lua_setfield( lua, tableIndex, field );
}

inline void lua_setnumber( lua_State* lua, const char* field, float value )
{
	lua_pushnumber( lua, value );
	lua_setfield( lua, -2, field );
}

inline void lua_setnumber( lua_State* lua, int tableIndex, int fieldIndex, int value )
{
	lua_pushnumber( lua, value );
	lua_rawseti( lua, tableIndex, fieldIndex );
}

inline void lua_setnumber( lua_State* lua, int fieldIndex, int value )
{
	lua_pushnumber( lua, value );
	lua_rawseti( lua, -2, fieldIndex );
}

inline void lua_setnumber( lua_State* lua, int tableIndex, const char* field, int value )
{
	lua_pushnumber( lua, value );
	lua_setfield( lua, tableIndex, field );
}

inline void lua_setnumber( lua_State* lua, const char* field, int value )
{
	lua_pushnumber( lua, value );
	lua_setfield( lua, -2, field );
}

inline void lua_setstring( lua_State* lua, int tableIndex, int fieldIndex, const char* str )
{
	lua_pushstring( lua, str );
	lua_rawseti( lua, tableIndex, fieldIndex );
}

inline void lua_setstring( lua_State* lua, int fieldIndex, const char* str )
{
	lua_pushstring( lua, str );
	lua_rawseti( lua, -2, fieldIndex );
}

inline void lua_setstring( lua_State* lua, int tableIndex, const char* field, const char* str )
{
	lua_pushstring( lua, str );
	lua_setfield( lua, tableIndex, field );
}

inline void lua_setstring( lua_State* lua, const char* field, const char* str )
{
	lua_pushstring( lua, str );
	lua_setfield( lua, -2, field );
}

inline void lua_setvec2( lua_State* lua, int tableIndex, const glm::vec2& vec )
{
	lua_setnumber( lua, tableIndex, 1, vec.x );
	lua_setnumber( lua, tableIndex, 2, vec.y );
}

inline void lua_setvec2( lua_State* lua, const glm::vec2& vec )
{
	lua_setnumber( lua, -2, 1, vec.x );
	lua_setnumber( lua, -2, 2, vec.y );
}

inline void lua_setvec3( lua_State* lua, int tableIndex, const glm::vec3& vec )
{
	lua_setnumber( lua, tableIndex, 1, vec.x );
	lua_setnumber( lua, tableIndex, 2, vec.y );
	lua_setnumber( lua, tableIndex, 3, vec.z );
}

inline void lua_setvec3( lua_State* lua, const glm::vec3& vec )
{
	lua_setnumber( lua, -2, 1, vec.x );
	lua_setnumber( lua, -2, 2, vec.y );
	lua_setnumber( lua, -2, 3, vec.z );
}

inline void lua_setvec4( lua_State* lua, int tableIndex, const glm::vec4& vec )
{
	lua_setnumber( lua, tableIndex, 1, vec.x );
	lua_setnumber( lua, tableIndex, 2, vec.y );
	lua_setnumber( lua, tableIndex, 3, vec.z );
	lua_setnumber( lua, tableIndex, 4, vec.w );
}

inline void lua_setvec4( lua_State* lua, const glm::vec4& vec )
{
	lua_setnumber( lua, -2, 1, vec.x );
	lua_setnumber( lua, -2, 2, vec.y );
	lua_setnumber( lua, -2, 3, vec.z );
	lua_setnumber( lua, -2, 4, vec.w );
}

inline void lua_setquat( lua_State* lua, int tableIndex, const glm::quat& q )
{
	lua_setnumber( lua, tableIndex, 1, q.x );
	lua_setnumber( lua, tableIndex, 2, q.y );
	lua_setnumber( lua, tableIndex, 3, q.z );
	lua_setnumber( lua, tableIndex, 4, q.w );
}

inline void lua_setquat( lua_State* lua, const glm::quat& q )
{
	lua_setnumber( lua, -2, 1, q.x );
	lua_setnumber( lua, -2, 2, q.y );
	lua_setnumber( lua, -2, 3, q.z );
	lua_setnumber( lua, -2, 4, q.w );
}

inline void lua_setuserdata( lua_State* lua, int index, const char* name, void* data )
{
	lua_pushlightuserdata( lua, data );
	lua_setfield( lua, index, name );
}

inline void lua_setuserdata( lua_State* lua, const char* name, void* data )
{
	lua_pushlightuserdata( lua, data );
	lua_setfield( lua, -2, name );
}

inline void lua_setuserdata( lua_State* lua, int index, void* data )
{
	lua_pushlightuserdata( lua, data );
	lua_setfield( lua, index, "__self" );
}

inline void lua_setuserdata( lua_State* lua, void* data )
{
	lua_pushlightuserdata( lua, data );
	lua_setfield( lua, -2, "__self" );
}
