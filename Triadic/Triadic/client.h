#pragma once

#include "common.h"
#include "message.h"

#define CLIENT_TICK_RATE 20
#define CLIENT_TICK_TIME ( 1000.0f / CLIENT_TICK_RATE )
#define CLIENT_CMD_MS 15
#define CLIENT_DEFAULT_PORT 12345

namespace Network
{
	class Client
	{
	public:
		Client();
		~Client();

		void start( int port = CLIENT_DEFAULT_PORT );
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
		struct sockaddr_in remoteAddress;

		char buffer[MESSAGE_SIZE];
		bool hasSocket, valid;
		SDL_mutex* mutex;
		Message sendMessage;
		Array<Message> recvMessages;
		int readOffset;
	};
}