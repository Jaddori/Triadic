#include "scripting.h"
using namespace Scripting;

Script::Script()
	: lua( NULL ),
	loadFunctionReference( -1 ),
	unloadFunctionReference( -1 ),
	updateFunctionReference( -1 ),
	renderFunctionReference( -1 ),
	clientWriteFunctionReference( -1 ),
	serverWriteFunctionReference( -1 )
{
}

Script::~Script()
{
	if( lua )
		lua_close( lua );
}

bool Script::bind( CoreData* coreData, bool _isServer )
{
	_coreData = coreData;
	isServer = _isServer;

	valid = true;
	LOG_INFO( "Initializing script backend." );

	lua = luaL_newstate();
	if( lua )
	{
		luaL_openlibs( lua );

		// set global variables
		lua_pushnumber( lua, WINDOW_WIDTH );
		lua_setglobal( lua, "WINDOW_WIDTH" );
		lua_pushnumber( lua, WINDOW_HEIGHT );
		lua_setglobal( lua, "WINDOW_HEIGHT" );

		lua_pushboolean( lua, isServer );
		lua_setglobal( lua, "IS_SERVER" );
		lua_pushboolean( lua, !isServer );
		lua_setglobal( lua, "IS_CLIENT" );

		lua_pushnumber( lua, TIMESTEP_MS );
		lua_setglobal( lua, "TIMESTEP_MS" );
		lua_pushnumber( lua, TIMESTEP_PER_SEC );
		lua_setglobal( lua, "TIMESTEP_PER_SEC" );

		// bind subsystems
		LuaRendering::bind( lua, coreData );
		LuaInput::bind( lua, coreData );
		LuaAssets::bind( lua, coreData );
		LuaTransform::bind( lua, coreData );
		LuaSystemInfo::bind( lua, coreData );
		LuaCamera::bind( lua, coreData );
		LuaLog::bind( lua, coreData );
		LuaShapes::bind( lua, coreData );
		LuaFilesystem::bind( lua );
		LuaPhysics::bind( lua, coreData );
		LuaMath::bind( lua );
		LuaCore::bind( lua, coreData );
		LuaMessage::bind( lua );
		LuaClient::bind( lua, coreData );
		LuaServer::bind( lua, coreData );

		// load main script
		lua_getglobal( lua, "debug" );
		lua_getfield( lua, -1, "traceback" );
		lua_replace( lua, -2 );

		LOG_INFO( "Loading main script." );
		if( luaL_loadfile( lua, LUA_MAIN_SCRIPT ) != 0 )
		{
			LOG_ERROR( "Failed to load main script." );
			LOG_ERROR( "%s", lua_tostring( lua, -1 ) );

			valid = false;
		}
		else
		{
			LOG_INFO( "Running main script." );

			if( lua_pcall( lua, 0, 0, -2 ) != 0 )
			{
				LOG_ERROR( "Failed to run main script." );
				LOG_ERROR( "%s", lua_tostring( lua, -1 ) );

				valid = false;
			}
			else
			{
				lua_pop( lua, 1 ); // remove traceback error function

				// get load function
				lua_getglobal( lua, "mainLoad" );
				if( !lua_isfunction( lua, -1 ) )
				{
					LOG_ERROR( "Failed to find main load function." );
					valid = false;
				}
				else
					loadFunctionReference = luaL_ref( lua, LUA_REGISTRYINDEX );

				// get unload function
				lua_getglobal( lua, "mainUnload" );
				if( !lua_isfunction( lua, -1 ) )
				{
					LOG_ERROR( "Failed to find main unload function." );
					valid = false;
				}
				else
					unloadFunctionReference = luaL_ref( lua, LUA_REGISTRYINDEX );

				// get update function
				lua_getglobal( lua, "mainUpdate" );
				if( !lua_isfunction( lua, -1 ) )
				{
					LOG_ERROR( "Failed to find main update function." );
					valid = false;
				}
				else
					updateFunctionReference = luaL_ref( lua, LUA_REGISTRYINDEX );

				// get fixed u
				lua_getglobal( lua, "mainFixedUpdate" );
				if( !lua_isfunction( lua, -1 ) )
				{
					LOG_ERROR( "Failed to find main fixed update function." );
					valid = false;
				}
				else
					fixedUpdateFunctionReference = luaL_ref( lua, LUA_REGISTRYINDEX );

				// get render function
				lua_getglobal( lua, "mainRender" );
				if( !lua_isfunction( lua, -1 ) )
				{
					LOG_ERROR( "Failed to find main render function." );
					valid = false;
				}
				else
					renderFunctionReference = luaL_ref( lua, LUA_REGISTRYINDEX );

				if( isServer )
				{
					// get server write function
					lua_getglobal( lua, "mainServerWrite" );
					if( !lua_isfunction( lua, -1 ) )
					{
						LOG_ERROR( "Failed to find main server write function." );
						valid = false;
					}
					else
						serverWriteFunctionReference = luaL_ref( lua, LUA_REGISTRYINDEX );
				}
				else
				{
					// get client write function
					lua_getglobal( lua, "mainClientWrite" );
					if( !lua_isfunction( lua, -1 ) )
					{
						LOG_ERROR( "Failed to find main client write function." );
						valid = false;
					}
					else
						clientWriteFunctionReference = luaL_ref( lua, LUA_REGISTRYINDEX );
				}
			}
		}
	}
	else
	{
		LOG_ERROR( "Failed to initialize script backend." );
		valid = false;
	}

	if( !valid )
	{
		lua_close( lua );
		lua = NULL;
	}

	return valid;
}

