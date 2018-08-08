#pragma once

#include "common.h"
#include "shader.h"

#define SHAPES_MAX_LINES 128
#define SHAPES_MAX_SPHERES 128
#define SHAPES_MAX_AABB 64
#define SHAPES_MAX_OBB 32

namespace Rendering
{
	struct DebugLine
	{
		glm::vec3 start;
		glm::vec3 end;
		glm::vec4 color;
	};

	struct DebugSphere
	{
		glm::vec3 position;
		float radius;
		glm::vec4 color;
	};

	struct DebugAABB
	{
		glm::vec3 minPosition;
		glm::vec3 maxPosition;
		glm::vec4 color;
	};

	struct DebugOBB
	{
		glm::vec3 position;
		glm::vec3 x, y, z;
		glm::vec3 extents;
		glm::vec4 color;
	};

	class DebugShapes
	{
	public:
		DebugShapes();
		~DebugShapes();

		bool load();
		void unload();
		void upload();

		void render( const glm::mat4& projectionMatrix, const glm::mat4& viewMatrix );
		void finalize();

		void addLine( const DebugLine& line );
		void addSphere( const DebugSphere& sphere );
		void addAABB( const DebugAABB& aabb );
		void addOBB( const DebugOBB& obb );

		void setIgnoreDepth( bool ignore );
		void setVisible( bool visible );

		bool getIgnoreDepth() const;
		bool getVisible() const;

	private:
		SwapArray<DebugLine> lines;
		SwapArray<DebugSphere> spheres;
		SwapArray<DebugAABB> aabbs;
		SwapArray<DebugOBB> obbs;
		bool ignoreDepth;
		bool visible;

		// line
		Rendering::Shader lineShader;
		GLint lineProjectionMatrixLocation;
		GLint lineViewMatrixLocation;
		GLuint lineVAO, lineVBO;

		// sphere
		Rendering::Shader sphereShader;
		GLint sphereProjectionMatrixLocation;
		GLint sphereViewMatrixLocation;
		GLuint sphereVAO, sphereVBO;

		// aabb
		Rendering::Shader aabbShader;
		GLint aabbProjectionMatrixLocation;
		GLint aabbViewMatrixLocation;
		GLuint aabbVAO, aabbVBO;

		// obb
		Rendering::Shader obbShader;
		GLint obbProjectionMatrixLocation;
		GLint obbViewMatrixLocation;
		GLuint obbVAO, obbVBO;
	};
}