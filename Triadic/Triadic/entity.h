#pragma once

#include "common.h"
#include "coredata.h"
#include "rendering.h"

class Entity
{
public:
	Entity();
	~Entity();

	static void setCoreData( CoreData* coreData );

protected:
	static CoreData* coreData;
	static uint64_t entities;

	uint64_t entityID;
};