#pragma once

#include "common.h"

namespace Physics
{
	struct Ray
	{
		glm::vec3 start, direction;
		float length;
	};

	struct Sphere
	{
		glm::vec3 center;
		float radius;
	};

	struct AABB
	{
		glm::vec3 minPosition, maxPosition;
	};

	struct Hit
	{
		glm::vec3 position;
	};

	class CollisionSolver
	{
	public:
		CollisionSolver();
		~CollisionSolver();

		bool ray( const Ray& ray, const Sphere& sphere );
		bool ray( const Ray& ray, const AABB& aabb );

		bool sphere( const Sphere& a, const Sphere& b );

		bool aabb( const AABB& a, const AABB& b );
	};
}