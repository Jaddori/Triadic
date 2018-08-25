#include "graphics.h"
using namespace Rendering;

Graphics::Graphics()
	: worldMatrixQueue( WORLD_MATRIX_QUEUE_INITIAL_CAPACITY ),
	writeIndex( 0 ), readIndex( 1 ), lightingEnabled( false )
{
}

Graphics::~Graphics()
{
}

void Graphics::load()
{
	if( !gbuffer.load( &assets, WINDOW_WIDTH, WINDOW_HEIGHT ) )
	{
		LOG( VERBOSITY_ERROR, "Failed to load gbuffer." );
	}

	shader.load( "./assets/shaders/instanced.vs", NULL, "./assets/shaders/instanced.fs" );

	perspectiveCamera.updatePerspective( WINDOW_WIDTH, WINDOW_HEIGHT );
	perspectiveCamera.setPosition( glm::vec3( 0, 0, -10 ) );

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

	// billboards
	LOG_INFO( "Loading billboard shader." );
	if( billboardShader.load( "./assets/shaders/billboard.vs",
		"./assets/shaders/billboard.gs",
		"./assets/shaders/billboard.fs" ) )
	{
		LOG_INFO( "Retrieving uniform locations from billboard shader." );
		billboardProjectionLocation = billboardShader.getLocation( "projectionMatrix" );
		billboardViewLocation = billboardShader.getLocation( "viewMatrix" );
		billboardDeltaTimeLocation = billboardShader.getLocation( "deltaTime" );

		LOG_INFO( "Generating vertex data for billboard shader." );
		glGenVertexArrays( 1, &billboardVAO );
		glBindVertexArray( billboardVAO );

		glEnableVertexAttribArray( 0 );
		glEnableVertexAttribArray( 1 );
		glEnableVertexAttribArray( 2 );
		glEnableVertexAttribArray( 3 );
		glEnableVertexAttribArray( 4 );

		glGenBuffers( 1, &billboardVBO );
		glBindBuffer( GL_ARRAY_BUFFER, billboardVBO );
		glBufferData( GL_ARRAY_BUFFER, sizeof(Billboard)*GRAPHICS_MAX_BILLBOARDS, nullptr, GL_STREAM_DRAW );

		glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, sizeof(Billboard), 0 );
		glVertexAttribPointer( 1, 4, GL_FLOAT, GL_FALSE, sizeof(Billboard), (void*)(sizeof(GLfloat)*3) );
		glVertexAttribPointer( 2, 2, GL_FLOAT, GL_FALSE, sizeof(Billboard), (void*)(sizeof(GLfloat)*7 ) );
		glVertexAttribPointer( 3, 1, GL_FLOAT, GL_FALSE, sizeof(Billboard), (void*)( sizeof(GLfloat)*9) );
		glVertexAttribPointer( 4, 3, GL_FLOAT, GL_FALSE, sizeof(Billboard), (void*)( sizeof(GLfloat)*10) );

		glBindVertexArray( 0 );
	}
	else
	{
		LOG_ERROR( "Failed to load billboard shader." );
	}

	int normalIndex = assets.loadTexture( "./assets/textures/normal.dds" );
	int specularIndex = assets.loadTexture( "./assets/textures/specular.dds" );

	normalMap = assets.getTexture( normalIndex );
	specularMap = assets.getTexture( specularIndex );

	DirectionalLight& light = directionalLights.append();
	light.color = glm::vec3( 1.0f, 0.0f, 0.0f );
	light.direction = glm::normalize( glm::vec3( 1, -1, 1 ) );
	light.intensity = 2.0f;

	PointLight& pointLight = pointLights.append();
	pointLight.position = glm::vec3( -1, 1, -1 );
	pointLight.color = glm::vec3( 0.0f, 0.0f, 1.0f );
	pointLight.intensity = 2.0f;
	pointLight.linear = 1.0f;
	pointLight.constant = 1.0f;
	pointLight.exponent = 2.0f;
}

