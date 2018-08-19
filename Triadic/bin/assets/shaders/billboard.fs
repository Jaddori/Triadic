#version 450

in vec2 fragUV;
in vec3 fragScroll;

out vec4 finalColor;

layout(binding=0) uniform sampler2D diffuseMap;
layout(binding=1) uniform sampler2D maskMap;
uniform float deltaTime;

void main()
{
	//finalColor = texture( diffuseMap, fragUV );
	
	float a1 = texture( diffuseMap, fragUV + fragScroll.xy + deltaTime * fragScroll.z ).a;
	float a2 = texture( diffuseMap, (fragUV*0.5) + fragScroll.xy + deltaTime * fragScroll.z*0.5 ).a;
	float a3 = texture( diffuseMap, (fragUV*2.0) + fragScroll.xy + deltaTime * fragScroll.z*1.5 ).a;
	float mask = texture( maskMap, fragUV ).r;
	
	finalColor = texture( diffuseMap, fragUV );
	finalColor.a = ((a1*a2*2)*a3*2)*mask;
}