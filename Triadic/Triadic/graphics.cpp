#include "graphics.h"
using namespace Rendering;

Graphics::Graphics()
	: worldMatrixQueue( WORLD_MATRIX_QUEUE_INITIAL_CAPACITY ),
	writeIndex( 0 ), readIndex( 1 )
{
}

Graphics::~Graphics()
{
}

void Graphics::load()
{
	shader.load( "./assets/shaders/instanced.vs", NULL, "./assets/shaders/instanced.fs" );

	camera.updatePerspective( WINDOW_WIDTH, WINDOW_HEIGHT );
	camera.setPosition( glm::vec3( 0, 0, -10 ) );

	texture.load( "./assets/textures/palette.dds" );
	texture.upload();
	
	shader.bind();
	projectionLocation = shader.getLocation( "projectionMatrix" );
	viewLocation = shader.getLocation( "viewMatrix" );

	glGenBuffers( 1, &uniformBuffer );
	glBindBuffer( GL_UNIFORM_BUFFER, uniformBuffer );
	glBindBufferRange( GL_UNIFORM_BUFFER, 0, uniformBuffer, 0, sizeof(glm::mat4)*MAX_WORLD_MATRICES );
	glBindBuffer( GL_UNIFORM_BUFFER, 0 );

	textShader.load( "./assets/shaders/font.vs", "./assets/shaders/font.gs", "./assets/shaders/font.fs" );
	textProjectionLocation = textShader.getLocation( "projectionMatrix" );

	orthographicCamera.updateOrthographic( WINDOW_WIDTH, WINDOW_HEIGHT );

	glGenVertexArrays( 1, &textVAO );
	glBindVertexArray( textVAO );

	glEnableVertexAttribArray( 0 );
	glEnableVertexAttribArray( 1 );
	glEnableVertexAttribArray( 2 );
	glEnableVertexAttribArray( 3 );

	glGenBuffers( 1, &textVBO );
	glBindBuffer( GL_ARRAY_BUFFER, textVBO );
	glBufferData( GL_ARRAY_BUFFER, sizeof(Glyph)*GRAPHICS_MAX_GLYPHS, NULL, GL_DYNAMIC_DRAW );

	glVertexAttribPointer( 0, 2, GL_FLOAT, GL_FALSE, sizeof(Glyph), 0 );
	glVertexAttribPointer( 1, 4, GL_FLOAT, GL_FALSE, sizeof(Glyph), (void*)(sizeof(GLfloat)*2) );
	glVertexAttribPointer( 2, 2, GL_FLOAT, GL_FALSE, sizeof(Glyph), (void*)(sizeof(GLfloat)*6) );
	glVertexAttribPointer( 3, 4, GL_FLOAT, GL_FALSE, sizeof(Glyph), (void*)(sizeof(GLfloat)*8) );

	glBindVertexArray( 0 );

	// quads
	if( quadShader.load( "./assets/shaders/quad.vs",
							"./assets/shaders/quad.gs",
							"./assets/shaders/quad.fs" ) )
	{
		quadShader.bind();
		quadProjectionLocation = quadShader.getLocation( "projectionMatrix" );

		glGenVertexArrays( 1, &quadVAO );
		glBindVertexArray( quadVAO );

		glEnableVertexAttribArray( 0 ); // position + size
		glEnableVertexAttribArray( 1 ); // uv start + uv end
		glEnableVertexAttribArray( 2 ); // color

		glGenBuffers( 1, &quadVBO );
		glBindBuffer( GL_ARRAY_BUFFER, quadVBO );
		glBufferData( GL_ARRAY_BUFFER, sizeof(Quad)*GRAPHICS_MAX_QUADS, NULL, GL_DYNAMIC_DRAW );

		glVertexAttribPointer( 0, 4, GL_FLOAT, GL_FALSE, sizeof(Quad), 0 );
		glVertexAttribPointer( 1, 4, GL_FLOAT, GL_FALSE, sizeof(Quad), (void*)(sizeof(GLfloat)*4) );
		glVertexAttribPointer( 2, 4, GL_FLOAT, GL_FALSE, sizeof(Quad), (void*)(sizeof(GLfloat)*8) );

		glBindVertexArray( 0 );
	}
}

