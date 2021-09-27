// Big huge monolithic fx file using the fixed function pipeline.

#define MATERIAL 0
#define COLOR1 1
#define COLOR2 2
#define ALWAYS 8
#define ZERO 1
#define ONE 2
#define CW 2
#define MODULATE 4
#define GOURAUD 2
#define WRAP 1

// *** material variables.
float4 materialAmbient			: MaterialAmbient =			{ 1.0f, 1.0f, 1.0f, 1.0f };
float4 materialDiffuse			: MaterialDiffuse =			{ 1.0f, 1.0f, 1.0f, 1.0f };
float4 materialEmissive			: MaterialEmissive =		{ 0.0f, 0.0f, 0.0f, 0.0f };
float4 materialSpecular			: MaterialSpecular =		{ 0.0f, 0.0f, 0.0f, 0.0f };
float materialPower				: MaterialPower =			1.0f;
bool specularEnable				: SpecularEnable =			false;

dword diffuseMaterialSource		: DiffuseMaterialSource =	COLOR1; // D3DMATERIALCOLORSOURCE
dword ambientMaterialSource		: AmbientMaterialSource =	MATERIAL; // D3DMATERIALCOLORSOURCE
dword emissiveMaterialSource	: EmissiveMaterialSource =	MATERIAL; // D3DMATERIALCOLORSOURCE

// *** alpha
bool alphaBlendEnable	: AlphaBlendEnable =	false;
dword destBlend			: DestBlend =			ZERO; // see D3DBLEND
dword srcBlend			: SrcBlend =			ONE; // see D3DBLEND.
dword alphaTestEnable	: AlphaTestEnable =		false;
dword alphaFunc			: AlphaFunc =			ALWAYS;
dword alphaRef			: AlphaRef =			0;

// *** z buffer
dword zEnable				: ZEnable =				true;
dword zWriteEnable			: ZWriteEnable =		true;

// Culling
dword cullMode			: CullMode =			CW; // NONE/CW/CCW

// *** Fog - left out, set globally from outside, except for toggle on and off.
// FogColor, FogDensity, FogEnable, FogEnd, FogStart, FogTableMode, FogVertexMode, RangeFogEnable.
bool fogEnable	: FogEnable =	true;

dword alphaApplyMode			: AlphaApplyMode =			MODULATE;
dword colorApplyMode			: ColorApplyMode =			MODULATE;

// *** Texture functions.	
texture texture0		: Texture0 =		NULL;
dword texCoordIndex0	: TexCoordIndex0 =	0;
dword textureTransformFlags0	: TextureTransformFlags0 =	0;
float4x4 textureTransform0		: TextureTransform0;
// * resultArg[] excluded, lets you draw a texture layer to a different dest.
// * bump map stuff excluded: BumpEnvLScale[], BumpEnvLOffset[], BumpEnvMat00[],
//		BumpEnvMat01[], BumpEnvMat10[], BumpEnvMat11[]

// *** additional pixel pipe states.
dword shadeMode				: ShadeMode =			GOURAUD; // flat/gouraud.

// sampler states.
dword addressU0			: AddressU0 = WRAP;
dword addressV0			: AddressV0 = WRAP;
dword addressW0			: AddressW0 = WRAP;

dword borderColor0		: BorderColor0 = 0;

technique TBasic
{
    pass P0
    {    
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
		
		// additional vertex pipe states.
		// This shouldn't be in the material... it should be driven by the engine
		// NormalizeNormals = (normalizeNormals);

		// NDL never sets this state after initialization,
		// therefor, if we change it, we will break NDL.
		// ColorVertex = (colorVertex);

		// Textures
		Texture[0] = (texture0);

		AlphaOp[0] = SELECTARG1;
		AlphaOp[1] = DISABLE;
		AlphaArg1[0] = CURRENT;
		AlphaArg2[0] = TEXTURE;
		ColorArg1[0] = CURRENT;
		ColorArg2[0] = TEXTURE;
		ColorOp[0] = MODULATE2X;
		ColorOp[1] = DISABLE;

		// sampler states
		AddressU[0] = (addressU0);
		AddressV[0] = (addressV0);
		AddressW[0] = (addressW0);

		TexCoordIndex[0] = (texCoordIndex0);

		TextureTransformFlags[0] = (textureTransformFlags0);

		TextureTransform[0] = (textureTransform0);
    }
}