
#ifndef FX_FOG_H
#define FX_FOG_H

// FogParams is
// kFogParams[0].x = fogstart in world units 
// kFogParams[0].y = 1.f / (fogend - fogstart)
// kFogParams[0].z = fogend in world units
// kFogParams[0].w = yon
// kFogParams[1] is fog plane, which is (normal (view direction).xyz, dot(P0, normal))
float4 kFogParams[2]	: FogParams = { float4(0.f, 0.01f, 100.f, 100.f),
										float4(0.f, 0.f, 1.f, 0.f) };


float computeFog(const float3 wPos)
{
	float distance = dot(wPos, kFogParams[1].xyz) - kFogParams[1].w;
	distance = (kFogParams[0].z - distance) * kFogParams[0].y;
	return saturate(distance);
}

#endif // FX_FOG_H