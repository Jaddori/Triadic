#pragma once

#include "common.h"
#include "mesh.h"
#include "shader.h"
#include "camera.h"
#include "texture.h"
#include "instanced_model.h"
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

	struct Quad
	{
		glm::vec2 position;
		glm::vec2 size;
		glm::vec2 uvStart, uvEnd;
		glm::vec4 color;
	};

	struct QuadCollection
	{
		const Texture* texture;
		Array<Quad> quads[2];
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
		void queueQuad( int textureIndex, const glm::vec2& position, const glm::vec2& size, const glm::vec2& uvStart, const glm::vec2& uvEnd, const glm::vec4& color );
		void queueText( int fontIndex, const char* text, const glm::vec2& position, const glm::vec4& color );

		//Camera* getCamera();
		Camera* getPerspectiveCamera();
		Camera* getOrthographicCamera();
		Assets* getAssets();

	private:
		//Camera camera;
		Camera perspectiveCamera;
		Shader shader;
		Texture texture;

		GLuint projectionLocation;
		GLuint viewLocation;

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

		Shader quadShader;
		GLuint quadProjectionLocation;
		GLuint quadVAO;
		GLuint quadVBO;
		Array<QuadCollection> quadCollections;

		int writeIndex, readIndex;
	};
}