#pragma once

#include "prop.h"
#include "text.h"

class Level : public Entity
{
public:
	Level();
	~Level();

	bool load( const char* path );
	void render();

private:
	Array<Prop> props;
};