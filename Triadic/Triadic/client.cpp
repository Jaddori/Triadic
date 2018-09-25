#include "client.h"
using namespace Network;

Client::Client()
	: handshakePhase( 0 ), salt( 0 ), remoteAddressSize( sizeof(remoteAddress) ), handshakeRetries( 0 ), connected( false ), networkID( 0 )
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

void Client::processHandshake()
{
	if( !valid )
		return;

	// send
	switch( handshakePhase )
	{
		case 0:
		case 1:
		{
			handshakeTicks -= TIMESTEP_MS;
			if( handshakeTicks <= 0 )
			{
				if( handshakeRetries >= CLIENT_HANDSHAKE_MAX_RETRIES )
				{
					LOG_ERROR( "Client: timed out after retrying 3 times." );
					valid = false;
				}
				else
				{
					if( salt == 0 )
					{
						int iterations = (rand() % 9) + 2; // between 2-10 times
						for( int i=0; i<iterations; i++ )
							salt += rand();
					}

					LOG_DEBUG( "Client: Sending handshake message #%d", handshakePhase );

					Message msg;
					msg.write( handshakePhase );
					msg.write( salt );

					int sendLen = sendto( mainSocket, msg.getBuffer(), msg.getSize(), 0, (addr)&remoteAddress, remoteAddressSize );

					if( sendLen == SOCKET_ERROR )
					{
						LOG_ERROR( "Client: sendto failed with error code: %d", WSAGetLastError() );
						valid = false;
					}

					handshakeTicks = CLIENT_HANDSHAKE_TIMEOUT_MS;
					handshakeRetries++;

					if( handshakePhase == 1 )
					{
						LOG_DEBUG( "Client: Connected!" );
						connected = true;
					}
				}
			}
		} break;
	}

	// recv
	memset( buffer, 0, MESSAGE_SIZE );
	int recvLen = recvfrom( mainSocket, buffer, MESSAGE_SIZE, 0, (addr)&remoteAddress, &remoteAddressSize );
	if( recvLen > 0 )
	{
		Message msg( buffer, recvLen );
		switch( handshakePhase )
		{
			case 0:
			{
				LOG_DEBUG( "Client: Received handshake message #%d", handshakePhase );
				
				uint32_t phase = msg.read<uint32_t>();
				if( phase == handshakePhase+1 )
				{
					salt = msg.read<uint32_t>();
					networkID = msg.read<uint32_t>();

					handshakePhase++;
					handshakeTicks = 0;
					handshakeRetries = 0;

					LOG_DEBUG( "Client: Full salt = %d, network ID = %d", salt, networkID );
				}
			} break;
		}
	}
}

void Client::processTick()
{
	if( !valid )
		return;

	SDL_LockMutex( mutex );
	if( sendMessage.getSize() > 0 )
	{
		int sendLen = sendto( mainSocket, sendMessage.getBuffer(), sendMessage.getSize(), 0, (addr)&remoteAddress, remoteAddressSize );

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

		recvLen = recvfrom( mainSocket, buffer, MESSAGE_SIZE, 0, (addr)&remoteAddress, &remoteAddressSize );
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

bool Client::getConnected() const
{
	return connected;
}

uint32_t Client::getNetworkID() const
{
	return networkID;
}