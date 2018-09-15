#include "network_message_tests.h"

namespace NetworkMessageTests
{
	bool writeChar_test()
	{
		NetworkMessage msg;

		char c = 140;
		msg.write( c );

		const char* buf = msg.getBuffer();
		if( buf[0] == c )
			return true;

		return false;
	}

	bool writeBool_test()
	{
		NetworkMessage msg;

		bool b = true;
		msg.write( b );

		const char* buf = msg.getBuffer();
		if( memcmp( buf, &b, sizeof(b) ) == 0 )
			return true;

		return false;
	}

	bool writeInt_test()
	{
		NetworkMessage msg;

		int i = 1337;
		msg.write( i );

		const char* buf = msg.getBuffer();
		if( memcmp( buf, &i, sizeof(i) ) == 0 )
			return true;

		return false;
	}

	bool writeFloat_test()
	{
		NetworkMessage msg;

		float f = 13.37f;
		msg.write( f );

		const char* buf = msg.getBuffer();
		if( memcmp( buf, &f, sizeof(f) ) == 0 )
			return true;

		return false;
	}

	bool writeString_test()
	{
		NetworkMessage msg;

		const char* text = "Testing";
		msg.write( text, strlen( text ) );

		const char* buf = msg.getBuffer();

		int len = *(int*)buf;
		const char* buftext = buf + sizeof(int);

		if( strncmp( text, buftext, len ) == 0 )
			return true;

		return false;
	}

	bool writeArray_test()
	{
		NetworkMessage msg;

		int arr[] = {1,3,3,7};
		msg.write( arr, 4 );

		const int* buf = (const int*)msg.getBuffer();

		int count = buf[0];
		const int* bufint = buf+1;

		if( count == 4 )
		{
			for( int i=0; i<count; i++ )
			{
				if( arr[i] != bufint[i] )
					return false;
			}

			return true;
		}

		return false;
	}

	bool readChar_test()
	{
		char buf[] = { 140, 1, 2, 3 };
		NetworkMessage msg( buf, 4 );

		char c = msg.read<char>();
		if( c == buf[0] )
			return true;

		return false;
	}

	bool readBool_test()
	{
		char buf[32];
		bool bufb = true;
		memcpy( buf, &bufb, sizeof(bufb) );

		NetworkMessage msg( buf, 32 );

		bool b = msg.read<bool>();
		if( b == bufb )
			return true;

		return false;
	}

	bool readInt_test()
	{
		char buf[32];
		int bufi = 1337;
		memcpy( buf, &bufi, sizeof(bufi) );

		NetworkMessage msg( buf, 32 );

		int i = msg.read<int>();
		if( i == bufi )
			return true;

		return false;
	}

	bool readFloat_test()
	{
		char buf[32];
		float buff = 13.37f;
		memcpy( buf, &buff, sizeof(buff) );

		NetworkMessage msg( buf, 32 );

		float f = msg.read<float>();
		if( f == buff )
			return true;

		return false;
	}

	bool readString_test()
	{
		char buf[32];
		const char* text = "Testing";
		int len = strlen( text );
		memcpy( buf, &len, sizeof(len) );
		memcpy( buf+sizeof(int), text, len );
		NetworkMessage msg( buf, 32 );

		char buftext[32] = {};
		len = msg.read<char>( buftext, 32 );
		buftext[len] = 0;

		if( len == strlen( text ) )
		{
			if( strcmp( text, buftext ) == 0 )
				return true;
		}

		return false;
	}

	bool readArray_test()
	{
		int buf[] = { 4, 1, 3, 3, 7 };
		NetworkMessage msg( (char*)buf, sizeof(int)*5 );

		int i[32] = {};
		int count = msg.read( i, 32 );
		
		if( count == 4 )
		{
			for( int it=0; it<count; it++ )
			{
				if( i[it] != buf[it+1] )
					return false;
			}

			return true;
		}

		return false;
	}

	bool readWriteMultiplePrimitives_test()
	{
		NetworkMessage msg;

		char c1 = 140;
		bool b1 = true;
		int i1 = 1337;
		float f1 = 13.37f;

		msg.write( c1 );
		msg.write( b1 );
		msg.write( i1 );
		msg.write( f1 );

		msg.setOffset( 0 );

		char c2 = msg.read<char>();
		bool b2 = msg.read<bool>();
		int i2 = msg.read<int>();
		float f2 = msg.read<float>();

		if( c1 == c2 &&
			b1 == b2 &&
			i1 == i2 &&
			f1 == f2 )
		{
			return true;
		}
		return false;
	}

	bool readWritePrimitivesAndArrays_test()
	{
		NetworkMessage msg;

		int ai1 = 1337;
		int bi1 = 1447;
		float f1[] = {1.1, 2.2, 3.3, 4.4};

		msg.write( ai1 );
		msg.write( f1, 4 );
		msg.write( bi1 );

		msg.setOffset( 0 );

		int ai2 = msg.read<int>();
		float f2[4];
		int len = msg.read( f2, 4 );
		int bi2 = msg.read<int>();

		if( ai1 == ai2 &&
			bi1 == bi2 &&
			len == 4 )
		{
			for( int i=0; i<4; i++ )
			{
				if( f1[i] != f2[i] )
					return false;
			}

			return true;
		}

		return false;
	}

	bool testAll()
	{
		bool result = true;

		printf( "Running network_message_test:\n " );

		TEST( writeChar_test );
		TEST( writeBool_test );
		TEST( writeInt_test );
		TEST( writeFloat_test );
		TEST( writeString_test );
		TEST( writeArray_test );

		TEST( readChar_test );
		TEST( readBool_test );
		TEST( readInt_test );
		TEST( readFloat_test );
		TEST( readString_test );
		TEST( readArray_test );

		if( result )
		{
			TEST( readWriteMultiplePrimitives_test );
			TEST( readWritePrimitivesAndArrays_test );
		}

		printf( "\n" );

		return result;
	}
}