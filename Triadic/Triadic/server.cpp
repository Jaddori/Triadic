#include "server.h"
using namespace Network;

Server::Server()
{
}

Server::~Server()
{
}

bool Server::debug()
{
	bool result = true;

	SOCKET s;
	struct sockaddr_in server, si_other;
	int slen, recv_len;
	char buf[128];
	WSADATA wsa;

	slen = sizeof(si_other);

	printf( "Server: Starting up.\n" );
	if( WSAStartup( MAKEWORD(2,2), &wsa ) != 0 )
	{
		printf( "Server: Failed to startup WSA." );
		result = false;
	}
	else
	{
		printf( "Server: Creating socket.\n" );
		s = socket( AF_INET, SOCK_DGRAM, IPPROTO_UDP );
		if( s == INVALID_SOCKET )
		{
			printf( "Server: Could not create socket: %d", WSAGetLastError() );
			result = false;
		}
		else
		{
			server.sin_family = AF_INET;
			server.sin_addr.s_addr = INADDR_ANY;
			server.sin_port = htons( 12345 );

			printf( "Server: Binding socket.\n" );
			if( bind( s, (struct sockaddr*)&server, sizeof(server) ) == SOCKET_ERROR )
			{
				printf( "Server: Bind failed with error code: %d", WSAGetLastError() );
				result = false;
			}
			else
			{
				for( int i=0; i<3 && result; i++ )
				{
					memset( buf, 0, 128 );

					printf( "Server: Receiving.\n" );
					recv_len = recvfrom( s, buf, 128, 0, (struct sockaddr*)&si_other, &slen );

					printf( "Received len: %d\n", recv_len );
					if( recv_len == SOCKET_ERROR )
					{
						printf( "Server: recvfrom failed with error code: %d", WSAGetLastError() );
						result = false;
					}
					else
					{
						buf[recv_len] = 0;
						printf( "Server: Received from client:\n%s\n", buf );

						int send_len = sendto( s, buf, recv_len, 0, (struct sockaddr*)&si_other, slen );
						if( send_len == SOCKET_ERROR )
						{
							printf( "Server: sendto failed with error code: %d", WSAGetLastError() );
							result = false;
						}
						else
						{
							printf( "Server: Sent to client:\n%s\n", buf );
						}
					}
				}
			}

			closesocket( s );
		}

		WSACleanup();
	}

	return result;
}