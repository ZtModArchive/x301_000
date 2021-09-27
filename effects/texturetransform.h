
#ifndef FX_TEXTRANSFORM_H
#define FX_TEXTRANSFORM_H

float2 uvTransform(const float2 uvIn, const float4x4 transform)
{
	float2 uvOut = uvIn.xx * transform[0].xy;
	uvOut += uvIn.yy * transform[1].xy;
	uvOut += transform[2].xy;

	return uvOut;
}

float2 uvTransform(const float3 uvwIn, const float4x4 transform)
{
	float2 uvOut = uvwIn.xx * transform[0].xy;
	uvOut += uvwIn.yy * transform[1].xy;
	uvOut += uvwIn.zz * transform[2].xy;
	uvOut += transform[3].xy;

	return uvOut;
}

float3 uvwTransform(const float3 uvwIn, const float4x4 transform)
{
	float3 uvwOut = uvwIn.xxx * transform[0].xyz;
	uvwOut += uvwIn.yyy * transform[1].xyz;
	uvwOut += uvwIn.zzz * transform[2].xyz;
	uvwOut += transform[3].xyz;

	return uvwOut;
}

#endif // FX_TEXTRANSFORM_H