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

	struct Plane
	{
		glm::vec3 normal;
		float offset;
	};

	struct Hit
	{
		glm::vec3 position;
		float length;
	};

	class CollisionSolver
	{
	public:
		CollisionSolver();
		~CollisionSolver();

		bool ray( const Ray& ray, const Sphere& sphere );
		bool ray( const Ray& ray, const AABB& aabb );
		bool ray( const Ray& ray, const Plane& plane, Hit* hit = NULL );

		bool sphere( const Sphere& a, const Sphere& b );

		bool aabb( const AABB& a, const AABB& b );
	};
}