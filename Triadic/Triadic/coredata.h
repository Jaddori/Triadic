#pragma once

#include "common.h"
#include "input.h"
#include "systeminfo.h"
#include "camera.h"
#include "assets.h"
#include "graphics.h"

struct CoreData
{
	System::Input* input;
	SystemInfo* systemInfo;
	bool* running;
	char* transientMemory;
	Rendering::Camera* camera;
	Rendering::Assets* assets;
	Rendering::Graphics* graphics;
};