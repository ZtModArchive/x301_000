
// You must have the following standard variables defined before including this file:
//
//	Variable name	: Semantic (if any)
//	-------------------------------------
//	vecLocalToWorld	: VecToWorld
//	kViewToWorld	: ViewToWorld
//	lutScaleOffset	: LUTScaleOffset

float2 sideFadeTexCoord(const float3 worldPos, const float3 texIn)
{
	// Fade out trick using texture coords
	float3 worldNorm = mul(texIn, vecLocalToWorld);
	
	float3 pos2cam = kViewToWorld[3].xyz - worldPos;
	float invDist = rsqrt(dot(pos2cam, pos2cam));
	float dist = 1.f / invDist;
	pos2cam *= invDist;
		
	float dotNorm = dot(pos2cam, worldNorm);
	
	const float kOffDist = 30.f;
	const float kOnDist = 10.f;
	const float kRangeDist = 1.f / (kOffDist - kOnDist);
	float range = saturate((dist - kOnDist) * kRangeDist);

	const float kMinAtten = 1.f;
	const float kMaxAtten = 2.f;
	float atten = kMinAtten + (kMaxAtten - kMinAtten) * range;

//atten = 100.f;
//atten = 1.f;
	dotNorm *= atten;

	dotNorm = dotNorm * lutScaleOffset[2].x + lutScaleOffset[3].x;
	
	float2 texOut = dotNorm;

	return texOut;
}

