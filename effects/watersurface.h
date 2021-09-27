
#ifndef FX_WATER_SURFACE_H
#define FX_WATER_SURFACE_H

#include "fog.h"

////////////////////////////////////////////////////////////////////////////////////
float CalcSinCos(const in float4 kDists,
				const in float4 amplitude,
				const in float4 frequency,
				const in float4 phase,
				const in float4 rampOffset,
				const in float4 rampScale,
				const in float scale,
				out float4 sines, out float4 cosines)
{
	// Dot x and y with direction vectors
	float4 dists = kDists;
	
	// Scale in our frequency and add in our phase
	dists = dists * frequency;
	dists = dists - phase;

	const float kPi = 3.14159265f;
	const float kTwoPi = 2.f * kPi;
	const float kOOTwoPi = 1.f / kTwoPi;
	// Mod into range [-Pi..Pi]
	dists = dists + kPi;
	dists = dists * kOOTwoPi;
	dists = frac(dists);
	dists = dists * kTwoPi;
	dists = dists - kPi;

	float4 dists2 = dists * dists; 
	float4 dists3 = dists2 * dists;
	float4 dists4 = dists2 * dists2;
	float4 dists5 = dists3 * dists2;
	float4 dists6 = dists3 * dists3;
	float4 dists7 = dists4 * dists3;

	const float4 kSinConsts = float4(1.f, -1.f/6.f, 1.f/120.f, -1.f/5040.f);
	const float4 kCosConsts = float4(1.f, -1.f/2.f, 1.f/24.f, -1.f/720.f);
	sines = dists + dists3 * kSinConsts.yyyy + dists5 * kSinConsts.zzzz + dists7 * kSinConsts.wwww;
	cosines = kCosConsts.xxxx + dists2 * kCosConsts.yyyy + dists4 * kCosConsts.zzzz + dists6 * kCosConsts.wwww;

	float strength = dot(sines * amplitude, sines * amplitude);

	float4 filteredAmp = scale * amplitude; 
	
	filteredAmp *= 1.f - max(min((kDists - rampOffset) * rampScale, 1.f), 0.f);
	
	sines = sines * filteredAmp;
	cosines = cosines * filteredAmp * scale * frequency;

	return strength;
}

////////////////////////////////////////////////////////////////////////////////////
void CalcScreenPosAndFog(const in float4x4 world2NDC, const in float4 wPos, out float4 scrPos, out float fog)
{
	// Calc screen position and fog from screen W
	// Fog is basic linear from start distance to end distance.
	fog = computeFog(wPos.xyz);
	scrPos = mul(wPos, world2NDC);
}

////////////////////////////////////////////////////////////////////////////////////

// Depth filter channels control:
// dFilter.x => overall opacity
// dFilter.y => reflection strength
// dFilter.z => wave height
float3 CalcDepthFilter(const in float4 depthOffset, const in float4 depthScale, const in float4 wPos, const in float waterLevel)
{
	/*
	float3 dFilter = float3(depthOffset.xyz) - wPos.zzz;

	dFilter = dFilter * float3(depthScale.xyz);
	dFilter = max(dFilter, 0.f);
	dFilter = min(dFilter, 1.f);

	dFilter *= float3(0.5f, 0.5f, 0.5f);
	dFilter += float3(0.5f, 0.5f, 0.5f);

	return dFilter;
	*/

	return float3(1.f, 1.f, 1.f);
}

////////////////////////////////////////////////////////////////////////////////////

// See Pos in CalcTangentBasis comments.
float4 CalcFinalPosition(in float4 wPos, 
						 const in float4 sines, 
						 const in float4 cosines, 
						 const in float depthOffset, 
						 const in float4 dirXK, 
						 const in float4 dirYK)
{
	// Height

	// Sum to a scalar

	wPos.x = wPos.x + dot(cosines, dirXK) * wPos.z;
	wPos.y = wPos.y + dot(cosines, dirYK) * wPos.z;

	// Clamp to never go beneath input height
	float h = dot(sines, 1.f) + depthOffset;
//	wPos.z = max(wPos.z, h);
	wPos.z = h;

	return wPos;
}

////////////////////////////////////////////////////////////////////////////////////

// Normal, binormal, tangent

// Okay, here we go:
// W == sum(k w Dir.x^2 A sin())
// V == sum(k w Dir.x Dir.y A sin())
// U == sum(k w Dir.y^2 A sin())
//
// T == sum(A sin())
//
// S == sum(k Dir.x A cos())
// R == sum(k Dir.y A cos())
//
// Q == sum(k w A cos())
//
// M == sum(A cos())
//
// P == sum(w Dir.x A cos())
// N == sum(w Dir.y A cos())
//
// Then:
// Pos = (in.x + S, in.y + R, waterheight + T)
// 
// Bin = (1 - W, -V, P)
// Tan = (-V, 1 - U, N)
// Nor = (-P, -N, 1 - Q)
//
// Remember we want the transpose of Binormal, Tangent, and Normal
void CalcNormal(const in float4 sines, 
					  const in float4 cosines, 
					  const in float4 dirXW,
					  const in float4 dirYW,
					  const in float4 KW,
					  out float3 norm)
{
// Note that we're swapping Y and Z and negating Z (rotation about X)
// to match the D3D convention of Y being up in cubemaps.

	norm.x = dot(cosines, -dirXW);

	norm.y = dot(cosines, -dirYW);

	norm.z = (1.f + dot(sines, -KW));
}



#endif // FX_WATER_SURFACE_H
