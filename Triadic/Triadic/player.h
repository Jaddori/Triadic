#pragma once

#include "common.h"
#include "rendering.h"
#include "entity.h"

#define PLAYER_SPEED 10.0f

class Player : public Entity
{
public:
	Player();
	~Player();

	bool load();

	void update( float deltaTime );
	void render();

private:
	Transform transform;
	int meshIndex;
	int fontIndex;
};