void Graphics::finalize()
{
	camera.finalize();
	orthographicCamera.finalize();

	writeIndex = ( writeIndex + 1 ) % 2;
	readIndex = ( readIndex + 1 ) % 2;

	// swap glyphs
	const int GLYPH_COLLECTION_COUNT = glyphCollections.getSize();
	for( int i=0; i<GLYPH_COLLECTION_COUNT; i++ )
		glyphCollections[i].glyphs[writeIndex].clear();

	// swap quads
	const int QUAD_COLLECTION_COUNT = quadCollections.getSize();
	for( int i=0; i<QUAD_COLLECTION_COUNT; i++ )
		quadCollections[i].quads[writeIndex].clear();

	// finalize world matrices
	const int MESH_COUNT = meshQueue.getSize();
	for( int curMesh = 0; curMesh < MESH_COUNT; curMesh++ )
	{
		worldMatrixQueue[curMesh].clear();

		int meshIndex = meshQueue[curMesh];
		const Mesh* mesh = assets.getMesh( meshIndex );
		Array<Transform*>& transforms = transformQueue[curMesh];

		if( mesh->getUploaded() )
		{
			const int transformCount = transforms.getSize();
			for( int curTransform = 0; curTransform < transformCount; curTransform++ )
			{
				if( transforms[curTransform]->getActive() )
				{
					worldMatrixQueue[curMesh].add( transforms[curTransform]->getWorldMatrix() );
				}
			}
		}

		transforms.clear();
	}
}

void Graphics::render()
{
	shader.bind();
	shader.setMat4( projectionLocation, camera.getProjectionMatrix() );
	shader.setMat4( viewLocation, camera.getViewMatrix() );

	texture.bind();

	const int MESH_COUNT = meshQueue.getSize();
	for( int curMesh = 0; curMesh < MESH_COUNT; curMesh++ )
	{
		int meshIndex = meshQueue[curMesh];
		const Mesh* mesh = assets.getMesh( meshIndex );
		Array<glm::mat4>& matrices = worldMatrixQueue[curMesh];

		if( mesh->getUploaded() )
		{
			mesh->bind();

			glBindBuffer( GL_UNIFORM_BUFFER, uniformBuffer );
			glBufferData( GL_UNIFORM_BUFFER, sizeof(glm::mat4)*matrices.getSize(), &matrices.getConstData()[0][0], GL_DYNAMIC_DRAW );

			glDrawElementsInstanced( GL_TRIANGLES, mesh->getIndexCount(), GL_UNSIGNED_INT, NULL, matrices.getSize() );

			glBindBuffer( GL_UNIFORM_BUFFER, 0 );
		}
	}

	// render quads
	glDisable( GL_DEPTH_TEST );
	glEnable( GL_BLEND );
	glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );

	quadShader.bind();
	quadShader.setMat4( quadProjectionLocation, orthographicCamera.getProjectionMatrix() );
	
	glBindVertexArray( quadVAO );
	glBindBuffer( GL_ARRAY_BUFFER, quadVBO );
	
	const int QUAD_COLLECTION_COUNT = quadCollections.getSize();
	for( int curCollection = 0; curCollection < QUAD_COLLECTION_COUNT; curCollection++ )
	{
		QuadCollection& collection = quadCollections[curCollection];
	
		if( collection.texture )
			collection.texture->bind();
		else
			glBindTexture( GL_TEXTURE_2D, 0 );
	
		const int QUAD_COUNT = collection.quads[readIndex].getSize();
		int offset = 0;
		while( offset < QUAD_COUNT )
		{
			int count = QUAD_COUNT - offset;
			if( count > GRAPHICS_MAX_QUADS )
				count = GRAPHICS_MAX_QUADS;
	
			glBufferSubData( GL_ARRAY_BUFFER, 0, sizeof(Quad)*count, collection.quads[readIndex].getData()+offset );
			glDrawArrays( GL_POINTS, 0, count );
	
			offset += count;
		}
	}
	
	glBindVertexArray( 0 );

	// render text
	textShader.bind();
	textShader.setMat4( textProjectionLocation, orthographicCamera.getProjectionMatrix() );

	glBindVertexArray( textVAO );
	glBindBuffer( GL_ARRAY_BUFFER, textVBO );

	const int GLYPH_COLLECTION_COUNT = glyphCollections.getSize();
	for( int curCollection = 0; curCollection < GLYPH_COLLECTION_COUNT; curCollection++ )
	{
		GlyphCollection& collection = glyphCollections[curCollection];

		if( collection.texture )
			collection.texture->bind();
		else
			glBindTexture( GL_TEXTURE_2D, 0 );

		const int GLYPH_COUNT = collection.glyphs[readIndex].getSize();
		int offset = 0;
		while( offset < GLYPH_COUNT )
		{
			int count = GLYPH_COUNT - offset;
			if( count > GRAPHICS_MAX_GLYPHS )
				count = GRAPHICS_MAX_GLYPHS;

			glBufferSubData( GL_ARRAY_BUFFER, 0, sizeof(Glyph)*count, collection.glyphs[readIndex].getData()+offset );
			glDrawArrays( GL_POINTS, 0, count );

			offset += count;
		}
	}

	glBindVertexArray( 0 );

	glEnable( GL_DEPTH_TEST );
	glDisable( GL_BLEND );
}

