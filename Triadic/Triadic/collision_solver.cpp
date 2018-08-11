#include "collision_solver.h"
using namespace Physics;

CollisionSolver::CollisionSolver()
{
}

CollisionSolver::~CollisionSolver()
{
}

bool CollisionSolver::ray( const Ray& ray, const Sphere& sphere )
{
	float t = 0.0f;

	glm::vec3 m = ray.start - sphere.center;
	float b = glm::dot( m, ray.direction );
	float c = glm::dot( m, m ) - sphere.radius * sphere.radius;

	if( c >= 0.0f && b >= 0.0f )
		return false;

	float discr = b*b - c;
	if( discr < 0.0f )
		return false;

	t = -b - sqrt( discr );

	if( t < 0.0f )
		t = 0.0f;

	return true;
}

bool CollisionSolver::ray( const Ray& ray, const AABB& aabb )
{
	float tmin = 0.0f;
	float tmax = std::numeric_limits<float>().max();
	const glm::vec3& rayDirection = ray.direction;
	const glm::vec3& rayPosition = ray.start;
	const glm::vec3& aabbMin = aabb.minPosition;
	const glm::vec3& aabbMax = aabb.maxPosition;

	unsigned int threeSlabs = 3;

	for (unsigned int i = 0; i < threeSlabs; i++)
	{
		if (glm::abs(rayDirection[i]) < EPSILON) // Ray is parallell to slab
		{
			if (rayPosition[i] < aabbMin[i] || rayPosition[i] > aabbMax[i]) // No hit if origin not inside slab
				return false;
		}
		else
		{
			// compute intersection t value of ray with near and far plane of slab
			float ood = 1.0f / rayDirection[i];
			float t1 = (aabbMin[i] - rayPosition[i]) * ood;
			float t2 = (aabbMax[i] - rayPosition[i]) * ood;

			if (t1 > t2) // Make sure t1 is the intersection with near plane and t2 with far plane
			{
				float temp = t1;
				t1 = t2;
				t2 = temp;
			}

			if (t1 > tmin)
				tmin = t1;

			if (t2 < tmax) 
				tmax = t2;

			if (tmin > tmax) // furthest entry further away than closest exit. Exit function, no collision
				return false;
		}

	}

	// ray intersects all slabs, we have a hit. 
	// hitDistance is tmin and intersection point is (rayposition + raydirection * hitdistance)
	float hitdistance = tmin;
	if (tmin < 0)
		hitdistance = tmax;
	glm::vec3 intersectionPoint = rayPosition + (rayDirection * hitdistance);
	//ray->hit(intersectionPoint, hitdistance);

	return true;
}

bool CollisionSolver::ray( const Ray& ray, const Plane& plane, Hit* hit )
{
	float denom = glm::dot( plane.normal, ray.direction ); 
	if( fabs(denom) > EPSILON )
	{
		glm::vec3 center = plane.normal * plane.offset;
		float t = glm::dot( center - ray.start, plane.normal ) / denom;
		if (t >= EPSILON)
		{
			if( hit )
			{
				hit->length = t;
				hit->position = ray.start + ray.direction * t;
			}

			return true;
		}
	}
	return false;
}

bool CollisionSolver::sphere( const Sphere& a, const Sphere& b )
{
	float distance = glm::distance( a.center, b.center );
	return ( distance <= ( a.radius + b.radius ) );
}

bool CollisionSolver::aabb( const AABB& a, const AABB& b )
{
	const glm::vec3& minPos1 = a.minPosition;
	const glm::vec3& maxPos1 = a.maxPosition;

	const glm::vec3& minPos2 = b.minPosition;
	const glm::vec3& maxPos2 = b.maxPosition;


	return (maxPos1.x >= minPos2.x &&
		minPos1.x <= maxPos2.x &&
		maxPos1.y >= minPos2.y &&
		minPos1.y <= maxPos2.y &&
		maxPos1.z >= minPos2.z &&
		minPos1.z <= maxPos2.z);
}