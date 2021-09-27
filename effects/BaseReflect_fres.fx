// Big huge	monolithic fx file using the fixed function	pipeline.

#define	MATERIAL 0
#define	COLOR1 1
#define	COLOR2 2
#define	ALWAYS 8
#define	ZERO 1
#define	ONE	2
#define	CW 2
#define	MODULATE 4
#define	GOURAUD	2
#define	WRAP 1
#define D3DTSS_TCI_CAMERASPACEREFLECTIONVECTOR 0x30000L
#define D3DTSS_TCI_CAMERASPACENORMAL 0x00010000L
#define SELECTARG1 2
#define SELECTARG2 3

// passed to my by the effect.
float4x4 viewToWorld			: ViewToWorld;

// *** material	variables.
float4 materialAmbient			: MaterialAmbient =			{ 1.0f,	1.0f, 1.0f,	1.0f };
float4 materialDiffuse			: MaterialDiffuse =			{ 1.0f,	1.0f, 1.0f,	1.0f };
float4 materialEmissive			: MaterialEmissive =		{ 0.0f,	0.0f, 0.0f,	0.0f };
float4 materialSpecular			: MaterialSpecular =		{ 0.0f,	0.0f, 0.0f,	0.0f };
float materialPower				: MaterialPower	=			1.0f;
bool specularEnable				: SpecularEnable =			false;

dword diffuseMaterialSource		: DiffuseMaterialSource	=	COLOR1;	// D3DMATERIALCOLORSOURCE
dword ambientMaterialSource		: AmbientMaterialSource	=	MATERIAL; // D3DMATERIALCOLORSOURCE
dword emissiveMaterialSource	: EmissiveMaterialSource =	MATERIAL; // D3DMATERIALCOLORSOURCE

// *** alpha
bool alphaBlendEnable			: AlphaBlendEnable =	false;
dword destBlend					: DestBlend	=			ZERO; // see D3DBLEND
dword srcBlend					: SrcBlend =			ONE; //	see	D3DBLEND.
dword alphaTestEnable			: AlphaTestEnable =		false;
dword alphaFunc					: AlphaFunc	=			ALWAYS;
dword alphaRef					: AlphaRef =			0;

// *** z buffer
dword zEnable					: ZEnable =				true;
dword zWriteEnable				: ZWriteEnable =		true;

// Culling
dword cullMode					: CullMode =			CW;	// NONE/CW/CCW

// *** Fog - left out, set globally	from outside, except for toggle	on and off.
// FogColor, FogDensity, FogEnable,	FogEnd,	FogStart, FogTableMode,	FogVertexMode, RangeFogEnable.
bool fogEnable					: FogEnable	=	true;

dword alphaApplyMode			: AlphaApplyMode =			MODULATE;
dword colorApplyMode			: ColorApplyMode =			MODULATE;

// *** Texture functions.	
texture	texture0				: Texture0 =		NULL;
texture	texture1				: Texture1 =		NULL;

dword texCoordIndex0			: TexCoordIndex0 =	0;
dword textureTransformFlags0	: TextureTransformFlags0 =	0;
float4x4 textureTransform0		: TextureTransform0		= float4x4( 1.0, 0.0, 0.0, 0.0, 
																		0.0, 1.0, 0.0, 0.0, 
																		0.0, 0.0, 1.0, 0.0, 
																		0.0, 0.0, 0.0, 1.0  );
// * resultArg[] excluded, lets	you	draw a texture layer to	a different	dest.
// * bump map stuff	excluded: BumpEnvLScale[], BumpEnvLOffset[], BumpEnvMat00[],
//		BumpEnvMat01[],	BumpEnvMat10[],	BumpEnvMat11[]

// *** additional pixel	pipe states.
dword shadeMode					: ShadeMode	=			GOURAUD; //	flat/gouraud.

// sampler states.
dword addressU0			: AddressU0	= WRAP;
dword addressV0			: AddressV0	= WRAP;
dword addressW0			: AddressW0	= WRAP;
dword borderColor0		: BorderColor0 = 0;

