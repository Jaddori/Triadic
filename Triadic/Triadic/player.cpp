#include "player.h"
using namespace System;

Player::Player()
{
}

Player::~Player()
{
}

bool Player::load()
{
	Assets* assets = coreData->assets;
	meshIndex = assets->loadMesh( "./assets/models/box.mesh" );

	fontIndex = assets->loadFont( "./assets/fonts/verdana12.bin", "./assets/fonts/verdana12.dds" );

	transform.setScale( glm::vec3( 1.0f, 2.0f, 3.0f ) );
	transform.setOrientation( glm::quat( glm::vec3( 0, 45, 0 ) ) );

	return ( meshIndex >= 0 && fontIndex >= 0 );
}

void Player::update( float deltaTime )
{
	Input* input = coreData->input;

	glm::vec3 movement;
	if( input->keyDown( SDL_SCANCODE_LEFT ) )
		movement.x -= 1.0f;
	if( input->keyDown( SDL_SCANCODE_RIGHT ) )
		movement.x += 1.0f;
	if( input->keyDown( SDL_SCANCODE_DOWN ) )
		movement.z -= 1.0f;
	if( input->keyDown( SDL_SCANCODE_UP ) )
		movement.z += 1.0f;

	if( glm::length( movement ) > EPSILON )
		movement = glm::normalize( movement );

	transform.addPosition( movement * PLAYER_SPEED * deltaTime );
}

void Player::render()
{
	coreData->graphics->queueMesh( meshIndex, &transform );
	coreData->graphics->queueText( fontIndex, "Testing...", glm::vec2( 32, 32 ), glm::vec4( 1.0f, 1.0f, 1.0f, 1.0f ) );

	DebugSphere sphere =
	{
		transform.getPosition(),
		2.0f,
		glm::vec4( 0.0f, 1.0f, 0.0f, 1.0f )
	};
	coreData->debugShapes->addSphere( sphere );
}