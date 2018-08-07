#pragma once

#include "common.h"
#include "vertex.h"

namespace Rendering
{
	class Mesh
	{
	public:
		Mesh();
		~Mesh();

		bool load( const char* path );
		void unload();
		void upload();

		void bind() const;
		void render() const;

		int getVertexCount() const;
		int getIndexCount() const;
		bool getUploaded() const;

		const Vertex* getVertices() const;
		const GLuint* getIndices() const;

	private:
		int vertexCount;
		int indexCount;

		Vertex* vertices;
		GLuint* indices;

		GLuint vertexArray;
		union
		{
			GLuint buffers[2];
			struct
			{
				GLuint vertexBuffer;
				GLuint indexBuffer;
			};
		};

		bool uploaded;
	};
}