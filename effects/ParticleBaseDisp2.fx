
#include "ParticleBase.fx"

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
	float4 Diffuse		: COLOR0;
	float3 Normal		: NORMAL;
	float3 TexCoord0	: TEXCOORD0;
	float3 TexCoord1	: TEXCOORD1;
};

struct WindVertOut
{
    float4 Position		: POSITION;
    float4 VColor		: COLOR0;
    float2 TexCoord0	: TEXCOORD0;
    float Fog			: FOG;
};

sampler MapSampler = sampler_state
{
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
};


//#include "waterdisplace.h"

WindVertOut vs_wind_vtxDiffuse(WindVertIn vIn)
{
	WindVertOut vertOut;

	float4 worldPos = mul(vIn.Position, kModelToWorld);

	float3 worldNorm = normalize(mul(vIn.Normal, vecLocalToWorld));

// Removing the heightScale, because it's currently always 0 and
// we currently always want it to be 1. At somepoint, we'll probably
// want individual control over the maximum displacement on any
// given particle (so particles don't blow through the tank walls
// for example) and we can add this back in then.
//	float heightScale = vIn.TexCoord0.z;

	float4 outPos = windDistort(worldPos, kVibration, kSway);

//	outPos = waterDisplace(outPos);

	// WVP transform
	vertOut.Position = mul(outPos, kWorldToProj);

	// Interpolates per pixel
	vertOut.VColor = vIn.Diffuse;
			
	vertOut.TexCoord0 = uvTransform(vIn.TexCoord0.xy, textureTransform0);

	vertOut.Fog = computeFog(outPos);
	
	return vertOut;
}


VertexShader wind_vtxDiffuse = compile vs_1_1 vs_wind_vtxDiffuse();

technique TWind
<
	float Quality = 1.0;
>
{
	pass P0
	{
		VertexShader = (wind_vtxDiffuse);

		// material
		MaterialAmbient	= (materialAmbient); 
		MaterialDiffuse	= (materialDiffuse); 
		MaterialSpecular = (materialSpecular); 
		MaterialEmissive = (materialEmissive);
		MaterialPower =	(materialPower);
		SpecularEnable = (specularEnable);

		// NDL will	never use these	states after initialization,
		// therefor, we	shouldn't use them,	otherwise it will trash
		// NDL's state.
		SpecularMaterialSource = MATERIAL;
		AmbientMaterialSource =	(ambientMaterialSource);
		DiffuseMaterialSource =	(diffuseMaterialSource);
		EmissiveMaterialSource = (emissiveMaterialSource);
		LocalViewer	= true;

		// alpha
		// can we use conditionals here	to avoid setting everything?
		AlphaBlendEnable = (alphaBlendEnable);
		AlphaFunc =	(alphaFunc);
		AlphaRef = (alphaRef);
		AlphaTestEnable	= (alphaTestEnable);
		DestBlend =	(destBlend);
		SrcBlend = (srcBlend);
//AlphaBlendEnable = false;
//AlphaTestEnable = true;
//AlphaRef = 0;
//AlphaFunc = Greater;

		// z buffer.
		ZEnable	= (zEnable);
		ZWriteEnable = (zWriteEnable);

		// Culling
		CullMode = (cullMode);

		// additional pixel	pipe states.
		ShadeMode =	(shadeMode);
		FogEnable =	(fogEnable);

		FogTableMode = None;
				
		// additional vertex pipe states.
		// This	shouldn't be in	the	material...	it should be driven	by the engine
		// NormalizeNormals	= (normalizeNormals);

		// NDL never sets this state after initialization,
		// therefor, if	we change it, we will break	NDL.
		// ColorVertex = (colorVertex);

		// Textures
		Texture[0] = (texture0);

		// APPLY MODES:
		// Apply modes describe	how	texturing should be	modulated with lighting.
		// To be compatible	with NDL apply modes, here are the following conversions:
		//
		//	APPLY_MODULATE:
		//	  Color	= texture color	* vertex color (MODULATE)
		//	  Alpha	= texture alpha	* vertex alpha (MODULATE)
		// 
		//	APPLY_DECAL:
		//	  Color	= texture alpha	* texture color	+ vertex color * ( 1 - texture alpha ) (BLENDCURRENTALPHA)
		//	  Alpha	= vertex alpha (SELECTARG1)
		//
		//	APPLY_REPLACE:
		//	  Color	= texture color	(SELECTARG2)
		//	  Alpha	= texture alpha	(SELECTARG2)

		AlphaArg1[0] = Texture;
		AlphaArg2[0] = Diffuse;
		AlphaOp[0] = (alphaApplyMode);
		
		AlphaOp[1] = Disable;	  

		ColorArg1[0] = Texture;
		ColorArg2[0] = Diffuse;
		ColorOp[0] = (colorApplyMode);	  // blend lighting	as needed.
		
		ColorOp[1] = Disable;

		AddressU[0]	= (addressU0);
		AddressV[0]	= (addressV0);

		TexCoordIndex[0] = (texCoordIndex0);
		TextureTransformFlags[0] = (textureTransformFlags0);
		TextureTransform[0]	= (textureTransform0);
	}
}

