#include "client.h"
using namespace Network;

Client::Client()
{
}

Client::~Client()
{
}

void Client::start( int port )
{
	valid = false;

	if( WSAStartup( MAKEWORD(2,2), &wsaData ) == 0 )
	{
		mainSocket = socket( AF_INET, SOCK_DGRAM, IPPROTO_UDP );
		if( mainSocket != SOCKET_ERROR )
		{
			DWORD nonBlocking = 1;
			if( ioctlsocket( mainSocket, FIONBIO, &nonBlocking ) == 0 )
			{
				memset( &remoteAddress, 0, sizeof(remoteAddress) );

				remoteAddress.sin_family = AF_INET;
				remoteAddress.sin_port = htons( port );
				inet_pton( AF_INET, "127.0.0.1", &remoteAddress.sin_addr.s_addr );

				mutex = SDL_CreateMutex();

				valid = true;
			}
			else
			{
				LOG_ERROR( "Server: Failed to set socket to non-blocking." );
			}
		}
		else
		{
			LOG_ERROR( "Client: Failed to create socket." );
		}
	}
	else
	{
		LOG_ERROR( "Client: Failed to startup WSA." );
	}
}

void Client::stop()
{
	if( hasSocket )
		closesocket( mainSocket );
	WSACleanup();
}

void Client::processTick()
{
	if( !valid )
		return;

	int remoteAddressSize = sizeof(remoteAddress);

	SDL_LockMutex( mutex );
	if( sendMessage.getSize() > 0 )
	{
		int sendLen = sendto( mainSocket, sendMessage.getBuffer(), sendMessage.getSize(), 0, (struct sockaddr*)&remoteAddress, remoteAddressSize );

		if( sendLen != SOCKET_ERROR )
		{
		}
		else
		{
			LOG_ERROR( "Client: sendto failed with error code: %d", WSAGetLastError() );
			valid = false;
		}

		sendMessage.clear();
	}
	SDL_UnlockMutex( mutex );

	// RECEIVE
	recvMessages.clear();

	int recvLen = 0;
	do
	{
		memset( buffer, 0, MESSAGE_SIZE );

		recvLen = recvfrom( mainSocket, buffer, MESSAGE_SIZE, 0, (struct sockaddr*)&remoteAddress, &remoteAddressSize );
		if( recvLen > 0 )
		{
			Message message( buffer, recvLen );
			recvMessages.add( message );
		}
	} while( recvLen > 0 );
}

Array<Message>& Client::getMessages()
{
	return recvMessages;
}

bool Client::getValid() const
{
	return valid;
}