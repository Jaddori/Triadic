#include "SDL\SDL.h"

int main( int argc, char* argv[] )
{
	SDL_Window* window = SDL_CreateWindow( "Triadic", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 640, 480, SDL_WINDOW_SHOWN | SDL_WINDOW_OPENGL );
	if( window )
	{
		bool running = true;

		SDL_Event e;
		while( running )
		{
			while( SDL_PollEvent( &e ) )
			{
				switch( e.type )
				{
					case SDL_QUIT:
						running = false;
						break;

					case SDL_KEYDOWN:
						break;
				}
			}
		}

		SDL_DestroyWindow( window );
	}

	return 0;
}