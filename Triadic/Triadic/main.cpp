#include "GL\glew.h"
#include "SDL\SDL.h"

#include "input.h"
#include "thread_data.h"
#include "system_info.h"
#include "core_data.h"
#include "rendering.h"
#include "entity.h"
#include "shapes.h"
#include "scripting.h"
#include "collision_solver.h"
#include "server.h"
#include "client.h"

using namespace System;
using namespace Scripting;
using namespace Physics;
using namespace Network;

int updateServer( void* args )
{
	ThreadData* data = (ThreadData*)args;

	Server& server = *data->coreData->server;
	server.start();

	Script script;
	script.bind( data->coreData, true );
	script.load();

	while( *data->coreData->running && server.getValid() )
	{
		uint64_t lastTick = SDL_GetTicks();

		//script.update(0.0f);
		script.fixedUpdate( TIMESTEP_PER_SEC );
		script.serverWrite();

		server.processTick();

		if( *data->coreData->reload )
		{
			script.reload();
			*data->coreData->reload = false;
		}

		uint64_t curTick = SDL_GetTicks();
		uint64_t tickDif = curTick - lastTick;

		if( tickDif < SERVER_TICK_TIME )
		{
			SDL_Delay( SERVER_TICK_TIME - tickDif );
		}
	}

	script.unload();

	server.stop();

	return 0;
}

int update( void* args )
{
	ThreadData* data = (ThreadData*)args;

	Input& input = *data->coreData->input;
	Script& script = *data->script;
	Client& client = *data->coreData->client;

	uint64_t lastTick = SDL_GetTicks();
	uint64_t lastClientTick = SDL_GetTicks();
	uint64_t lastUpdateTick = SDL_GetTicks();

	uint64_t* updateAccumulator = data->coreData->updateAccumulator;

	client.start();

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

			uint64_t acc = *updateAccumulator;
			acc += ( curTick - lastTick );

			lastTick = curTick;

			if( acc > TIMESTEP_MS )
			{
				int iterations = acc / TIMESTEP_MS;

				for( int i=0; i<iterations; i++ )
				{
					script.fixedUpdate( TIMESTEP_MS );
				}
			}
			*updateAccumulator = acc;

			// update subsystems
			script.update( deltaTime );
			script.render();
			
			if( data->coreData->input->keyReleased( SDL_SCANCODE_F1 ) )
			{
				script.reload();
				*data->coreData->reload = true;
			}

			data->coreData->systemInfo->stopUpdate();

			if( input.keyPressed( SDL_SCANCODE_G ) )
			{
				data->coreData->graphics->getGbuffer()->toggleDebugMode();
			}

			// update client
			uint64_t curClientTick = SDL_GetTicks();
			if( curClientTick - lastClientTick > CLIENT_TICK_TIME )
			{
				script.clientWrite();
				client.processTick();

				lastClientTick = SDL_GetTicks();
			}

			SDL_SemPost( data->updateDone );
		}
		else if( result == -1 )
		{
			LOG_ERROR( "Update thread encountered error when waiting on semaphore." );
		}
	}

	data->coreData->client->stop();

	return 0;
}

int main( int argc, char* argv[] )
{
	LOG_START( "./log.log" );
	LOG_WARNINGS();
	//LOG_INFORMATIONS();

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
			bool reload = false;

			Input input;

			DebugShapes debugShapes;
			if( !debugShapes.load() )
			{
				LOG_ERROR( "Failed to load debug shapes." );
				return -1;
			}
			debugShapes.upload();

			CollisionSolver collisionSolver;
			Client client;
			Server server;

			uint64_t updateAccumulator = 0;

			CoreData coreData = {};
			coreData.input = &input;
			coreData.systemInfo = &systemInfo;
			coreData.running = &running;
			coreData.reload = &reload;
			coreData.assets = graphics.getAssets();
			coreData.graphics = &graphics;
			coreData.debugShapes = &debugShapes;
			coreData.transientMemory = (char*)malloc( CORE_DATA_TRANSIENT_MEMORY_SIZE );
			coreData.collisionSolver = &collisionSolver;
			coreData.client = &client;
			coreData.server = &server;
			coreData.updateAccumulator = &updateAccumulator;

			LOG_INFO( "Initializing Entity." );
			Entity::setCoreData( &coreData );

			Script script;
			script.bind( &coreData, false );
			script.load();

			ThreadData threadData;
			threadData.coreData = &coreData;
			threadData.updateDone = SDL_CreateSemaphore( 0 );
			threadData.renderDone = SDL_CreateSemaphore( 1 );
			threadData.script = &script;

			SDL_Thread* updateThread = SDL_CreateThread( update, NULL, &threadData );
			SDL_Thread* serverThread = SDL_CreateThread( updateServer, NULL, &threadData );

			uint64_t lastTick = SDL_GetTicks();

			uint64_t inputLastTick = SDL_GetTicks();

			while( running )
			{
				int waitResult = SDL_SemWait( threadData.updateDone );
				if( waitResult == 0 )
				{
					if( updateAccumulator > TIMESTEP_MS )
					{
						while( updateAccumulator > TIMESTEP_MS )
							updateAccumulator -= TIMESTEP_MS;

						input.reset();

						// events
						SDL_Event e;
						while( SDL_PollEvent( &e ) )
						{
							if( e.type == SDL_QUIT )
								running = false;
							input.update( &e );
						}
					}

					// finalize objects
#if _DEBUG
					graphics.getAssets()->hotload();
#endif
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

				const glm::mat4& projectionMatrix = graphics.getPerspectiveCamera()->getProjectionMatrix();
				const glm::mat4& viewMatrix = graphics.getPerspectiveCamera()->getViewMatrix();

				debugShapes.render( projectionMatrix, viewMatrix );

				uint64_t curTick = SDL_GetTicks();
				float deltaTime = ( curTick - lastTick ) * 0.001f;
				lastTick = curTick;

				graphics.render( deltaTime );

				glClear( GL_DEPTH_BUFFER_BIT );

				debugShapes.renderOmnipresent( projectionMatrix, viewMatrix );

				SDL_GL_SwapWindow( window );

				systemInfo.stopRender();

				uint64_t endTicks = SDL_GetTicks();
				uint64_t elapsedTicks = endTicks - startTicks;
				
				uint64_t minTicks = TICKS_PER_FRAME;
				if( elapsedTicks < minTicks )
					SDL_Delay( (Uint32)( minTicks - elapsedTicks ) );
			}

			LOG_INFO( "Waiting for update thread to finish." );
			SDL_WaitThread( updateThread, NULL );

			LOG_INFO( "Waiting for server thread to finish." );
			SDL_WaitThread( serverThread, NULL );
			
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