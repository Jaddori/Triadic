#include "GL\glew.h"
#include "SDL\SDL.h"

#include "input.h"
#include "threaddata.h"
#include "systeminfo.h"
#include "coredata.h"
#include "rendering.h"
#include "entity.h"
#include "level.h"
#include "shapes.h"
#include "scripting.h"

using namespace System;
using namespace Scripting;

int update( void* args )
{
	ThreadData* data = (ThreadData*)args;

	Input& input = *data->coreData->input;
	Camera& camera = *data->coreData->camera;
	Script& script = *data->script;

	uint64_t lastTick = SDL_GetTicks();

	while( *data->coreData->running )
	{
		int result = SDL_SemWaitTimeout( data->renderDone, THREAD_UPDATE_WAIT );
		if( result == 0 )
		{
			data->coreData->systemInfo->startUpdate();

			if( input.keyDown( SDL_SCANCODE_ESCAPE ) )
				*data->coreData->running = false;

			uint64_t curTick = SDL_GetTicks();
			float deltaTime = ( curTick - lastTick ) * 0.001f;
			lastTick = curTick;

			// update subsystems
			script.update( deltaTime );
			script.render();
			//data->player->update( deltaTime );

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

			data->coreData->systemInfo->stopUpdate();

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

	SDL_Window* window = SDL_CreateWindow( "Triadic", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, WINDOW_WIDTH, WINDOW_HEIGHT, SDL_WINDOW_SHOWN | SDL_WINDOW_OPENGL );
	if( window )
	{
		LOG_INFO( "Window created." );

		SDL_GLContext context = SDL_GL_CreateContext( window );

		if( context )
		{
			SDL_GL_SetSwapInterval( 0 );

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

			glEnable( GL_DEPTH_TEST );

			Graphics graphics;
			graphics.load();

			SystemInfo systemInfo;
			systemInfo.poll();

			ThreadPool threadPool;
			threadPool.load();

			bool running = true;
			bool mouseDown = false;

			Input input;

			DebugShapes debugShapes;
			if( !debugShapes.load() )
			{
				LOG_ERROR( "Failed to load debug shapes." );
				return -1;
			}
			debugShapes.upload();

			CoreData coreData = {};
			coreData.input = &input;
			coreData.systemInfo = &systemInfo;
			coreData.running = &running;
			coreData.camera = graphics.getCamera();
			coreData.assets = graphics.getAssets();
			coreData.graphics = &graphics;
			coreData.debugShapes = &debugShapes;
			coreData.transientMemory = (char*)malloc( CORE_DATA_TRANSIENT_MEMORY_SIZE );

			LOG_INFO( "Initializing Entity." );
			Entity::setCoreData( &coreData );

			//Player player;
			//if( !player.load() )
			//{
			//	LOG_ERROR( "Failed to load player." );
			//	return -1;
			//}

			Level level;
			if( !level.load( "./assets/levels/level01.txt" ) )
			{
				LOG_ERROR( "Failed to load level." );
				return -1;
			}

			Script script;
			script.bind( &coreData );
			script.load();

			ThreadData threadData;
			threadData.coreData = &coreData;
			threadData.updateDone = SDL_CreateSemaphore( 0 );
			threadData.renderDone = SDL_CreateSemaphore( 1 );
			//threadData.player = &player;
			threadData.script = &script;

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
					graphics.getAssets()->upload();
					graphics.finalize();
					debugShapes.finalize();

					threadPool.schedule();

					SDL_SemPost( threadData.renderDone );
				}

				uint64_t startTicks = SDL_GetTicks();

				// render
				systemInfo.startRender();

				glClearColor( 0.1f, 0.1f, 0.1f, 0.0f );
				glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

				//player.render();
				level.render();

				graphics.render();

				debugShapes.render( graphics.getCamera()->getProjectionMatrix(), graphics.getCamera()->getViewMatrix() );

				SDL_GL_SwapWindow( window );

				systemInfo.stopRender();

				uint64_t endTicks = SDL_GetTicks();
				uint64_t elapsedTicks = endTicks - startTicks;
				
				uint64_t minTicks = TICKS_PER_FRAME;
				if( elapsedTicks < minTicks )
					SDL_Delay( minTicks - elapsedTicks );
			}

			LOG_INFO( "Waiting for update thread to finish." );
			SDL_WaitThread( updateThread, NULL );
			
			// UNLOAD
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