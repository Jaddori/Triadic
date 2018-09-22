#include "reliable_logic_tests.h"
#include "array.h"
#include <ctime>

namespace ReliableLogicTests
{
	struct dd
	{
		uint8_t localAck, remoteAck, history;
		Array<uint8_t> reliables;
	};

	void printfBits( uint8_t number )
	{
		for( int i=7; i>=0; i-- )
		{
			int value = ( number >> i ) & 1;
			printf( "%d", value );

			if( i == 4 )
				printf( " " );
		}
	}

	void s_recv( dd& localClient, dd& remoteServer, dd& localServer, dd& remoteClient )
	{
		for( int i=0; i<localClient.reliables.getSize(); i++ )
		{
			uint8_t offset = remoteServer.remoteAck - localClient.reliables[i];
			bool wasReceived = ( remoteServer.history >> offset ) & 1;

			if( !wasReceived )
			{
				printf( "Resending packet: %d\n", localClient.reliables[i] );
			}
		}
		localClient.reliables.clear();

		localClient.localAck++;

		remoteClient.localAck = localClient.localAck;
		remoteClient.remoteAck = localClient.remoteAck;
		remoteClient.history = localClient.history;

		uint8_t prevRemoteAck = localServer.remoteAck;
		localServer.remoteAck = remoteClient.localAck;
		uint8_t dif = localServer.remoteAck - prevRemoteAck;
		localServer.history = ( localServer.history << dif ) | 1;

		printf( "Client: %d,%d,", localClient.localAck, localClient.remoteAck );
		printfBits( localClient.history );
		printf( " -->\n" );

		for( int i=0; i<localServer.reliables.getSize(); i++ )
		{
			uint8_t offset = remoteClient.remoteAck - localServer.reliables[i];
			bool wasReceived = ( remoteClient.history >> offset ) & 1;

			if( !wasReceived )
			{
				printf( "Detected dropped reliable packet: %d\n", localServer.reliables[i] );
			}
		}
	}

	void s_recv_drop( dd& localClient, dd& remoteServer, dd& localServer, dd& remoteClient )
	{
		localClient.localAck++;

		printf( "Client: %d,%d,", localClient.localAck, localClient.remoteAck );
		printfBits( localClient.history );
		printf( " --x\n" );
	}

	void s_recv_reliable( dd& localClient, dd& remoteServer, dd& localServer, dd& remoteClient )
	{
		localClient.localAck++;
		localClient.reliables.add( localClient.localAck );

		remoteClient.localAck = localClient.localAck;
		remoteClient.remoteAck = localClient.remoteAck;
		remoteClient.history = localClient.history;

		uint8_t prevRemoteAck = localServer.remoteAck;
		localServer.remoteAck = remoteClient.localAck;
		uint8_t dif = localServer.remoteAck - prevRemoteAck;
		localServer.history = ( localServer.history << dif ) | 1;

		printf( "*Client: %d,%d,", localClient.localAck, localClient.remoteAck );
		printfBits( localClient.history );
		printf( " -->\n" );
	}

	void s_recv_reliable_drop( dd& localClient, dd& remoteServer, dd& localServer, dd& remoteClient )
	{
		localClient.localAck++;
		localClient.reliables.add( localClient.localAck );

		printf( "*Client: %d,%d,", localClient.localAck, localClient.remoteAck );
		printfBits( localClient.history );
		printf( " --x\n" );
	}

	void c_recv( dd& localClient, dd& remoteServer, dd& localServer, dd& remoteClient )
	{
		for( int i=0; i<localServer.reliables.getSize(); i++ )
		{
			uint8_t offset = remoteClient.remoteAck - localServer.reliables[i];
			bool wasReceived = ( remoteClient.history >> offset ) & 1;

			if( !wasReceived )
			{
				printf( "Resending packet: %d\n", localServer.reliables[i] );
			}
		}
		localServer.reliables.clear();

		localServer.localAck++;

		remoteServer.localAck = localServer.localAck;
		remoteServer.remoteAck = localServer.remoteAck;
		remoteServer.history = localServer.history;

		uint8_t prevRemoteAck = localClient.remoteAck;
		localClient.remoteAck = remoteServer.localAck;
		uint8_t dif = localClient.remoteAck - prevRemoteAck;
		localClient.history = ( localClient.history << dif ) | 1;

		printf( "\t\t\t<-- Server: %d,%d,", localServer.localAck, localServer.remoteAck );
		printfBits( localServer.history );
		printf( "\n" );

		for( int i=0; i<localClient.reliables.getSize(); i++ )
		{
			uint8_t offset = remoteServer.remoteAck - localClient.reliables[i];
			bool wasReceived = ( remoteServer.history >> offset ) & 1;

			if( !wasReceived )
			{
				printf( "Detected dropped reliable packet: %d\n", localClient.reliables[i] );
			}
		}
	}

