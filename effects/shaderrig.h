
#ifndef FX_SHADER_RIG_H
#define FX_SHADER_RIG_H

float4 kLightRig[7]	: LightRig = 
{
	float4(1.f, 1.f, 1.f, 1.f), // Color1
	float4(0.2f, 0.3f, 0.3f, 1.f), // Color2
	float4(0.2f, 0.3f, 0.3f, 1.f), // Color3

	float4(0.f, 0.f, -1.f, 1.f), // Dir1
	float4(1.f, 0.f, 0.f, 1.f), // Dir2
	float4(-1.f, 0.f, 0.f, 1.f), // Dir3

	float4(0.2f, 0.2f, 0.2f, 1.f) // Ambient Color
};

float4 kHighlightEmissive	: HighlightEmissive = float4(1.f, 0.f, 0.f, 1.f);
float4 kHighlightAmbient	: HighlightAmbient = float4(0.f, 1.f, 0.f, 0.f);

#define kMaxShaderLights (3)
#define kOffsetToColor (0)
#define kOffsetToDir (kMaxShaderLights)
#define kOffsetToAmbient (6) // (kOffsetToDir + kMaxShaderLights);

float4 lightFromRig(const float3 worldNorm, const float4 diffuse, const float4 emissive)
{
	float4 colorOut;

	float3 dots;
	dots.x = dot(-kLightRig[0 + kOffsetToDir].xyz, worldNorm);
	dots.y = dot(-kLightRig[1 + kOffsetToDir].xyz, worldNorm);
	dots.z = dot(-kLightRig[2 + kOffsetToDir].xyz, worldNorm);
	// 3
	saturate(dots);
	// 4
	colorOut = kLightRig[kOffsetToAmbient]; // Ambient term, inits alpha to 1.f
	colorOut.xyz += saturate(kLightRig[0 + kOffsetToColor].xyz * dots.x);
	colorOut.xyz += saturate(kLightRig[1 + kOffsetToColor].xyz * dots.y);
	colorOut.xyz += saturate(kLightRig[2 + kOffsetToColor].xyz * dots.z);
	// 8
	colorOut.xyz *= diffuse.xyz;
	// 9
	colorOut.xyz += emissive.xyz;
	// 10

	colorOut *= (1.f - kHighlightAmbient.w);
	colorOut += kHighlightAmbient.w * kHighlightEmissive;
	
	return colorOut;
}

#endif // FX_SHADER_RIG_H
