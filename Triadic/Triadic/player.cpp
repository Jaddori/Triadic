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
	//textureIndex = assets->loadTexture( "./assets/textures/palette.dds" );

	fontIndex = assets->loadFont( "./assets/fonts/verdana12.bin", "./assets/fonts/verdana12.dds" );

	return ( meshIndex >= 0 && fontIndex >= 0 );
}

void Player::update()
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

	transform.addPosition( movement );
}

void Player::render()
{
	coreData->graphics->queueMesh( meshIndex, &transform );
	coreData->graphics->queueText( fontIndex, "Testing...", glm::vec2( 32, 32 ), glm::vec4( 0.0f, 0.0f, 1.0f, 1.0f ) );
}