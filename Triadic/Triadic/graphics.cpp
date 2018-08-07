#include "graphics.h"
using namespace Rendering;

Graphics::Graphics()
	: worldMatrixQueue( WORLD_MATRIX_QUEUE_INITIAL_CAPACITY )
{
}

Graphics::~Graphics()
{
}

void Graphics::load()
{
	shader.load( "./assets/shaders/instanced.vs", NULL, "./assets/shaders/instanced.fs" );

	floorMesh.load( "./assets/models/floor.mesh" );
	floorMesh.upload();

	camera.updatePerspective( WINDOW_WIDTH, WINDOW_HEIGHT );
	camera.setPosition( glm::vec3( 0, 0, -10 ) );

	texture.load( "./assets/textures/palette.dds" );
	texture.upload();

	floorModel.load( &floorMesh, &texture );
	insFloorModel.load( &floorModel );

	int index = insFloorModel.addInstance();
	insFloorModel.setPosition( index, glm::vec3( 0, 0, 0 ) );

	index = insFloorModel.addInstance();
	insFloorModel.setPosition( index, glm::vec3( 10, 0, 0 ) );

	index = insFloorModel.addInstance();
	insFloorModel.setPosition( index, glm::vec3( 20, 0, 0 ) );

	index = insFloorModel.addInstance();
	insFloorModel.setPosition( index, glm::vec3( 30, 0, 0 ) );

	index = insFloorModel.addInstance();
	insFloorModel.setPosition( index, glm::vec3( 0, 0, 10 ) );

	index = insFloorModel.addInstance();
	insFloorModel.setPosition( index, glm::vec3( 10, 0, 10 ) );

	index = insFloorModel.addInstance();
	insFloorModel.setPosition( index, glm::vec3( 20, 0, 10 ) );

	index = insFloorModel.addInstance();
	insFloorModel.setPosition( index, glm::vec3( 30, 0, 10 ) );

	insFloorModel.finalize();
	
	shader.bind();
	projectionLocation = shader.getLocation( "projectionMatrix" );
	viewLocation = shader.getLocation( "viewMatrix" );

	glGenBuffers( 1, &uniformBuffer );
	glBindBuffer( GL_UNIFORM_BUFFER, uniformBuffer );
	glBindBufferRange( GL_UNIFORM_BUFFER, 0, uniformBuffer, 0, sizeof(glm::mat4)*MAX_WORLD_MATRICES );
	glBindBuffer( GL_UNIFORM_BUFFER, 0 );
}

void Graphics::render()
{
	shader.bind();
	shader.setMat4( projectionLocation, camera.getProjectionMatrix() );
	shader.setMat4( viewLocation, camera.getViewMatrix() );

	
	for( int curMesh = 0; curMesh < meshQueue.getSize(); curMesh++ )
	{
		int meshIndex = meshQueue[curMesh];
		const Mesh* mesh = assets.getMesh( meshIndex );
		Array<Transform*>& transforms = transformQueue[curMesh];

		if( mesh->getUploaded() )
		{
			worldMatrixQueue.clear();

			int activeTransforms = 0;

			const int transformCount = transforms.getSize();
			for( int curTransform = 0; curTransform < transformCount; curTransform++ )
			{
				if( transforms[curTransform]->getActive() )
				{
					worldMatrixQueue.add( transforms[curTransform]->getWorldMatrix() );
					activeTransforms++;
				}
			}

			mesh->bind();

			glBindBuffer( GL_UNIFORM_BUFFER, uniformBuffer );
			glBufferData( GL_UNIFORM_BUFFER, sizeof(glm::mat4)*worldMatrixQueue.getSize(), &worldMatrixQueue.getConstData()[0][0], GL_DYNAMIC_DRAW );

			glDrawElementsInstanced( GL_TRIANGLES, mesh->getIndexCount(), GL_UNSIGNED_INT, NULL, activeTransforms );

			glBindBuffer( GL_UNIFORM_BUFFER, 0 );
		}

		transforms.clear();
	}
}

void Graphics::queueMesh( int meshIndex, Transform* transform )
{
	int index = meshQueue.find( meshIndex );
	if( index < 0 )
	{
		index = meshQueue.getSize();

		meshQueue.append() = meshIndex;
		transformQueue.append();
	}

	transformQueue[index].add( transform );
}

Camera* Graphics::getCamera()
{
	return &camera;
}

Assets* Graphics::getAssets()
{
	return &assets;
}