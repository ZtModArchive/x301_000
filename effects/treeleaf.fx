
#include "interp.h"

#include "winddistort.h"

#include "shaderrig.h"

#include "fog.h"

bool fogEnable					: FogEnable =	true;

texture leafTexture : Texture0;
texture lutTexture : Texture1;

float	kVibration	: Vibration = 1.f;
float	kSway		: Sway = 1.f;

float3 kWindInfo : WindInfo;

float4x4 kModelToWorld			: ModelToWorld;
float4x4 kWorldToProj			: WorldToProj;
float4x4 kWorldViewProj			: ModelToProj;
float4x4 kViewToWorld			: ViewToWorld;

float4x4 vecLocalToWorld		: VecToWorld;
float4x4 vecWorldToView			: VecWorldToView;

float4x4 lutScaleOffset : LUTScaleOffset = float4x4( 0.0, 0.0, 0.0, 0.0, 
													0.0, 1.0, 0.0, 0.0, 
													0.5, 0.0, 1.0, 0.0, 
													0.5, 0.0, 0.0, 1.0  );

float4 materialAmbient			: MaterialAmbient =			{ 1.0f, 1.0f, 1.0f, 1.0f };
float4 materialDiffuse			: MaterialDiffuse =			{ 1.0f, 1.0f, 1.0f, 1.0f };
float4 materialEmissive			: MaterialEmissive =		{ 0.0f, 0.0f, 0.0f, 0.0f };
float4 materialSpecular			: MaterialSpecular =		{ 0.0f, 0.0f, 0.0f, 0.0f };
float materialPower				: MaterialPower =			1.0f;

dword diffuseMaterialSource			: DiffuseMaterialSource =    0;
dword ambientMaterialSource			: AmbientMaterialSource =    0;
dword emissiveMaterialSource		: EmissiveMaterialSource =   0;

sampler MapSampler = sampler_state
{
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	
	AddressU	= CLAMP;
	AddressV	= CLAMP;
};

sampler LutSampler = sampler_state
{
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = POINT;

	AddressU	= CLAMP;
	AddressV	= CLAMP;
};

struct TreeVertIn
{
	float4 Position		: POSITION;
	float3 Normal		: NORMAL;
	float3 TexCoord0	: TEXCOORD0;
	float3 TexCoord1	: TEXCOORD1;
};

struct TreeVertDiffIn
{
	float4 Position		: POSITION;
	float4 Diffuse		: COLOR0;
	float3 Normal		: NORMAL;
	float3 TexCoord0	: TEXCOORD0;
	float3 TexCoord1	: TEXCOORD1;
};

struct TreeVertOut
{
    float4 Position		: POSITION;
    float4 VColor		: COLOR0;
    float2 TexCoord0	: TEXCOORD0;
    float2 TexCoord1	: TEXCOORD1;
    float Fog			: FOG;
};

#include "sideFadeTexCoord.h"

TreeVertOut vs_tree_matDiffuse(TreeVertIn vIn)
{
	TreeVertOut vertOut;

	float4 worldPos = mul(vIn.Position, kModelToWorld);

	float3 worldNorm = normalize(mul(vIn.Normal, vecLocalToWorld));

	float heightScale = saturate(vIn.TexCoord0.z);

	float4 outPos = windDistort(worldPos, heightScale * kVibration, heightScale * kSway);

	// WVP transform
	vertOut.Position = mul(outPos, kWorldToProj);

	// Interpolates per pixel
	vertOut.VColor = lightFromRig(worldNorm, materialDiffuse, materialEmissive);
			
	vertOut.TexCoord0 = vIn.TexCoord0.xy;
	
	vertOut.TexCoord1.xy = sideFadeTexCoord(outPos.xyz, vIn.TexCoord1);
	
	vertOut.Fog = computeFog(outPos);

	return vertOut;
}


VertexShader tree_matDiffuse = compile vs_1_1 vs_tree_matDiffuse();

technique T2
<
	float Quality=1.1;
