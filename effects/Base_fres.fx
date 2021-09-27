

bool fogEnable					: FogEnable =	true;
dword cullMode					: CullMode = 2;

texture leafTexture : Texture0;

float4x4 kModelToWorld			: ModelToWorld;
float4x4 kWorldToProj			: WorldToProj;
float4x4 kWorldViewProj			: ModelToProj;

#define	ZERO 1
#define	ONE	2
dword destBlend						: DestBlend	=			 ZERO; // see D3DBLEND
dword srcBlend						: SrcBlend =			ONE; //	see	D3DBLEND.

dword zEnable						: ZEnable =				   true;
dword zWriteEnable					: ZWriteEnable =			true;

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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FIXED FUNCTION TECHNIQUE
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


technique T0
<
	float Quality=0.0;
>
{

    pass P0
    {
		// Clip/Raster state
		AlphaBlendEnable = true;
		AlphaTestEnable = true;
        AlphaFunc = greater;
        AlphaRef = 0;

        SrcBlend  = (srcBlend);
        DestBlend = (destBlend);
//DestBlend = One;

		Lighting = true;
		SpecularEnable = false;
		CullMode = (cullMode);
		ZFunc = LessEqual;
		ZWriteEnable=(zWriteEnable);
//ZWriteEnable=false;
		ZEnable=(zEnable);

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

		ColorArg1[1] = Texture;
		ColorArg2[1] = Current;
		ColorOp[1] = SelectArg2;
//ColorOp[1] = SelectArg2;
//ColorOp[1] = Disable;
		
		AlphaArg1[1] = Texture | Complement;
		AlphaArg2[1] = Current;
		AlphaOp[1] = Modulate;
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
		TextureTransformFlags[1] = Count2;
		TexCoordIndex[1] = (lutTexCoordIndex);
		TextureTransform[1] = (mul(mul(vecLocalToWorld, vecWorldToView), lutScaleOffset));
		Sampler[1] = (LutSampler);

    }
}
