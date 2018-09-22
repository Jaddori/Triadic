#include <iostream>
#include "network.h"
#include "SDL\SDL_thread.h"
#include "message_tests.h"
#include "network_message_tests.h"
#include "reliable_logic_tests.h"
using namespace Network;

int main( int argc, char* argv[] )
{
	//MessageTests::testAll();
	//NetworkMessageTests::testAll();
	ReliableLogicTests::testAll();

	std::cout << "Done:\n";
	std::cin.get();

	return 0;
}