>
{

    pass P0
    {
		VertexShader = (tree_matDiffuse);

		// Clip/Raster state
		AlphaBlendEnable = false;
		AlphaTestEnable = true;
        AlphaFunc = greater;
        AlphaRef = 40;
//AlphaBlendEnable = true;
//AlphaTestEnable = false;

        SrcBlend  = One;
        DestBlend = Zero;
//DestBlend = One;

		Lighting = true;
		SpecularEnable = false;
		CullMode = None;
		ZFunc = LessEqual;
		ZWriteEnable=true;
//ZWriteEnable=false;
		ZEnable=true;

		FogEnable = (fogEnable);
		FogTableMode = None;

        MaterialAmbient = (materialAmbient); 
        MaterialDiffuse = (materialDiffuse); 
//MaterialAmbient = (float4(0.0, 0.0, 0.0, 0.0));
//MaterialDiffuse = (float4(0.1, 0.1, 0.1, 0.1));
        MaterialSpecular = (materialSpecular); 
        MaterialEmissive = (materialEmissive);
        MaterialPower = (materialPower);
		
		ColorArg1[0] = Texture;
		ColorArg2[0] = Diffuse;
		ColorOp[0] = Modulate;
//ColorOp[0] = SelectArg2;

		AlphaArg1[0] = Texture;
		AlphaArg2[0] = Diffuse;
		AlphaOp[0] = SelectArg1;
//AlphaOp[0] = SelectArg2;

		ColorArg1[1] = Current;
		ColorArg2[1] = Texture;
		ColorOp[1] = SelectArg1;
//ColorOp[1] = SelectArg2;
//ColorOp[1] = Disable;
		
		AlphaArg1[1] = Current;
		AlphaArg2[1] = Texture;
		AlphaOp[1] = Subtract;
//AlphaOp[1] = SelectArg1;
//AlphaOp[1] = Disable;
				
		ColorOp[2] = Disable;
		AlphaOp[2] = Disable;
		
		AmbientMaterialSource = (ambientMaterialSource);
		DiffuseMaterialSource = (diffuseMaterialSource);
		EmissiveMaterialSource = (emissiveMaterialSource);
		
		Texture[0] = (leafTexture);
		TextureTransformFlags[0] = Disable;
		TexCoordIndex[0] = 0;
		Sampler[0] = (MapSampler);

		Texture[1] = (lutTexture);
// VS - TextureTransformFlags[1] = Count2;
		TextureTransformFlags[1] = Disable;
		TexCoordIndex[1] = 1;
// VS -	TextureTransform[1] = (mul(mul(vecLocalToWorld, vecWorldToView), lutScaleOffset));
		Sampler[1] = (LutSampler);
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FIXED FUNCTION TECHNIQUE
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

technique T1
<
	float Quality=1.0;
>
{

    pass P0
    {
		// Clip/Raster state
		AlphaBlendEnable = false;
		AlphaTestEnable = true;
        AlphaFunc = greater;
        AlphaRef = 40;
//AlphaBlendEnable = true;
//AlphaTestEnable = false;

        SrcBlend  = One;
        DestBlend = Zero;
//DestBlend = One;

		Lighting = true;
		SpecularEnable = false;
		CullMode = None;
		ZFunc = LessEqual;
		ZWriteEnable=true;
//ZWriteEnable=false;
		ZEnable=true;

        MaterialAmbient = (materialAmbient); 
        MaterialDiffuse = (materialDiffuse); 
//MaterialAmbient = (float4(0.0, 0.0, 0.0, 0.0));
//MaterialDiffuse = (float4(0.1, 0.1, 0.1, 0.1));
        MaterialSpecular = (materialSpecular); 
        MaterialEmissive = (materialEmissive);
        MaterialPower = (materialPower);
		
		ColorArg1[0] = Texture;
		ColorArg2[0] = Diffuse;
		ColorOp[0] = Modulate;
//ColorOp[0] = SelectArg2;

		AlphaArg1[0] = Texture;
		AlphaArg2[0] = Diffuse;
		AlphaOp[0] = SelectArg1;
//AlphaOp[0] = SelectArg2;

		ColorArg1[1] = Current;
		ColorArg2[1] = Texture;
		ColorOp[1] = SelectArg1;
//ColorOp[1] = SelectArg2;
//ColorOp[1] = Disable;
		
		AlphaArg1[1] = Current;
		AlphaArg2[1] = Texture;
		AlphaOp[1] = Subtract;
//AlphaOp[1] = SelectArg1;
//AlphaOp[1] = Disable;
				
		ColorOp[2] = Disable;
		AlphaOp[2] = Disable;
		
		AmbientMaterialSource = (ambientMaterialSource);
		DiffuseMaterialSource = (diffuseMaterialSource);
		EmissiveMaterialSource = (emissiveMaterialSource);
		
		// These won't work. The material will set it's values
		// to the renderer, wiping out the renderer's camera state,
		// before the renderer sets the camera state to the material.
		// By that time, it's too late.
//		WorldTransform[0] = (localToWorld);
//		ViewTransform = (worldToCamera);
//		ProjectionTransform = (cameraToNDC);		

		Texture[0] = (leafTexture);
		TextureTransformFlags[0] = Disable;
		TexCoordIndex[0] = 0;
		Sampler[0] = (MapSampler);

		Texture[1] = (lutTexture);
		TextureTransformFlags[1] = Count2;
		TexCoordIndex[1] = 1;
		TextureTransform[1] = (mul(mul(vecLocalToWorld, vecWorldToView), lutScaleOffset));
		Sampler[1] = (LutSampler);

    }
}

technique T0
<
	float Quality=0.0;
>
{

    pass P0
    {
		// Clip/Raster state
		AlphaBlendEnable = false;
		AlphaTestEnable = true;
        AlphaFunc = greater;
        AlphaRef = 20;
//AlphaBlendEnable = true;
//AlphaTestEnable = false;

        SrcBlend  = One;
        DestBlend = Zero;
//DestBlend = One;

		Lighting = true;
		SpecularEnable = false;
		CullMode = None;
		ZFunc = LessEqual;
		ZWriteEnable=true;
//ZWriteEnable=false;
		ZEnable=true;

        MaterialAmbient = (materialAmbient); 
        MaterialDiffuse = (materialDiffuse); 
//MaterialAmbient = (float4(0.0, 0.0, 0.0, 0.0));
//MaterialDiffuse = (float4(0.1, 0.1, 0.1, 0.1));
        MaterialSpecular = (materialSpecular); 
        MaterialEmissive = (materialEmissive);
        MaterialPower = (materialPower);
		
		ColorArg1[0] = Texture;
		ColorArg2[0] = Diffuse;
		ColorOp[0] = Modulate;
//ColorOp[0] = SelectArg2;

		AlphaArg1[0] = Texture;
		AlphaArg2[0] = Diffuse;
		AlphaOp[0] = SelectArg1;
//AlphaOp[0] = SelectArg2;

		ColorArg1[1] = Current;
		ColorArg2[1] = Texture;
		ColorOp[1] = SelectArg1;
//ColorOp[1] = SelectArg2;
//ColorOp[1] = Disable;
		
		AlphaArg1[1] = Current;
		AlphaArg2[1] = Texture | Complement;
		AlphaOp[1] = Modulate;
//AlphaOp[1] = SelectArg1;
//AlphaOp[1] = Disable;
				
		ColorOp[2] = Disable;
		AlphaOp[2] = Disable;
		
		AmbientMaterialSource = (ambientMaterialSource);
		DiffuseMaterialSource = (diffuseMaterialSource);
		EmissiveMaterialSource = (emissiveMaterialSource);
		
		// These won't work. The material will set it's values
		// to the renderer, wiping out the renderer's camera state,
		// before the renderer sets the camera state to the material.
		// By that time, it's too late.
//		WorldTransform[0] = (localToWorld);
//		ViewTransform = (worldToCamera);
//		ProjectionTransform = (cameraToNDC);		

		Texture[0] = (leafTexture);
		TextureTransformFlags[0] = Disable;
		TexCoordIndex[0] = 0;
		Sampler[0] = (MapSampler);

		Texture[1] = (lutTexture);
		TextureTransformFlags[1] = Count2;
		TexCoordIndex[1] = 1;
		TextureTransform[1] = (mul(mul(vecLocalToWorld, vecWorldToView), lutScaleOffset));
		Sampler[1] = (LutSampler);

    }
}
