
#include "causticdefault.fx"

float4x4 kModelToWorld			: ModelToWorld;
float4x4 vecLocalToWorld		: VecToWorld;
float4x4 kWorldToProj			: WorldToProj;
float4x4 kWorldViewProj			: ModelToProj;

float4x4 kWorldToCaustic0		: WorldToCaustic0;
float4x4 kWorldToCaustic1		: WorldToCaustic1;
float4	kHeightRamp				: HeightRamp;

float4	kCausticTint			: CausticTint;


float kVibration	: Vibration = 1.f;
float kSway			: Sway = 1.f;

#include "winddistort.h"
#include "shaderrig.h"
#include "texturetransform.h"
#include "fog.h"

struct WindVertIn
{
	float4 Position		: POSITION;
	float3 TexCoord0	: TEXCOORD0;
};

struct WindVertOut
{
    float4 Position		: POSITION;
    float4 VColor		: COLOR0;
    float2 TexCoord0	: TEXCOORD0;
    float2 TexCoord1	: TEXCOORD1;
    float2 TexCoord2	: TEXCOORD2;
    float	Fog			: FOG;
};

sampler MapSampler = sampler_state
{
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
};

//#include "waterdisplace.h"

WindVertOut vs_wind_caustic(WindVertIn vIn)
{
	WindVertOut vertOut;

	float4 worldPos = mul(vIn.Position, kModelToWorld);

	float heightScale = saturate(vIn.TexCoord0.z);

	float4 outPos = windDistort(worldPos, heightScale * kVibration, heightScale * kSway);

//outPos = waterDisplace(outPos);

	// WVP transform
	vertOut.Position = mul(outPos, kWorldToProj);

	// Interpolates per pixel
	float heightRamp = saturate((outPos.z - kHeightRamp.x) * kHeightRamp.y);
	vertOut.VColor = kCausticTint * heightRamp;
			
	vertOut.TexCoord0 = uvTransform(vIn.TexCoord0.xy, textureTransform0);
	vertOut.TexCoord1 = mul(outPos, kWorldToCaustic0).xy;
	vertOut.TexCoord2 = mul(outPos, kWorldToCaustic1).xy;

	vertOut.Fog = computeFog(outPos);
	
	return vertOut;
}


VertexShader wind_caustic = compile vs_1_1 vs_wind_caustic();

technique TWind
<
	float Quality = 1.0;
>
{
	pass P0
	{
		VertexShader = (wind_caustic);

		ZWriteEnable = false;
		AlphaBlendEnable = true;

		SrcBlend = One;
		DestBlend = One;
//DestBlend = Zero;

		FogColor = 0;

		Texture[0] = (texture0);
		Texture[1] = (causticMap0);
		Texture[2] = (causticMap1);

		ColorArg1[0] = Texture | AlphaReplicate;
		ColorArg2[0] = Diffuse;
		ColorOp[0] = Modulate;
//ColorOp[0] = SelectArg1;

		ColorArg1[1] = Texture;
		ColorArg2[1] = Current;
		ColorOp[1] = Modulate;
		
		ColorArg1[2] = Texture;
		ColorArg2[2] = Current;
		ColorOp[2] = Modulate;

		ColorOp[3] = Disable;

		AlphaArg1[0] = Texture;
		AlphaArg2[0] = Diffuse;
		AlphaOp[0] = SelectArg2;
		
		AlphaArg1[1] = Texture;
		AlphaArg2[1] = Current;
		AlphaOp[1] = SelectArg2;

		AlphaArg1[2] = Texture;
		AlphaArg2[2] = Current;
		AlphaOp[2] = SelectArg2;

		AlphaOp[3] = Disable;

		// sampler states
		AddressU[0]	= (addressU0);
		AddressV[0]	= (addressV0);
		AddressU[1] = Wrap;
		AddressV[1] = Wrap;
		AddressU[2] = Wrap;
		AddressV[2] = Wrap;

		AddressU[3] = CLAMP;
		AddressV[3] = CLAMP;
	}
}

