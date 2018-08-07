#pragma once

// Standard libraries
#include <fstream>
#include <iostream>
#include <string>
#include <stdint.h>
#include <ctime>
#include <Windows.h>

// Windowing
#include "SDL\SDL.h"

#define WINDOW_X SDL_WINDOWPOS_UNDEFINED
#define WINDOW_Y SDL_WINDOWPOS_UNDEFINED
#define WINDOW_WIDTH 1280
#define WINDOW_HEIGHT 720
#define WINDOW_VIEWPORT glm::vec4( 0.0f, 0.0f, WINDOW_WIDTH, WINDOW_HEIGHT )

#define FPS 144
#define TICKS_PER_FRAME ( 1000.0f / FPS )

// Threading
#define THREAD_UPDATE_WAIT 1000

// Rendering
#include "GL\glew.h"

#define CAMERA_FOV 45.0f
#define CAMERA_NEAR 0.1f
#define CAMERA_FAR 100.0f
#define CAMERA_HORIZONTAL_SENSITIVITY 0.01f
#define CAMERA_VERTICAL_SENSITIVITY 0.01f

#define MAX_WORLD_MATRICES 512
#define WORLD_MATRIX_QUEUE_INITIAL_CAPACITY 100

#define GRAPHICS_MAX_GLYPHS 128

// Maths
#include "glm\glm.hpp"
#include "glm\gtc\type_ptr.hpp"
#include "glm\gtc\matrix_transform.hpp"
#include "glm\gtc\noise.hpp"
#include "glm\gtc\quaternion.hpp"
#include "glm\gtx\quaternion.hpp"

const float PI = glm::pi<float>();
const float EPSILON = glm::epsilon<float>();
const glm::mat4 IDENT;
const glm::vec3 RIGHT( 1.0f, 0.0f, 0.0f );
const glm::vec3 UP( 0.0f, 1.0f, 0.0f );
const glm::vec3 FORWARD( 0.0f, 0.0f, 1.0f );

// Lua
#include "Lua\lua.hpp"
//#include "LuaUtils.h"
//
//// Core
#include "log.h"
#include "array.h"
#include "queue.h"
#include "swap.h"
#include "swaparray.h"
//#include "Utils.h"

struct Point
{
	int x, y;
};
