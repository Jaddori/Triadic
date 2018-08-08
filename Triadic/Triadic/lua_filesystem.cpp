#include "lua_filesystem.h"

namespace LuaFilesystem
{
	void bind( lua_State* lua )
	{
		luaL_newmetatable( lua, "filesystemMeta" );
		luaL_Reg filesystemRegs[] =
		{
			{ "getFiles", getFiles },
			{ "messageBox", messageBox },

			{ NULL, NULL }
		};

		luaL_setfuncs( lua, filesystemRegs, 0 );
		lua_pushvalue( lua, -1 );
		lua_setfield( lua, -2, "__index" );
		lua_setglobal( lua, "Filesystem" );
	}

	LDEC( getFiles )
	{
		int result = 0;

		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_STRING( 1 ) )
			{
				const char* path = lua_tostring( lua, 1 );

				lua_newtable( lua );

				int index = 1;
				WIN32_FIND_DATAA findData = {};
				HANDLE findHandle = FindFirstFileA( path, &findData );
				if( findHandle != INVALID_HANDLE_VALUE )
				{
					do
					{
						if( ( findData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY ) == 0 )
						{
							lua_pushstring( lua, findData.cFileName );
							lua_rawseti( lua, -2, index );
							index++;
						}
					} while( FindNextFileA( findHandle, &findData ) != 0 );
				}

				result = 1;
			}
		}

		return result;
	}

	LDEC( messageBox )
	{
		LUA_EXPECT_ARGS( 1 )
		{
			if( LUA_EXPECT_STRING( 1 ) )
			{
				const char* text = lua_tostring( lua, 1 );

				MessageBoxA( NULL, text, "Triadic", MB_OK );
			}
		}

		return 0;
	}
}