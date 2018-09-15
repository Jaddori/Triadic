#pragma once

#include <WinSock2.h>
#include <WS2tcpip.h>
#include <iostream>
#include <stdint.h>

namespace Network
{
	class Client
	{
	public:
		Client();
		~Client();

		bool debug();

	private:
	};
}