// All our LUT specifics
sampler lutSampler = sampler_state
{
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = POINT;

	AddressU	= CLAMP;
	AddressV	= CLAMP;
};

texture lutTexture				: TextureLUT =		NULL;
dword lutTexCoordIndex			: TexCoordIndexLUT = 1;

float4x4 vecLocalToWorld		: VecToWorld;
float4x4 vecWorldToView			: VecWorldToView;

float4x4 lutScaleOffset : LUTScaleOffset = float4x4( 0.0, 0.0, 0.0, 0.0, 
													0.0, 1.0, 0.0, 0.0, 
													0.5, 0.0, 1.0, 0.0, 
													0.5, 0.0, 0.0, 1.0  );
// End LUT specifics

technique TAdvanced
	< float Quality = 1.0; >
{
	pass P0
	{
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
		DestBlend =	(destBlend);
		SrcBlend = (srcBlend);
		AlphaTestEnable	= (alphaTestEnable);
		AlphaFunc =	(alphaFunc);
		AlphaRef = (alphaRef);
//AlphaBlendEnable = false;
//AlphaTestEnable = false;

		// z buffer.
		ZEnable	= (zEnable);
		ZWriteEnable = (zWriteEnable);

		// Culling
		CullMode = (cullMode);

		// additional pixel	pipe states.
		ShadeMode =	(shadeMode);
		FogEnable =	(fogEnable);

		// additional vertex pipe states.
		// This	shouldn't be in	the	material...	it should be driven	by the engine
		// NormalizeNormals	= (normalizeNormals);

		// NDL never sets this state after initialization,
		// therefor, if	we change it, we will break	NDL.
		// ColorVertex = (colorVertex);

		// Setup stages
		ColorArg1[0] = Texture;
		ColorArg2[0] = Diffuse;
		ColorOp[0] = (colorApplyMode);

		AlphaArg1[0] = Texture;
		AlphaArg2[0] = Diffuse;
		AlphaOp[0] = (alphaApplyMode);
AlphaOp[0] = SelectArg1; // Ignore diffuse alpha, we're alpha'd out enough by the LUT

		ColorArg1[1] = Texture;
		ColorArg2[1] = Current;
		ColorOp[1] = SelectArg2; // if this is an additive blend to the FB, this should be modulate by alpha
//ColorOp[1] = SelectArg1;
		
		AlphaArg1[1] = Texture | Complement;
		AlphaArg2[1] = Current;
		AlphaOp[1] = Modulate;
				
		ColorOp[2] = Disable;
		AlphaOp[2] = Disable;

		// Setup textures
		Texture[0] = (texture0);
		// sampler states
		AddressU[0]	= (addressU0);
		AddressV[0]	= (addressV0);
		AddressW[0]	= (addressW0);
		TexCoordIndex[0] = (texCoordIndex0);
		TextureTransformFlags[0] = (textureTransformFlags0);
		TextureTransform[0]	= (textureTransform0);

		Texture[1] = (lutTexture);
		TextureTransformFlags[1] = Count2;
		TexCoordIndex[1] = (lutTexCoordIndex);
		TextureTransform[1] = (mul(mul(vecLocalToWorld, vecWorldToView), lutScaleOffset));
		Sampler[1] = (lutSampler);


	}
	pass P1
	{
		// do the cube map reflection.
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
		NormalizeNormals = true;

		// alpha
		// can we use conditionals here	to avoid setting everything?
		AlphaBlendEnable = true;
		DestBlend =	ONE;
		SrcBlend = ONE;
		AlphaTestEnable	= true;
		AlphaFunc =	GREATEREQUAL;
		AlphaRef = 10;

		// z buffer.
		ZEnable	= (zEnable);
		ZWriteEnable = false;

		// Culling
		CullMode = (cullMode);

		// additional pixel	pipe states.
		ShadeMode =	(shadeMode);
		FogEnable =	(fogEnable);

		// additional vertex pipe states.
		// This	shouldn't be in	the	material...	it should be driven	by the engine
		// NormalizeNormals	= (normalizeNormals);

		// NDL never sets this state after initialization,
		// therefor, if	we change it, we will break	NDL.
		// ColorVertex = (colorVertex);

		ColorArg1[0] = Texture;
		ColorArg2[0] = Diffuse;
		ColorOp[0] = SelectArg1;

		AlphaArg1[0] = Texture;
		AlphaArg2[0] = Diffuse;
		AlphaOp[0] = SelectArg1;

		ColorArg1[1] = Texture | Complement;
		ColorArg2[1] = Current;
		ColorOp[1] = Modulate;
		
		AlphaArg1[1] = Texture;
		AlphaArg2[1] = Current;
		AlphaOp[1] = SelectArg2;
				
		ColorOp[2] = Disable;
		AlphaOp[2] = Disable;
ColorOp[1] = Disable;
AlphaOp[1] = Disable;

		// Textures
		Texture[0] = (texture1);
		// sampler states
		AddressU[0]	= (addressU0);
		AddressV[0]	= (addressV0);
		AddressW[0]	= (addressW0);

		TexCoordIndex[0] = (D3DTSS_TCI_CAMERASPACEREFLECTIONVECTOR);

		TextureTransformFlags[0] = COUNT3;

		TextureTransform[0]	= float4x3(viewToWorld[0].xzy, viewToWorld[1].xzy, viewToWorld[2].xzy, float3(0, 0, 0));

/*
		Texture[1] = (lutTexture);
		TextureTransformFlags[1] = Count2;
		TexCoordIndex[1] = (lutTexCoordIndex);
		TextureTransform[1] = (mul(mul(vecLocalToWorld, vecWorldToView), lutScaleOffset));
		Sampler[1] = (lutSampler);
*/
	}
}

