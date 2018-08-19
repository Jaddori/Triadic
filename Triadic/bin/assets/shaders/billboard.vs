#version 330

layout(location=0) in vec3 vertPosition;
layout(location=1) in vec4 vertUV;
layout(location=2) in vec2 vertSize;
layout(location=3) in float vertSpherical;

out vec4 geomUV;
out vec2 geomSize;
out float geomSpherical;

uniform mat4 viewMatrix;

void main()
{
	gl_Position = vec4( vertPosition, 1.0 );
	geomUV = vertUV;
	geomSize = vertSize;
	geomSpherical = vertSpherical;
	
	/*gl_Position = viewMatrix * vec4( vertPosition, 1.0 );
	geomUV = vertUV;
	geomSize = vertSize;*/
}