
#include "BaseDecal.fx"


float4x4 vecLocalToWorld		: VecToWorld;
float4x4 kModelToWorld			: ModelToWorld;
float4x4 kWorldToProj			: WorldToProj;
float4x4 kWorldViewProj			: ModelToProj;

float kVibration	: Vibration = 1.f;
float kSway			: Sway = 1.f;

#include "winddistort.h"
#include "shaderrig.h"
#include "texturetransform.h"
#include "fog.h"

struct WindVertIn
{
	float4 Position		: POSITION;
	float3 Normal		: NORMAL;
	float3 TexCoord0	: TEXCOORD0;
	float3 TexCoord1	: TEXCOORD1;
};

struct WindVertOut
{
    float4 Position		: POSITION;
    float4 VColor		: COLOR0;
    float2 TexCoord0	: TEXCOORD0;
    float2 TexCoord1	: TEXCOORD1;
    float Fog			: FOG;
};

sampler MapSampler = sampler_state
{
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
};

WindVertOut vs_wind_matDiffuse(WindVertIn vIn)
{
	WindVertOut vertOut;

	float4 worldPos = mul(vIn.Position, kModelToWorld);

	float3 worldNorm = normalize(mul(vIn.Normal, vecLocalToWorld));

	float heightScale = saturate(vIn.TexCoord0.z);

	float4 outPos = windDistort(worldPos, heightScale * kVibration, heightScale * kSway);

	// WVP transform
	vertOut.Position = mul(outPos, kWorldToProj);

	// Interpolates per pixel
	vertOut.VColor = lightFromRig(worldNorm, materialDiffuse, materialEmissive);
			
	// See note in Base_wind.fx
	vertOut.TexCoord0 = uvTransform(vIn.TexCoord0.xy, textureTransform0);
	vertOut.TexCoord1 = uvTransform(vIn.TexCoord1.xy, textureTransform1);

	vertOut.Fog = computeFog(outPos);
	
	return vertOut;
}


VertexShader wind_matDiffuse = compile vs_1_1 vs_wind_matDiffuse();

technique TWind
<
	float Quality = 1.1;
>
{
	pass P0
	{
		VertexShader = (wind_matDiffuse);

        // material
        MaterialAmbient = (materialAmbient); 
        MaterialDiffuse = (materialDiffuse); 
        MaterialSpecular = (materialSpecular); 
        MaterialEmissive = (materialEmissive);
        MaterialPower = (materialPower);
		SpecularEnable = (specularEnable);

		// NDL will never use these states after initialization,
		// therefor, we shouldn't use them, otherwise it will trash
		// NDL's state.
		SpecularMaterialSource = MATERIAL;
		AmbientMaterialSource = (ambientMaterialSource);
		DiffuseMaterialSource = (diffuseMaterialSource);
		EmissiveMaterialSource = (emissiveMaterialSource);
		LocalViewer = true;

        // alpha
        // can we use conditionals here to avoid setting everything?
        AlphaBlendEnable = (alphaBlendEnable);
        DestBlend = (destBlend);
        SrcBlend = (srcBlend);
        AlphaTestEnable = (alphaTestEnable);
        AlphaFunc = (alphaFunc);
        AlphaRef = (alphaRef);

		// z buffer.
		ZEnable = (zEnable);
		ZWriteEnable = (zWriteEnable);

		// Culling
		CullMode = (cullMode);

		// additional pixel pipe states.
		ShadeMode = (shadeMode);
		FogEnable = (fogEnable);
		FogTableMode = None;

		// additional vertex pipe states.
		// This shouldn't be in the material... it should be driven by the engine
		// NormalizeNormals = (normalizeNormals);

		// NDL never sets this state after initialization,
		// therefor, if we change it, we will break NDL.
		// ColorVertex = (colorVertex);

		AlphaArg1[0] = TEXTURE;
		AlphaArg2[0] = CURRENT;
		AlphaArg1[1] = TEXTURE;
		AlphaArg2[1] = CURRENT;
		AlphaArg1[2] = DIFFUSE;
		AlphaArg2[2] = CURRENT;

		AlphaOp[0] = SELECTARG1;
		AlphaOp[1] = SELECTARG2;
		AlphaOp[2] = (alphaApplyMode);
		AlphaOp[3] = DISABLE;

		ColorArg1[0] = TEXTURE;
		ColorArg2[0] = CURRENT;
		ColorArg1[1] = TEXTURE;
		ColorArg2[1] = CURRENT;
		ColorArg1[2] = DIFFUSE;
		ColorArg2[2] = CURRENT;

		ColorOp[0] = SELECTARG1;
		ColorOp[1] = BLENDTEXTUREALPHA;
		ColorOp[2] = (colorApplyMode);
		ColorOp[3] = DISABLE;

		// sampler states
		AddressU[0] = (addressU0);
		AddressV[0] = (addressV0);
		AddressW[0] = (addressW0);
		AddressU[1] = (addressU1);
		AddressV[1] = (addressV1);
		AddressW[1] = (addressW1);


		// Textures
		Texture[0] = (texture0);
		Sampler[0] = (MapSampler);
		Texture[1] = (texture1);
		Sampler[1] = (MapSampler);
	}
}

