#include "GL\glew.h"
#include "SDL\SDL.h"

#include "input.h"
#include "threaddata.h"
#include "systeminfo.h"
#include "coredata.h"
#include "rendering.h"

using namespace System;

int update( void* args )
{
	ThreadData* data = (ThreadData*)args;

	Input& input = *data->coreData->input;
	Camera& camera = *data->coreData->camera;

	uint64_t lastTick = SDL_GetTicks();

	while( *data->coreData->running )
	{
		int result = SDL_SemWaitTimeout( data->renderDone, THREAD_UPDATE_WAIT );
		if( result == 0 )
		{
			if( input.keyDown( SDL_SCANCODE_ESCAPE ) )
				*data->coreData->running = false;

			uint64_t curTick = SDL_GetTicks();
			float deltaTime = ( curTick - lastTick ) * 0.001f;
			lastTick = curTick;

			// update subsystems
			Point mouseDelta = input.getMouseDelta();
			if( input.buttonDown( SDL_BUTTON_LEFT ) )
				camera.updateDirection( mouseDelta.x, mouseDelta.y );
			
			glm::vec3 movement;
			if( input.keyDown( SDL_SCANCODE_A ) )
				movement.x -= 1.0f;
			if( input.keyDown( SDL_SCANCODE_D ) )
				movement.x += 1.0f;
			if( input.keyDown( SDL_SCANCODE_W ) )
				movement.z += 1.0f;
			if( input.keyDown( SDL_SCANCODE_S ) )
				movement.z -= 1.0f;
			camera.relativeMovement( movement );

			SDL_SemPost( data->updateDone );
		}
		else if( result == -1 )
		{
			LOG_ERROR( "Update thread encountered error when waiting on semaphore." );
		}
	}

	return 0;
}

int main( int argc, char* argv[] )
{
	LOG_START( "./log.txt" );
	//LOG_WARNINGS();
	LOG_INFORMATIONS();

	if( SDL_Init( SDL_INIT_AUDIO | SDL_INIT_EVENTS | SDL_INIT_TIMER ) )
	{
		LOG_ERROR( "Failed to initialize SDL." );
		return -1;
	}

	SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, 3 );
	SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, 2 );
	SDL_GL_SetAttribute( SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE );

	SDL_Window* window = SDL_CreateWindow( "Triadic", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 640, 480, SDL_WINDOW_SHOWN | SDL_WINDOW_OPENGL );
	if( window )
	{
		LOG_INFO( "Window created." );

		SDL_GLContext context = SDL_GL_CreateContext( window );

		if( context )
		{
			LOG_INFO( "OpenGL context created." );

			glewExperimental = GL_TRUE;
			if( glewInit() == GLEW_OK )
			{
				LOG_INFO( "GLEW initialized." );
			}
			else
			{
				LOG_ERROR( "Failed to initialize GLEW." );
				return -1;
			}

			//glEnable( GL_CULL_FACE );
			glEnable( GL_DEPTH_TEST );

			Camera camera;
			camera.updatePerspective( WINDOW_WIDTH, WINDOW_HEIGHT );
			camera.setPosition( glm::vec3( 0, 0, -10 ) );

			Shader shader;
			shader.load( "./assets/shaders/basic.vs", NULL, "./assets/shaders/basic.fs" );

			Texture texture;
			texture.load( "./assets/textures/palette.dds" );
			texture.upload();

			SystemInfo systemInfo;
			systemInfo.poll();

			ThreadPool threadPool;
			threadPool.load();

			GLuint vao = 0, vbo = 0, ibo = 0;

			Mesh mesh;
			mesh.load( "./assets/models/pillar.mesh" );
			mesh.upload();

			Model model;
			model.load( &mesh, &texture );

			GLuint projectionLocation = shader.getLocation( "projectionMatrix" );
			GLuint viewLocation = shader.getLocation( "viewMatrix" );
			GLuint uvOffsetLocation = shader.getLocation( "uvOffset" );

			bool running = true;
			int timeElapsed = 0;
			int fps = 0;
			bool mouseDown = false;

			Input input;

			CoreData coreData = {};
			coreData.input = &input;
			coreData.systemInfo = &systemInfo;
			coreData.running = &running;
			coreData.camera = &camera;

			ThreadData threadData;
			threadData.coreData = &coreData;
			threadData.updateDone = SDL_CreateSemaphore( 0 );
			threadData.renderDone = SDL_CreateSemaphore( 1 );

			SDL_Thread* updateThread = SDL_CreateThread( update, NULL, &threadData );

			while( running )
			{
				int waitResult = SDL_SemWait( threadData.updateDone );
				if( waitResult == 0 )
				{
					input.reset();

					// events
					SDL_Event e;
					while( SDL_PollEvent( &e ) )
					{
						if( e.type == SDL_QUIT )
							running = false;
						input.update( &e );
					}

					// finalize objects
					camera.finalize();

					threadPool.schedule();

					SDL_SemPost( threadData.renderDone );
				}

				fps++;
				uint64_t startTicks = SDL_GetTicks();

				// render
				systemInfo.startRender();

				glClearColor( 1.0f, 0.0f, 0.0f, 0.0f );
				glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

				shader.bind();
				shader.setMat4( projectionLocation, camera.getProjectionMatrix() );
				shader.setMat4( viewLocation, camera.getViewMatrix() );
				shader.setVec2( uvOffsetLocation, glm::vec2( 0.0f, 0.0f ) );

				texture.bind();

				model.render();

				SDL_GL_SwapWindow( window );

				uint64_t endTicks = SDL_GetTicks();
				uint64_t elapsedTicks = endTicks - startTicks;

				timeElapsed += elapsedTicks;
				if( timeElapsed > 1000 )
				{
					char buf[32] = {};
					_snprintf( buf, 32, "FPS: %d", fps );
					SDL_SetWindowTitle( window, buf );

					timeElapsed -= 1000;
					fps = 0;
				}
				
				if( elapsedTicks < TICKS_PER_FRAME )
					SDL_Delay( TICKS_PER_FRAME - elapsedTicks );

				systemInfo.stopRender();
			}

			LOG_INFO( "Waiting for update thread to finish." );
			SDL_WaitThread( updateThread, NULL );
			
			threadPool.unload();

			LOG_INFO( "Deleting OpenGL context." );
			SDL_GL_DeleteContext( context );
		}

		LOG_INFO( "Destroying window." );
		SDL_DestroyWindow( window );
	}

	LOG_STOP();

	return 0;
}