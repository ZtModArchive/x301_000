
#ifndef FX_WATER_DISPLACE_H
#define FX_WATER_DISPLACE_H

float4		waterTable[3 * 4 + 4 + 4 + 1 + 1 + 1] : WaterBlock = {
	// 3x4 transforms x 4 - vectors 0 - 11
	{ 0.f, 0.f, 0.f, 0.f },
	{ 0.f, 0.f, 0.f, 0.f },
	{ 0.f, 0.f, 0.f, 0.f },

	{ 0.f, 0.f, 0.f, 0.f },
	{ 0.f, 0.f, 0.f, 0.f },
	{ 0.f, 0.f, 0.f, 0.f },

	{ 0.f, 0.f, 0.f, 0.f },
	{ 0.f, 0.f, 0.f, 0.f },
	{ 0.f, 0.f, 0.f, 0.f },

	{ 0.f, 0.f, 0.f, 0.f },
	{ 0.f, 0.f, 0.f, 0.f },
	{ 0.f, 0.f, 0.f, 0.f },

	// world center * 4 (last float unused) - vectors 12-15
	{ 0.f, 0.f, 0.f, 0.f },
	{ 0.f, 0.f, 0.f, 0.f },
	{ 0.f, 0.f, 0.f, 0.f },
	{ 0.f, 0.f, 0.f, 0.f },

	// radii * 4 (last float unused) - vectors 16 - 19
	{ 0.f, 0.f, 0.f, 0.f },
	{ 0.f, 0.f, 0.f, 0.f },
	{ 0.f, 0.f, 0.f, 0.f },
	{ 0.f, 0.f, 0.f, 0.f },

	// Displacements - vector 20
	{ 0.f, 0.f, 0.f, 0.f },

	// One minus displacements - vector 21
	{ 0.f, 0.f, 0.f, 0.f },

	// One over falloffs - vector 22
	{ 0.f, 0.f, 0.f, 0.f },
};

#define kDisplacements			waterTable[20]
#define kOMDisplacements		waterTable[21]
#define kOOFalloffs				waterTable[22]

#define kCenterBegin			(12)
#define kRadiiBegin				(16)

#define kCenter(i)				waterTable[kCenterBegin + i]
#define kRadii(i)				waterTable[kRadiiBegin + i]

float interpDist(const float4 wPos, const float4 row0, const float4 row1, const float4 row2)
{
	float3 lPos;
	lPos.x = dot(wPos, row0);
	lPos.y = dot(wPos, row1);
	lPos.z = dot(wPos, row2);
	
	return length(lPos);
}

float4 totalDisplacements(const float4 dists)
{
	float4 dInner = saturate(dists) * (kOMDisplacements);

	float4 dOuter = saturate(1.f + dists * kOOFalloffs) * kDisplacements;

	return dInner + dOuter;
}

float3 displaceDir(const float4 wPos, const float3 center, const float3 radii)
{
	return normalize(wPos.xyz - center) * radii;
}

float4 waterDisplace(const float4 wPos)
{
	float4 dists;
	dists.x = interpDist(wPos, waterTable[0], waterTable[1], waterTable[2]);
	dists.y = interpDist(wPos, waterTable[3], waterTable[4], waterTable[5]);
	dists.z = interpDist(wPos, waterTable[6], waterTable[7], waterTable[8]);
	dists.w = interpDist(wPos, waterTable[9], waterTable[10], waterTable[11]);

	dists = 1.f - dists;

	dists = totalDisplacements(dists);

	float4 newPos = wPos;
	newPos.xyz += dists.x * displaceDir(wPos, kCenter(0).xyz, kRadii(0).xyz);
	newPos.xyz += dists.y * displaceDir(wPos, kCenter(1).xyz, kRadii(0).xyz);
	newPos.xyz += dists.z * displaceDir(wPos, kCenter(2).xyz, kRadii(0).xyz);
	newPos.xyz += dists.w * displaceDir(wPos, kCenter(3).xyz, kRadii(0).xyz);
	
	return newPos;
}

#endif // FX_WATER_DISPLACE_H
