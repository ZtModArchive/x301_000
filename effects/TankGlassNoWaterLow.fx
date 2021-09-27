
#define Never 1

bool fogEnable					: FogEnable =	true;
dword cullMode					: CullMode = 2;

bool AlphaSort = true;

texture reflectTexture : TextureReflect;
texture glassTexture : TextureGlass;

float4x4 kModelToWorld			: ModelToWorld;
float4x4 kWorldToProj			: WorldToProj;
float4x4 kWorldViewProj			: ModelToProj;
float4x4 kViewToWorld			: ViewToWorld;
float4x4 kWorldToView			: WorldToView;


float4 materialAmbient			: MaterialAmbient =			{ 1.0f, 1.0f, 1.0f, 1.0f };
float4 materialDiffuse			: MaterialDiffuse =			{ 1.0f, 1.0f, 1.0f, 1.0f };
float4 materialEmissive			: MaterialEmissive =		{ 0.0f, 0.0f, 0.0f, 0.0f };
float4 materialSpecular			: MaterialSpecular =		{ 0.0f, 0.0f, 0.0f, 0.0f };
float materialPower				: MaterialPower =			1.0f;


float4x4 glassTransform : GlassTransform = float4x4( 1.0, 0.0, 0.0, 0.0, 
													0.0, 1.0, 0.0, 0.0, 
													0.0, 0.0, 1.0, 0.0, 
													0.0, 0.0, 0.0, 1.0  );


float4x4 reflectViewToUVW				= float4x4( 1.0, 0.0, 0.0, 0.0, 
													0.0, 1.0, 0.0, 0.0, 
													0.0, 0.0, 1.0, 0.0, 
													0.0, 0.0, 0.0, 1.0  );

float4x4 invertTransform				= float4x4( -1.0, 0.0, 0.0, 0.0, 
													0.0, 1.0, 0.0, 0.0, 
													0.0, 0.0, 1.0, 0.0, 
													0.0, 0.0, 0.0, 1.0  );


dword diffuseMaterialSource			: DiffuseMaterialSource =    0;
dword ambientMaterialSource			: AmbientMaterialSource =    0;
dword emissiveMaterialSource		: EmissiveMaterialSource =   0;

sampler MapSampler = sampler_state
{
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	
	AddressU	= Wrap;
	AddressV	= Wrap;
};

// All our LUT specifics
sampler LutSampler = sampler_state
{
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = POINT;

	AddressU	= CLAMP;
	AddressV	= CLAMP;
};

texture lutTexture				: TextureLUT;
dword lutTexCoordIndex			: TexCoordIndexLUT = 1;

float4x4 vecLocalToWorld		: VecToWorld;
float4x4 vecWorldToView			: VecWorldToView;

float4x4 lutScaleOffset : LUTScaleOffset = float4x4( 0.0, 0.0, 0.0, 0.0, 
													0.0, 1.0, 0.0, 0.0, 
													0.5, 0.0, 1.0, 0.0, 
													0.5, 0.0, 0.0, 1.0  );

// End LUT specifics

#include "TankGlassNoneLow_AIO.h"

PixelShader comp_ps_waterAll = compile ps_1_1 ps_waterAll(
											materialAmbient,	// Glass Color
											materialSpecular	// Reflection color.rgb
											);

technique T2
<
	float Quality = 1.1; bool NoRender = false;
>
{
	pass AllPass
	{
		VertexShader = compile vs_1_1 vs_waterAll();
					 
		PixelShader = (comp_ps_waterAll);

		AlphaBlendEnable = true;

		AlphaTestEnable = false;
        AlphaFunc = greater;

		AlphaRef = 0;
		
		Lighting = true;
		SpecularEnable = false;
		CullMode = 1;
		
		ZFunc = LessEqual;
		ZWriteEnable=true;
		ZEnable=true;

        SrcBlend  = One;
        DestBlend = InvSrcAlpha;
	}

#ifdef MF_WIREFRAME_PASS
	pass WireFramePass
	{
	#include "TankDbgWirePass.h"
	CullMode = 2;
	}
#endif // MF_WIREFRAME_PASS

}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FIXED FUNCTION TECHNIQUE
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

technique T0_1
<
	float Quality=0.1;
>
{
	pass GlassFresPass
	{
	#include "TankGlassFresPass.h"
	}

}

technique T0_0
<
	float Quality=0.0;
>
{
	#define HACKY_UNICHROME
		pass GlassFresPass
		{
		#include "TankGlassFresPass.h"
		}
	#undef HACKY_UNICHROME

}