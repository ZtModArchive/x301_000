
#ifndef FX_WIND_DISTORT_H
#define FX_WIND_DISTORT_H

#include "interp.h"

float4	kWindBlock[7] : WindBlock = { 
		{0.f, 20.f, 0.f, 0.f},
		{0.f, 0.f, 5.5f, 0.f},
		{0.f, 0.f, 0.f, 0.f },
		{0.5f, 0.5f, 0.5f, 0.f },
		{1.f, 0.f, 0.f, 0.f },
		{0.f, 1.f, 0.f, 0.f },
		{0.f, 0.f, 1.f, 0.f } };


#define kWindDir		(kWindBlock[0])
#define kVibrateVec		(kWindBlock[1])
#define kFreq			(kWindBlock[2])
#define kPhase			(kWindBlock[3])
#define kPerpVec		(kWindBlock[4])
#define kDirVec			(kWindBlock[5])
#define kUpVec			(kWindBlock[6])


float4 windDistort(const float4 worldPos, const float vibration, const float bendiness)
{
	float4 abscissa;
	abscissa.x = dot(worldPos, kPerpVec.xyz) * kFreq.x + kPhase.x;	// direction envelope
	abscissa.y = dot(worldPos, kDirVec.xyz) * kFreq.y + kPhase.y;	// perpendicular envelope
	abscissa.z = dot(worldPos, kUpVec.xyz) * kFreq.z + kPhase.z;				// vertical envelope
	abscissa.w = kPhase.w + worldPos.x * worldPos.y * kFreq.w;	// vibration
	abscissa = smoothwave(abscissa);

	float4 outPos = worldPos;

	outPos.xyz += kVibrateVec.xyz * abscissa.w * vibration;

	float3 bend = kWindDir.xyz * (1.f - abscissa.x * abscissa.y * abscissa.z) * bendiness;
	outPos.xyz += bend;

	return outPos;
}

#endif // FX_WIND_DISTORT_H