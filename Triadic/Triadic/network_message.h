#pragma once

#include <stdint.h>
#include <algorithm>
#include <cassert>

#define NETWORK_MESSAGE_SIZE 512

namespace Network
{
	class NetworkMessage
	{
	public:
		NetworkMessage();
		NetworkMessage( char* buffer, int length );
		~NetworkMessage();

		void clear();

		template<typename T>
		void write( T value )
		{
			assert( offset + sizeof(T) < NETWORK_MESSAGE_SIZE );

			*(T*)(buffer+offset) = value;
			offset += sizeof(T);
			size = offset;
		}
		
		template<typename T>
		void write( T* value, int count )
		{
			write<int32_t>( count );

			assert( offset + sizeof(T)*count < NETWORK_MESSAGE_SIZE );

			memcpy( buffer+offset, value, count*sizeof(T) );
			offset += sizeof(T)*count;
			size = offset;
		}

		template<typename T>
		T read()
		{
			assert( offset + sizeof(T) <= size );

			T result = *(T*)(buffer+offset);
			offset += sizeof(T);

			return result;
		}

		template<typename T>
		int read( T* destination, int maxCount )
		{
			int count = read<int32_t>();

			assert( offset + sizeof(T)*count <= size );
			assert( count <= maxCount );

			memcpy( destination, buffer+offset, count*sizeof(T) );
			offset += sizeof(T)*count;

			return count;
		}

		void setSize( int size );
		void setOffset( int offset );
		void setBuffer( char* buffer, int length );

		int getSize() const;
		int getOffset() const;
		const char* getBuffer() const;

	private:
		int size;
		int offset;
		char buffer[NETWORK_MESSAGE_SIZE];
	};
}