void Graphics::finalize()
{
	static float sinval = 0.0f;
	sinval += 0.001f;

	float x = sinf( sinval );
	float z = cosf( sinval );

	directionalLights[0].direction = glm::normalize( glm::vec3( x, -1, z ) );

	perspectiveCamera.finalize();
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

	// swap billboards
	const int BILLBOARD_COLLECTION_COUNT = billboardCollections.getSize();
	for( int i=0; i<BILLBOARD_COLLECTION_COUNT; i++ )
		billboardCollections[i].billboards[writeIndex].clear();

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

void Graphics::render( float deltaTime )
{
	elapsedTime += deltaTime;

	if( lightingEnabled )
	{
		renderDeferred();
		renderForward();
	}
	else
	{
		renderBasic();
	}
}

void Graphics::renderDeferred()
{
	gbuffer.begin();

	// GEOMETRY PASS
	gbuffer.beginGeometryPass( &perspectiveCamera );

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

			//gbuffer.updateGeometryWorldMatrices( matrices.getConstData(), matrices.getSize() );

			gbuffer.updateGeometryTextures( &texture, normalMap, specularMap );

			glDrawElementsInstanced( GL_TRIANGLES, mesh->getIndexCount(), GL_UNSIGNED_INT, NULL, matrices.getSize() );

			glBindBuffer( GL_UNIFORM_BUFFER, 0 );
		}
	}

	gbuffer.endGeometryPass();

	// DIRECTIONAL LIGHT PASS
	const int DIRECTIONAL_LIGHT_COUNT = directionalLights.getSize();
	for( int curLight = 0; curLight < DIRECTIONAL_LIGHT_COUNT; curLight++ )
	{
		const DirectionalLight& light = directionalLights[curLight];

		// render shadow
		gbuffer.beginDirectionalShadowPass( &perspectiveCamera, light );
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

				//gbuffer.updateGeometryWorldMatrices( matrices.getConstData(), matrices.getSize() );

				gbuffer.updateGeometryTextures( &texture, normalMap, specularMap );

				glDrawElementsInstanced( GL_TRIANGLES, mesh->getIndexCount(), GL_UNSIGNED_INT, NULL, matrices.getSize() );

				glBindBuffer( GL_UNIFORM_BUFFER, 0 );
			}
		}
		gbuffer.endDirectionalShadowPass();

		// render light
		gbuffer.beginDirectionalLightPass( TARGET_LIGHT, &perspectiveCamera );
		gbuffer.renderDirectionalLight( &perspectiveCamera, light );
		gbuffer.endDirectionalLightPass();
	}

	// POINT LIGHT PASS
	gbuffer.beginPointLightPass( TARGET_LIGHT, &perspectiveCamera );

	const int POINT_LIGHT_COUNT = pointLights.getSize();
	for( int curLight=0; curLight < POINT_LIGHT_COUNT; curLight++ )
	{
		gbuffer.renderPointLight( pointLights[curLight] );
	}

	gbuffer.endPointLightPass();

	// BILLBOARDS
	gbuffer.beginBillboardPass( &perspectiveCamera );

	Array<Billboard> bbs;
	Billboard& bb = bbs.append();
	bb.position = glm::vec3( 0.0f, 0.0f, 0.0f );
	bb.size = glm::vec2( 2.0f, 2.0f );
	bb.spherical = 1.0f;
	bb.uv = glm::vec4( 0.0f, 0.0f, 1.0f, 1.0f );
	bb.scroll = glm::vec3( 0.0f, 0.0f, 0.0f );

	texture.bind( GL_TEXTURE0 );
	normalMap->bind( GL_TEXTURE1 );
	specularMap->bind( GL_TEXTURE2 );

	gbuffer.renderBillboards( bbs );

	gbuffer.endBillboardPass();

	// FINAL PASS
	gbuffer.performFinalPass();
	gbuffer.end();
}

