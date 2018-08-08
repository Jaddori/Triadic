#pragma once

#include "common.h"
#include "core_data.h"
#include "scripting.h"

struct ThreadData
{
	CoreData* coreData;
	SDL_semaphore* updateDone;
	SDL_semaphore* renderDone;
	Scripting::Script* script;
};