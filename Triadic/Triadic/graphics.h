#pragma once

#include "common.h"
#include "mesh.h"
#include "shader.h"
#include "camera.h"
#include "texture.h"
#include "instancedmodel.h"
#include "assets.h"
#include "transform.h"

namespace Rendering
{
	class Graphics
	{
	public:
		Graphics();
		~Graphics();

		void load();

		void render();

		void queueMesh( int meshIndex, Transform* transform );

		Camera* getCamera();
		Assets* getAssets();

	private:
		Camera camera;
		Shader shader;
		Texture texture;

		GLuint projectionLocation;
		GLuint viewLocation;

		Mesh floorMesh;
		Model floorModel;
		InstancedModel insFloorModel;

		Assets assets;

		Array<int> meshQueue;
		Array<Array<Transform*>> transformQueue;
		Array<glm::mat4> worldMatrixQueue;
		GLuint uniformBuffer;
	};
}