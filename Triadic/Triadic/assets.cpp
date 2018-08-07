#include "assets.h"
using namespace Rendering;

Assets::Assets()
	: dirtyTextures( false ), dirtyMeshes( false )
{
}

Assets::~Assets()
{
}

void Assets::unload()
{
	for( int i=0; i<textures.getSize(); i++ )
		textures[i].unload();

	for( int i=0; i<meshes.getSize(); i++ )
		meshes[i].unload();

	textureHashes.clear();
	textures.clear();

	meshHashes.clear();
	meshes.clear();
}

void Assets::upload()
{
	if( dirtyTextures )
	{
		LOG_INFO( "Uploading textures." );

		for( int i=0; i<textures.getSize(); i++ )
			textures[i].upload();

		dirtyTextures = false;
	}

	if( dirtyMeshes )
	{
		LOG_INFO( "Uploading meshes." );

		for( int i=0; i<meshes.getSize(); i++ )
			meshes[i].upload();

		dirtyMeshes = false;
	}
}

int Assets::loadTexture( const char* path )
{
	uint64_t hash = hashPath( path );
	int result = textureHashes.find( hash );
	if( result < 0 )
	{
		Texture texture;
		if( texture.load( path ) )
		{
			result = textures.getSize();
			textures.add( texture );
			textureHashes.add( hash );

			dirtyTextures = true;
		}
	}

	return result;
}

int Assets::loadMesh( const char* path )
{
	uint64_t hash = hashPath( path );
	int result = meshHashes.find( hash );
	if( result < 0 )
	{
		Mesh mesh;
		if( mesh.load( path ) )
		{
			result = meshes.getSize();
			meshes.add( mesh );
			meshHashes.add( hash );

			dirtyMeshes = true;
		}
	}

	return result;
}

const Texture* Assets::getTexture( int index ) const
{
	LOG_ASSERT( index >= 0 && index < textures.getSize(), "Index %d out of range %d.", index, textures.getSize() );

	return &textures[index];
}

const Mesh* Assets::getMesh( int index ) const
{
	LOG_ASSERT( index >= 0 && index < meshes.getSize(), "Index %d out of range %d.", index, meshes.getSize() );

	return &meshes[index];
}

uint64_t Assets::hashPath( const char* path )
{
	uint64_t hash = 5381;
	int c;

	while( c = *path++ )
		hash = ((hash << 5) + hash) + c; /* hash * 33 + c */

	return hash;
}