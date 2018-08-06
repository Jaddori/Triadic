#include "graphics.h"
using namespace Rendering;

Graphics::Graphics()
{
}

Graphics::~Graphics()
{
}

void Graphics::load()
{
	shader.load( "./assets/shaders/instanced.vs", NULL, "./assets/shaders/instanced.fs" );
	
	mesh.load( "./assets/models/pillar.mesh" );
	mesh.upload();

	camera.updatePerspective( WINDOW_WIDTH, WINDOW_HEIGHT );
	camera.setPosition( glm::vec3( 0, 0, -10 ) );

	texture.load( "./assets/textures/palette.dds" );
	texture.upload();

	shader.bind();
	projectionLocation = shader.getLocation( "projectionMatrix" );
	viewLocation = shader.getLocation( "viewMatrix" );
	worldLocation = shader.getLocation( "worldMatrices" );

	//worldMatrices[0] = glm::translate( glm::mat4(), glm::vec3( 0, 0, 0 ) );
	//worldMatrices[1] = glm::translate( glm::mat4(), glm::vec3( 10, 0, 0 ) );
	//worldMatrices[2] = glm::translate( glm::mat4(), glm::vec3( 10, 0, 10 ) );
	//worldMatrices[3] = glm::translate( glm::mat4(), glm::vec3( 0, 0, 10 ) );

	glm::mat4 ident;
	for( int x=0, i = 0; x<10; x++ )
	{
		for( int z=0; z<10; z++, i++ )
		{
			worldMatrices[i] = glm::translate( ident, glm::vec3( x*5, 0, z*5 ) );
		}
	}

	glGenBuffers( 1, &ubo );
	glBindBuffer( GL_UNIFORM_BUFFER, ubo );
	glBufferData( GL_UNIFORM_BUFFER, sizeof(glm::mat4)*100, &worldMatrices[0][0], GL_STATIC_DRAW );
	glBindBufferRange( GL_UNIFORM_BUFFER, 0, ubo, 0, sizeof(glm::mat4)*100 );
	glBindBuffer( GL_UNIFORM_BUFFER, 0 );
}

void Graphics::render()
{
	shader.bind();
	shader.setMat4( projectionLocation, camera.getProjectionMatrix() );
	shader.setMat4( viewLocation, camera.getViewMatrix() );

	texture.bind();

	mesh.bind();
	glBindBuffer( GL_UNIFORM_BUFFER, ubo );
	
	glDrawElementsInstanced( GL_TRIANGLES, mesh.getIndexCount(), GL_UNSIGNED_INT, NULL, 100 );
	glBindBuffer( GL_UNIFORM_BUFFER, 0 );
}

Camera* Graphics::getCamera()
{
	return &camera;
}