void Graphics::queueMesh( int meshIndex, Transform* transform )
{
	int index = meshQueue.find( meshIndex );
	if( index < 0 )
	{
		index = meshQueue.getSize();

		meshQueue.append() = meshIndex;
		transformQueue.append();
		worldMatrixQueue.append();
	}

	transformQueue[index].add( transform );
}

void Graphics::queueQuad( int textureIndex, const glm::vec2& position, const glm::vec2& size, const glm::vec2& uvStart, const glm::vec2& uvEnd, const glm::vec4& color )
{
	const Texture* texture = NULL;
	if( textureIndex >= 0 )
		texture = assets.getTexture( textureIndex );

	const int QUAD_COLLECTION_COUNT = quadCollections.getSize();
	int collectionIndex = -1;
	for( int i=0; i<QUAD_COLLECTION_COUNT && collectionIndex < 0; i++ )
		if( quadCollections[i].texture == texture )
			collectionIndex = i;

	if( collectionIndex < 0 )
	{
		QuadCollection& collection = quadCollections.append();
		collection.texture = texture;
		collection.quads[writeIndex].expand( GRAPHICS_MAX_QUADS );
		collection.quads[readIndex].expand( GRAPHICS_MAX_QUADS );

		collectionIndex = QUAD_COLLECTION_COUNT;
	}

	QuadCollection& collection = quadCollections[collectionIndex];
	collection.quads[writeIndex].add( { position, size, uvStart, uvEnd, color } );
}

void Graphics::queueText( int fontIndex, const char* text, const glm::vec2& position, const glm::vec4& color )
{
	const Font* font = assets.getFont( fontIndex );

	const int GLYPH_COLLECTION_COUNT = glyphCollections.getSize();
	int collectionIndex = -1;
	for( int i=0; i<GLYPH_COLLECTION_COUNT && collectionIndex < 0; i++ )
		if( glyphCollections[i].texture == font->getTexture() )
			collectionIndex = i;

	if( collectionIndex < 0 )
	{
		GlyphCollection& collection = glyphCollections.append();
		collection.texture = font->getTexture();
		collection.glyphs[writeIndex].expand( GRAPHICS_MAX_GLYPHS );
		collection.glyphs[readIndex].expand( GRAPHICS_MAX_GLYPHS );

		collectionIndex = GLYPH_COLLECTION_COUNT;
	}

	GlyphCollection& collection = glyphCollections[collectionIndex];

	glm::vec2 offset;
	int index = 0;

	const char* cur = text;
	while( *cur )
	{
		if( *cur == '\n' )
		{
			offset.x = 0;
			offset.y += font->getHeight();
		}
		else if( *cur == '\t' )
		{
			offset.x += font->getWidth( 0 ) * FONT_TAB_WIDTH;
		}
		else if( *cur >= FONT_FIRST && *cur <= FONT_LAST )
		{
			char c = *cur - FONT_FIRST;

			Glyph& glyph = collection.glyphs[writeIndex].append();

			glyph.position = position + offset;

			// avoid sub-pixel positions
			glyph.position.x = (int)( glyph.position.x + 0.5f );
			glyph.position.y = (int)( glyph.position.y + 0.5f );

			font->getUV( c, &glyph.uv );
			glyph.size.x = (float)font->getWidth( c );
			glyph.size.y = (float)font->getHeight();
			glyph.color = color;

			offset.x += glyph.size.x;

			index++;
		}

		cur++;
	}
}

Camera* Graphics::getCamera()
{
	return &camera;
}

Assets* Graphics::getAssets()
{
	return &assets;
}