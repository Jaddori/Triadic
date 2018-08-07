#pragma once

#include "common.h"
#include "texture.h"
#include "mesh.h"

namespace Rendering
{
	class Assets
	{
	public:
		Assets();
		~Assets();

		void unload();
		void upload();

		int loadTexture( const char* path );
		int loadMesh( const char* path );

		const Texture* getTexture( int index ) const;
		const Mesh* getMesh( int index ) const;

	private:
		uint64_t hashPath( const char* path );

		Array<int> textureHashes;
		Array<Texture> textures;
		bool dirtyTextures;

		Array<int> meshHashes;
		Array<Mesh> meshes;
		bool dirtyMeshes;
	};
}