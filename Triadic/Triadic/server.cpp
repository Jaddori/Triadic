#include "server.h"
using namespace Network;

Server::Server()
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
	recvMessages.clear();

	int recvLen = 0;
	do
	{
		memset( buffer, 0, MESSAGE_SIZE );

		struct sockaddr_in remoteAddress;
		recvLen = recvfrom( mainSocket, buffer, MESSAGE_SIZE, 0, (struct sockaddr*)&remoteAddress, &remoteAddressSize );

		if( recvLen > 0 )
		{
			uint32_t hash = remoteAddress.sin_addr.S_un.S_addr + remoteAddress.sin_port;
			if( addressHashes.find( hash ) < 0 )
			{
				addressHashes.add( hash );
				remoteAddresses.add( remoteAddress );

				Message& msg = sendMessages.append();
				msg.clear();

				LOG_DEBUG( "Adding new remote address with hash: %d", hash );
			}

			Message msg( buffer, recvLen );
			msg.setHash( hash  );
			recvMessages.add( msg );
		}
	} while( recvLen > 0 );

	// SEND
	const int REMOTE_ADDRESS_COUNT = remoteAddresses.getSize();
	for( int curAddress = 0; curAddress < REMOTE_ADDRESS_COUNT; curAddress++ )
	{
		Message& message = sendMessages[curAddress];
		if( message.getSize() > 0 )
		{
			int sendLen = sendto( mainSocket, message.getBuffer(), message.getSize(), 0, (addr)&remoteAddresses[curAddress], remoteAddressSize );

			if( sendLen == SOCKET_ERROR )
			{
				LOG_ERROR( "Server: sendto failed with error code: %d", WSAGetLastError() );
				valid = false;
			}

			message.clear();
		}
	}
}

Array<Message>& Server::getMessages()
{
	return recvMessages;
}

bool Server::getValid() const
{
	return valid;
}