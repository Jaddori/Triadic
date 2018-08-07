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

	return meshIndex >= 0;
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
}