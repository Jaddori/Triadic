#include "level.h"

Level::Level()
{
}

Level::~Level()
{
}

bool Level::load( const char* path )
{
	bool result = false;

	LOG_INFO( "Loading level from: %s", path );

	FILE* file = fopen( path, "rb" );
	if( file )
	{
		result = true;

		fseek( file, 0, SEEK_END );
		int len = ftell( file );
		fseek( file, 0, SEEK_SET );

		if( len > CORE_DATA_TRANSIENT_MEMORY_SIZE+1 )
		{
			LOG_ERROR( "Not enough transient memory." );
			result = false;
		}
		else
		{
			fread( coreData->transientMemory, 1, len, file );
			coreData->transientMemory[len+1] = 0;

			char* cur = coreData->transientMemory;
			int x = 0, z = 0;
			while( *cur )
			{
				// remove whitespace
				while( *cur && ( isWhitespace( *cur ) || isNewline( *cur ) ) )
					cur++;

				if( *cur )
				{
					// get word
					while( *cur && !isNewline( *cur ) )
					{
						int id = charToInt( *cur );

						if( id > 0 )
						{
							Prop& prop = props.append();
							prop.load( "./assets/models/floor.mesh" );

							Transform& transform = prop.getTransform();
							transform.setPosition( glm::vec3( x*10, 0, z*10 ) );
						}

						x++;
						cur++;
					}

					z++;
					x = 0;
				}
			}
		}

		fclose( file );
	}
	else
	{
		LOG_ERROR( "Failed to open file: %s", path );
	}

	return result;
}

void Level::render()
{
	const int PROP_COUNT = props.getSize();
	for( int i=0; i<PROP_COUNT; i++ )
	{
		props[i].render();
	}
}