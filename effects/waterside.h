
#ifndef _FX_WATER_SIDE_
#define _FX_WATER_SIDE_

#include "watersurface.h"

struct SideVertIn
{
	float4 Position		: POSITION;
    float4 TexCoord0	: TEXCOORD0; // Maps zero along the top and one at the base.
};

struct SideVertOut
{
    float4 Position		: POSITION;
	float4 Color		: COLOR0;
	float  Fog			: FOG;
};

SideVertOut vs_waterSide(SideVertIn vIn,
					uniform float4x4 kWorld2NDC,
					uniform float4 kWaterColor,
					uniform float4 kFrequency,
					uniform float4 kPhase,
					uniform float4 kAmplitude,
					uniform float4 kPosX,
					uniform float4 kPosY,
					uniform float4 kDepthOffset, // water level is w component
					uniform float4 kRampOffset,
					uniform float4 kRampScale,
					uniform float4 kK
					 )
{
	SideVertOut vOut;

	// Evaluate world space base position. All subsequent calculations in world space.
	float4 wPos = vIn.Position;
	wPos.w = 1.f;

	// Build our 4 waves
	float4 kDirX = wPos.xxxx - kPosX;
	float4 kDirY = wPos.yyyy - kPosY;
	float4 kDirSq = kDirX * kDirX + kDirY * kDirY;
	float4 kInvDir = rsqrt(kDirSq);
	kDirX *= kInvDir;
	kDirY *= kInvDir;
	float4 kDists = 1.f / kInvDir;

	float4 sines;
	float4 cosines;
	CalcSinCos(kDists, 
		kAmplitude, 
		kFrequency, 
		kPhase, 
		kRampOffset, kRampScale,
		1.f, 
		sines, cosines);
		
	float4 kDirXK = kDirX * kK;
	float4 kDirYK = kDirY * kK;

	float origHeight = wPos.z;
	wPos.z = 0.f;
	wPos = CalcFinalPosition(wPos, sines, cosines, kDepthOffset.w, kDirXK, kDirYK);
	wPos.z = min(wPos.z, origHeight);

	// Calc screen position and fog
	CalcScreenPosAndFog(kWorld2NDC, wPos, vOut.Position, vOut.Fog.x);
	float kScale = 0.99999f;
	vOut.Position *= float4(kScale, kScale, kScale*kScale, kScale);

	vOut.Color = kWaterColor;

	return vOut;
}
#endif // _FX_WATER_SIDE_