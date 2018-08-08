#pragma once

#include "common.h"
#include "mesh.h"
#include "shader.h"
#include "camera.h"
#include "texture.h"
#include "instancedmodel.h"
#include "assets.h"
#include "transform.h"
#include "font.h"

namespace Rendering
{
	struct Glyph
	{
		glm::vec2 position;
		glm::vec4 uv;
		glm::vec2 size;
		glm::vec4 color;
	};

	struct GlyphCollection
	{
		const Texture* texture;
		Array<Glyph> glyphs[2];
	};

	class Graphics
	{
	public:
		Graphics();
		~Graphics();

		void load();

		void finalize();
		void render();

		void queueMesh( int meshIndex, Transform* transform );
		void queueText( int fontIndex, const char* text, const glm::vec2& position, const glm::vec4& color );

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
		Array<Array<glm::mat4>> worldMatrixQueue;
		GLuint uniformBuffer;

		Shader textShader;
		GLuint textProjectionLocation;
		Camera orthographicCamera;
		GLuint textVAO;
		GLuint textVBO;
		Array<GlyphCollection> glyphCollections;

		int writeIndex, readIndex;
	};
}