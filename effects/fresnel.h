

#ifndef _FX_FRESNEL_H_
#define _FX_FRESNEL_H_

const float2 kDefaultFresnelRange = float2(1.f, 0.25f);

// kFresAt.x is the opacity at a glancing angle (N dot viewdir == 0)
// kFresAt.y is the opacity looking straight at the face along (or away from) the normal
float4 EvalFresnel(const float3 normal, const float2 kFresAt)
{
	float4 fresnel;
	
	fresnel.w = abs(dot(normal, kViewToWorld[2].xyz));

	fresnel.w = lerp(kFresAt.x, kFresAt.y, fresnel.w);

	fresnel.xyz = kLightRig[kOffsetToAmbient];

	return saturate(fresnel);
}

#endif // _FX_FRESNEL_H_
