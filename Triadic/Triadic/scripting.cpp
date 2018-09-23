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

bool Script::bind( CoreData* coreData, bool _isServer, bool _isHost )
{
	_coreData = coreData;
	isServer = _isServer;
	isHost = _isHost;

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
		lua_pushboolean( lua, isHost );
		lua_setglobal( lua, "IS_HOST" );

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

				// getting function references
				loadFunctionReference = findFunctionReference( "mainLoad" );
				unloadFunctionReference = findFunctionReference( "mainUnload" );
				updateFunctionReference = findFunctionReference( "mainUpdate" );
				fixedUpdateFunctionReference = findFunctionReference( "mainFixedUpdate" );
				renderFunctionReference = findFunctionReference( "mainRender" );
				
				if( isServer )
				{
					// get server specific function references
					serverWriteFunctionReference = findFunctionReference( "mainServerWrite" );
					serverReadFunctionReference = findFunctionReference( "mainServerRead" );
				}
				else
				{
					// get client specific function references
					clientWriteFunctionReference = findFunctionReference( "mainClientWrite" );
					clientReadFunctionReference = findFunctionReference( "mainClientRead" );
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
	bind( _coreData, isServer, isHost );
	load();
}

int Script::findFunctionReference( const char* name )
{
	int result = -1;

	lua_getglobal( lua, name );
	if( !lua_isfunction( lua, -1 ) )
	{
		LOG_ERROR( "Failed to find function reference \"%s\".", name );
		valid = false;
	}
	else
		result = luaL_ref( lua, LUA_REGISTRYINDEX );

	return result;
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