void Script::update( float deltaTime )
{
	if( valid )
	{
		lua_getglobal( lua, "debug" );
		lua_getfield( lua, -1, "traceback" );
		lua_replace( lua, -2 );

		lua_rawgeti( lua, LUA_REGISTRYINDEX, updateFunctionReference );
		lua_pushnumber( lua, deltaTime );
		if( lua_pcall( lua, 1, 0, -3 ) != 0 )
		{
			LOG_ERROR( "Failed to run update function." );
			LOG_ERROR( "%s", lua_tostring( lua, -1 ) );

			valid = false;
		}
		else
			lua_pop( lua, 1 );
	}
}

void Script::fixedUpdate( float timestep )
{
	if( valid )
	{
		lua_getglobal( lua, "debug" );
		lua_getfield( lua, -1, "traceback" );
		lua_replace( lua, -2 );

		lua_rawgeti( lua, LUA_REGISTRYINDEX, fixedUpdateFunctionReference );
		lua_pushnumber( lua, timestep );
		if( lua_pcall( lua, 1, 0, -3 ) != 0 )
		{
			LOG_ERROR( "Failed to run fixed update function." );
			LOG_ERROR( "%s", lua_tostring( lua, -1 ) );

			valid = false;
		}
		else
			lua_pop( lua, 1 );
	}
}

void Script::run( int functionReference, const char* debugName )
{
	if( valid )
	{
		lua_getglobal( lua, "debug" );
		lua_getfield( lua, -1, "traceback" );
		lua_replace( lua, -2 );

		lua_rawgeti( lua, LUA_REGISTRYINDEX, functionReference );
		if( lua_pcall( lua, 0, 0, -2 ) != 0 )
		{
			LOG_ERROR( "Failed to run function reference for: %s", debugName );
			LOG_ERROR( "%s", lua_tostring( lua, -1 ) );
			valid = false;
		}
		else
			lua_pop( lua, 1 );
	}
}

void Script::reload()
{
	system( "cls" );
	LOG_DEBUG( "RELOADING" );

	if( lua )
		lua_close( lua );
	bind( _coreData, isServer );
	load();
}

void Script::setGlobal( const char* name, bool value )
{
	lua_pushboolean( lua, value );
	lua_setglobal( lua, name );
}

void Script::setGlobal( const char* name, int value )
{
	lua_pushnumber( lua, value );
	lua_setglobal( lua, name );
}

void Script::setGlobal( const char* name, float value )
{
	lua_pushnumber( lua, value );
	lua_setglobal( lua, name );
}

void Script::setGlobal( const char* name, const char* value )
{
	lua_pushstring( lua, value );
	lua_setglobal( lua, name );
}