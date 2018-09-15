#include "client.h"
using namespace Network;

Client::Client()
{
}

Client::~Client()
{
}

bool Client::debug()
{
	bool result = true;

	struct sockaddr_in si_other;
	int s, slen = sizeof(si_other);
	char buf[128];
	char message[128] = { "Hello, World!" };
	WSADATA wsa;

	if( WSAStartup( MAKEWORD(2,2), &wsa ) != 0 )
	{
		printf( "Client: Failed to startup WSA: %d", WSAGetLastError() );
		result = false;
	}
	else
	{
		s = socket( AF_INET, SOCK_DGRAM, IPPROTO_UDP );
		if( s == SOCKET_ERROR )
		{
			printf( "Client: Failed to create socket: %d", WSAGetLastError() );
			result = false;
		}
		else
		{
			memset( &si_other, 0, sizeof(si_other) );
			si_other.sin_family = AF_INET;
			si_other.sin_port = htons( 12345 );
			//si_other.sin_addr.s_addr = inet_addr( "127.0.0.1" );
			inet_pton( AF_INET, "127.0.0.1", &si_other.sin_addr.s_addr );

			for( int i=0; i<3 && result; i++ )
			{
				//printf( "Client: Sending." );
				int send_len = sendto( s, message, strlen( message ), 0, (struct sockaddr*)&si_other, slen );
				if( send_len == SOCKET_ERROR )
				{
					printf( "Client: sendto failed with error code: %d", WSAGetLastError() );
					result = false;
				}
				else
				{
					memset( buf, 0, 128 );

					int recv_len = recvfrom( s, buf, 128, 0, (struct sockaddr*)&si_other, &slen );
					if( recv_len == SOCKET_ERROR )
					{
						printf( "Client: recvfrom failed with error code: %d", WSAGetLastError() );
						result = false;
					}
				}
			}

			closesocket( s );
		}

		WSACleanup();
	}

	return result;
}