	void c_recv_drop( dd& localClient, dd& remoteServer, dd& localServer, dd& remoteClient )
	{
		localServer.localAck++;

		printf( "\t\t\tx-- Server: %d,%d,", localServer.localAck, localServer.remoteAck );
		printfBits( localServer.history );
		printf( "\n" );
	}

	void c_recv_reliable( dd& localClient, dd& remoteServer, dd& localServer, dd& remoteClient )
	{
		localServer.localAck++;
		localServer.reliables.add( localServer.localAck );

		remoteServer.localAck = localServer.localAck;
		remoteServer.remoteAck = localServer.remoteAck;
		remoteServer.history = localServer.history;

		uint8_t prevRemoteAck = localClient.remoteAck;
		localClient.remoteAck = remoteServer.localAck;
		uint8_t dif = localClient.remoteAck - prevRemoteAck;
		localClient.history = ( localClient.history << dif ) | 1;

		printf( "\t\t\t<-- *Server: %d,%d,", localServer.localAck, localServer.remoteAck );
		printfBits( localServer.history );
		printf( "\n" );
	}

	void c_recv_reliable_drop( dd& localClient, dd& remoteServer, dd& localServer, dd& remoteClient )
	{
		localServer.localAck++;
		localServer.reliables.add( localServer.localAck );

		printf( "\t\t\tx-- *Server: %d,%d,", localServer.localAck, localServer.remoteAck );
		printfBits( localServer.history );
		printf( "\n" );
	}

	bool drop_test()
	{
		dd localClient;
		dd remoteServer;

		dd localServer;
		dd remoteClient;

		localClient.localAck = localClient.remoteAck = localClient.history = 0;
		remoteServer.localAck = remoteServer.remoteAck = remoteServer.history = 0;
		localServer.localAck = localServer.remoteAck = localServer.history = 0;
		remoteClient.localAck = remoteClient.remoteAck = remoteClient.history = 0;

		for( int i=0; i<3; i++ )
		{
			s_recv( localClient, remoteServer, localServer, remoteClient );
			c_recv( localClient, remoteServer, localServer, remoteClient );
		}

		s_recv_reliable_drop( localClient, remoteServer, localServer, remoteClient );
		c_recv( localClient, remoteServer, localServer, remoteClient );

		for( int i=0; i<3; i++ )
		{
			s_recv( localClient, remoteServer, localServer, remoteClient );
			c_recv( localClient, remoteServer, localServer, remoteClient );
		}

		return true;
	}

	bool random_test()
	{
		srand( (unsigned int)time( NULL ) );

		dd localClient;
		dd remoteServer;

		dd localServer;
		dd remoteClient;

		localClient.localAck = localClient.remoteAck = localClient.history = 0;
		remoteServer.localAck = remoteServer.remoteAck = remoteServer.history = 0;
		localServer.localAck = localServer.remoteAck = localServer.history = 0;
		remoteClient.localAck = remoteClient.remoteAck = remoteClient.history = 0;

		s_recv( localClient, remoteServer, localServer, remoteClient );
		c_recv( localClient, remoteServer, localServer, remoteClient );
		
		typedef void (*func)( dd&, dd&, dd&, dd& );
		func sfuncs[4] = { s_recv, s_recv_drop, s_recv_reliable, s_recv_reliable_drop };
		func cfuncs[4] = { c_recv, c_recv_drop, c_recv_reliable, c_recv_reliable_drop };

		for( int i=0; i<10; i++ )
		{
			int index = ( rand() % 100 ) / 25;
			sfuncs[index]( localClient, remoteServer, localServer, remoteClient );

			index = ( rand() % 100 ) / 25;
			cfuncs[index]( localClient, remoteServer, localServer, remoteClient );
		}

		return true;
	}

	bool testAll()
	{
		bool result = true;

		printf( "Running reliable_logic_tests:\n" );

		TEST( drop_test );
		//TEST( random_test );

		printf( "\n" );

		return result;
	}
}