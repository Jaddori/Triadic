#pragma once

#include "common.h"
#include "rendering.h"
#include "entity.h"

class Player : public Entity
{
public:
	Player();
	~Player();

	bool load();

	void update();
	void render();

private:
	Transform transform;
	int meshIndex;
};