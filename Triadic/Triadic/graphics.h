#pragma once

#include "common.h"
#include "mesh.h"
#include "shader.h"
#include "camera.h"
#include "texture.h"

namespace Rendering
{
	class Graphics
	{
	public:
		Graphics();
		~Graphics();

		void load();

		void render();

		Camera* getCamera();

	private:
		Camera camera;
		Shader shader;
		Mesh mesh;
		Texture texture;
		glm::mat4 worldMatrices[100];
		GLuint ubo;

		GLuint projectionLocation;
		GLuint viewLocation;
		GLuint worldLocation;
	};
}