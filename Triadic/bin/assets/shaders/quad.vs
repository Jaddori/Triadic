#version 440

layout(location=0) in vec4 vertDimensions;
layout(location=1) in vec4 vertUV;
layout(location=2) in vec4 vertColor;

out vec2 geomSize;
out vec4 geomUV;
out vec4 geomColor;

void main()
{
	geomSize = vertDimensions.zw;
	geomUV = vertUV;
	geomColor = vertColor;
	
	gl_Position = vec4( vertDimensions.xy, 0.0, 1.0 );
}