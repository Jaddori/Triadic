#pragma once

#include "common.h"
#include "coredata.h"

struct ThreadData
{
	CoreData* coreData;
	SDL_semaphore* updateDone;
	SDL_semaphore* renderDone;
};