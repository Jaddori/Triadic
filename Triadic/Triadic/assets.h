#pragma once

#include "common.h"
#include "texture.h"
#include "mesh.h"
#include "font.h"

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
		int loadFont( const char* info, const char* texture );

		const Texture* getTexture( int index ) const;
		const Mesh* getMesh( int index ) const;
		const Font* getFont( int index ) const;

	private:
		uint64_t hashPath( const char* path );

		Array<uint64_t> textureHashes;
		Array<Texture> textures;
		bool dirtyTextures;

		Array<uint64_t> meshHashes;
		Array<Mesh> meshes;
		bool dirtyMeshes;

		Array<uint64_t> fontHashes;
		Array<Font> fonts;
		bool dirtyFonts;
	};
}