technique TBasic
	< float Quality = 0.0; >
{
	pass P0
	{
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
		DestBlend =	(destBlend);
		SrcBlend = (srcBlend);
		AlphaTestEnable	= (alphaTestEnable);
		AlphaFunc =	(alphaFunc);
		AlphaRef = (alphaRef);

		// z buffer.
		ZEnable	= (zEnable);
		ZWriteEnable = (zWriteEnable);

		// Culling
		CullMode = (cullMode);

		// additional pixel	pipe states.
		ShadeMode =	(shadeMode);
		FogEnable =	(fogEnable);

		// additional vertex pipe states.
		// This	shouldn't be in	the	material...	it should be driven	by the engine
		// NormalizeNormals	= (normalizeNormals);

		// NDL never sets this state after initialization,
		// therefor, if	we change it, we will break	NDL.
		// ColorVertex = (colorVertex);

		ColorArg1[0] = Texture;
		ColorArg2[0] = Diffuse;
		ColorOp[0] = (colorApplyMode);

		AlphaArg1[0] = Texture;
		AlphaArg2[0] = Diffuse;
		AlphaOp[0] = (alphaApplyMode);
		
		ColorArg1[1] = Texture;
		ColorArg2[1] = Current;
		ColorOp[1] = SelectArg2;

		AlphaArg1[1] = Texture;
		AlphaArg2[1] = Current;
		AlphaOp[1] = Modulate;

		ColorOp[2] = Disable;
		AlphaOp[2] = Disable;

		// sampler states
		AddressU[0]	= (addressU0);
		AddressV[0]	= (addressV0);

		// Textures
		Texture[0] = (texture0);

		TexCoordIndex[0] = (texCoordIndex0);
		TextureTransformFlags[0] = (textureTransformFlags0);
		TextureTransform[0]	= (textureTransform0);

		Texture[1] = (lutTexture);
		TextureTransformFlags[1] = Count2;
		TexCoordIndex[1] = (lutTexCoordIndex);
		TextureTransform[1] = (mul(mul(vecLocalToWorld, vecWorldToView), lutScaleOffset));
		Sampler[1] = (lutSampler);
	}
}
