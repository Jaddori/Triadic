#include "server.h"
using namespace Network;

Server::Server()
	: ids( 50 )
{
}

Server::~Server()
{
}

void Server::start( int port )
{
	valid = false;

	if( WSAStartup( MAKEWORD(2,2), &wsaData ) == 0 )
	{
		mainSocket = socket( AF_INET, SOCK_DGRAM, IPPROTO_UDP );
		if( mainSocket != INVALID_SOCKET )
		{
			hasSocket = true;

			localAddress.sin_family = AF_INET;
			localAddress.sin_addr.s_addr = INADDR_ANY;
			localAddress.sin_port = htons( port );

			if( bind( mainSocket, (struct sockaddr*)&localAddress, sizeof(localAddress) ) != SOCKET_ERROR )
			{
				DWORD nonBlocking = 1;
				if( ioctlsocket( mainSocket, FIONBIO, &nonBlocking ) == 0 )
				{
					remoteAddressSize = sizeof(struct sockaddr_in);
					valid = true;
				}
				else
				{
					LOG_ERROR( "Server: Failed to set socket to non-blocking." );
				}
			}
			else
			{
				LOG_ERROR( "Server: Failed to bind socket." );
			}
		}
		else
		{
			LOG_ERROR( "Server: Failed to create socket." );
		}
	}
	else
	{
		LOG_ERROR( "Server: Failed to startup WSA." );
	}
}

void Server::stop()
{
	if( hasSocket )
		closesocket( mainSocket );
	WSACleanup();
}

void Server::processTick()
{
	if( !valid )
		return;

	// RECEIVE
	int recvLen = 0;
	do
	{
		memset( buffer, 0, MESSAGE_SIZE );

		struct sockaddr_in remoteAddress;
		recvLen = recvfrom( mainSocket, buffer, MESSAGE_SIZE, 0, (struct sockaddr*)&remoteAddress, &remoteAddressSize );

		if( recvLen > 0 )
		{
			uint64_t hash = ((uint64_t)remoteAddress.sin_addr.S_un.S_addr << 32) | remoteAddress.sin_port;
			if( addressHashes.find( hash ) < 0 )
			{
				addressHashes.add( hash );
				remoteAddresses.add( remoteAddress );
			}

			SDL_LockMutex( mutex );
			Message msg( buffer, recvLen );
			recvMessages.add( msg );
			SDL_UnlockMutex( mutex );
		}
	} while( recvLen > 0 );

	// SEND
	SDL_LockMutex( mutex );
	if( sendMessage.getSize() > 0 )
	{
		const int REMOTE_ADDRESS_COUNT = remoteAddresses.getSize();
		for( int curAddress = 0; curAddress < REMOTE_ADDRESS_COUNT; curAddress++ )
		{
			int sendLen = sendto( mainSocket, sendMessage.getBuffer(), sendMessage.getSize(), 0, (struct sockaddr*)&remoteAddresses[curAddress], remoteAddressSize );

			if( sendLen == SOCKET_ERROR )
			{
				LOG_ERROR( "Server: sendto failed with error code: %d", WSAGetLastError() );
				valid = false;
			}
		}

		sendMessage.clear();
	}
	SDL_UnlockMutex( mutex );
}

int Server::beginRead()
{
	readOffset = 0;
	SDL_LockMutex( mutex );

	return recvMessages.getSize();
}

void Server::endRead()
{
	recvMessages.clear();
	SDL_UnlockMutex( mutex );
}

Message* Server::getMessage()
{
	Message* result = NULL;

	if( readOffset < recvMessages.getSize() )
	{
		result = &recvMessages[readOffset];
		readOffset++;
	}

	return result;
}

bool Server::getValid() const
{
	return valid;
}