#pragma once

#include "common.h"
#include "message.h"

#define SERVER_TICK_RATE 20
#define SERVER_TICK_TIME ( 1000.0f / SERVER_TICK_RATE )
#define SERVER_CMD_MS 15
#define SERVER_DEFAULT_PORT 12345

namespace Network
{
	class Server
	{
	public:
		Server();
		~Server();

		void start( int port = SERVER_DEFAULT_PORT );
		void stop();

		void processTick();

		template<typename T>
		void queue( T value )
		{
			SDL_LockMutex( mutex );
			sendMessage.write( value );
			SDL_UnlockMutex( mutex );
		}

		template<typename T>
		void queue( T* value, int maxCount )
		{
			SDL_LockMutex( mutex );
			sendMessage.write( value, maxCount );
			SDL_UnlockMutex( mutex );
		}

		int beginRead();
		void endRead();
		Message* getMessage();

		bool getValid() const;

	private:
		SOCKET mainSocket;
		WSADATA wsaData;
		struct sockaddr_in localAddress;
		int remoteAddressSize;

		bool hasSocket, valid;
		char buffer[MESSAGE_SIZE];

		Message sendMessage;
		Array<Message> recvMessages;
		Array<struct sockaddr_in> remoteAddresses;
		Array<uint64_t> addressHashes;
		Array<int> ids;
		SDL_mutex* mutex;
		int readOffset;
	};
}