void Graphics::renderForward()
{
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

void Graphics::renderBasic()
{
	shader.bind();
	shader.setMat4( projectionLocation, perspectiveCamera.getProjectionMatrix() );
	shader.setMat4( viewLocation, perspectiveCamera.getViewMatrix() );

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

	// render billboards
	glEnable( GL_BLEND );
	glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	glDepthMask( GL_FALSE );

	billboardShader.bind();
	billboardShader.setMat4( billboardProjectionLocation, perspectiveCamera.getProjectionMatrix() );
	billboardShader.setMat4( billboardViewLocation, perspectiveCamera.getViewMatrix() );

	//float intPart = 0;
	//float billboardDelta = modf( elapsedTime, &intPart );
	//billboardShader.setFloat( billboardDeltaTimeLocation, billboardDelta );
	billboardShader.setFloat( billboardDeltaTimeLocation, elapsedTime );

	glBindVertexArray( billboardVAO );
	glBindBuffer( GL_ARRAY_BUFFER, billboardVBO );

	const int BILLBOARD_COLLECTION_COUNT = billboardCollections.getSize();
	for( int curCollection = 0; curCollection < BILLBOARD_COLLECTION_COUNT; curCollection++ )
	{
		BillboardCollection& collection = billboardCollections[curCollection];

		collection.texture->bind( GL_TEXTURE0 );
		collection.mask->bind( GL_TEXTURE1 );

		const int BILLBOARD_COUNT = collection.billboards[readIndex].getSize();
		int offset = 0;
		while( offset < BILLBOARD_COUNT )
		{
			int count = BILLBOARD_COUNT - offset;
			if( count > GRAPHICS_MAX_BILLBOARDS )
			count = GRAPHICS_MAX_BILLBOARDS;

			glBufferSubData( GL_ARRAY_BUFFER, 0, sizeof(Billboard)*count, collection.billboards[readIndex].getData()+offset );
			glDrawArrays( GL_POINTS, 0, count );

			offset += count;
		}
	}

	glDepthMask( GL_TRUE );
	glBindVertexArray( 0 );

	// render quads
	glDisable( GL_DEPTH_TEST );

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

void Graphics::queueBillboard( int textureIndex, int maskIndex, const glm::vec3& position, const glm::vec2& size, const glm::vec4& uv, bool spherical, const glm::vec3& scroll )
{
	const Texture* texture = assets.getTexture( textureIndex );
	const Texture* mask = assets.getTexture( maskIndex );

	const int BILLBOARD_COLLECTION_COUNT = billboardCollections.getSize();

	int index = -1;
	for( int i=0; i<BILLBOARD_COLLECTION_COUNT && index < 0; i++ )
		if( billboardCollections[i].texture == texture &&
			billboardCollections[i].mask == mask )
			index = i;

	if( index < 0 ) // this is a new texture
	{
		BillboardCollection& collection = billboardCollections.append();
		collection.texture = texture;
		collection.mask = mask;
		collection.billboards[writeIndex].expand( GRAPHICS_MAX_BILLBOARDS );
		collection.billboards[readIndex].expand( GRAPHICS_MAX_BILLBOARDS );

		index = BILLBOARD_COLLECTION_COUNT;
	}

	Billboard& billboard = billboardCollections[index].billboards[writeIndex].append();
	billboard.position = position;
	billboard.uv = uv;
	billboard.size = size;
	billboard.spherical = ( spherical ? 1.0f : 0.0f );
	billboard.scroll = scroll;
}

//Camera* Graphics::getCamera()
//{
//	return &camera;
//}

void Graphics::setLightingEnabled( bool enabled )
{
	lightingEnabled = enabled;
}

Camera* Graphics::getPerspectiveCamera()
{
	return &perspectiveCamera;
}

Camera* Graphics::getOrthographicCamera()
{
	return &orthographicCamera;
}

Assets* Graphics::getAssets()
{
	return &assets;
}

Gbuffer* Graphics::getGbuffer()
{
	return &gbuffer;
}

bool Graphics::getLightingEnabled()
{
	return lightingEnabled;
}