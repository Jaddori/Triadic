#include "network_message.h"
using namespace Network;

NetworkMessage::NetworkMessage()
	: size( 0 ), offset( 0 )
{
}

NetworkMessage::NetworkMessage( char* buf, int len )
	: size( len ), offset( 0 )
{
	memcpy( buffer, buf, len );
}

NetworkMessage::~NetworkMessage()
{
}

void NetworkMessage::clear()
{
	size = 0;
	offset = 0;
}

void NetworkMessage::setSize( int value )
{
	size = value;
}

void NetworkMessage::setOffset( int value )
{
	offset = value;
}

void NetworkMessage::setBuffer( char* buf, int len )
{
	memcpy( buffer, buf, len );
	size = len;
}

int NetworkMessage::getSize() const
{
	return size;
}

int NetworkMessage::getOffset() const
{
	return offset;
}

const char* NetworkMessage::getBuffer() const
{
	return buffer;
}