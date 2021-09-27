// Big huge	monolithic fx file using the fixed function	pipeline.

#define	MATERIAL 0
#define	COLOR1 1
#define	COLOR2 2
#define	ALWAYS 8
#define	ZERO 1
#define	ONE	2
#define	KEEP 0x00000001L
#define	LESSEQUAL 4
#define	CW 2
#define	DISABLE	1
#define	MODULATE 4
#define	SOLID 3
#define	GOURAUD	2
#define	WRAP 1
#define	TRUE 1
#define	FALSE 0

// *** material	variables.
float4 materialSpecular				: MaterialSpecular =			{ 0.0f,	0.0f, 0.0f,	0.0f };
float4 materialAmbient				: MaterialAmbient =			   { 1.0f, 1.0f, 1.0f, 1.0f	};
float4 materialDiffuse				: MaterialDiffuse =			   { 1.0f, 1.0f, 1.0f, 1.0f	};
float4 materialEmissive				: MaterialEmissive =		{ 0.0f,	0.0f, 0.0f,	0.0f };
float materialPower					: MaterialPower	=			 1.0f;
bool specularEnable					: SpecularEnable =			  false;

dword diffuseMaterialSource			: DiffuseMaterialSource	=	 COLOR1; //	D3DMATERIALCOLORSOURCE
dword ambientMaterialSource			: AmbientMaterialSource	=	 MATERIAL; // D3DMATERIALCOLORSOURCE
dword emissiveMaterialSource		: EmissiveMaterialSource =	  MATERIAL;	// D3DMATERIALCOLORSOURCE

// *** alpha
bool alphaBlendEnable				: AlphaBlendEnable =	false;
dword destBlend						: DestBlend	=			 ZERO; // see D3DBLEND
dword srcBlend						: SrcBlend =			ONE; //	see	D3DBLEND.
dword alphaTestEnable				: AlphaTestEnable =		   FALSE;
dword alphaFunc						: AlphaFunc	=			 ALWAYS;
dword alphaRef						: AlphaRef =			0;

// *** z buffer
dword zEnable						: ZEnable =				   true;
dword zWriteEnable					: ZWriteEnable =		TRUE;

// Culling
dword cullMode						: CullMode =			CW;	// NONE/CW/CCW

// *** Lighting	functions explicitly excluded, set globally	from outside.
bool lightingEnable					: LightingEnable =			  true;

// *** Fog - left out, set globally	from outside, except for toggle	on and off.
// FogColor, FogDensity, FogEnable,	FogEnd,	FogStart, FogTableMode,	FogVertexMode, RangeFogEnable.
bool fogEnable						: FogEnable	=	 true;

dword alphaApplyMode				: AlphaApplyMode =			  MODULATE;
dword colorApplyMode				: ColorApplyMode =			  MODULATE;

// *** Texture functions.
texture	texture0					: Texture0 =		NULL;
dword texCoordIndex0				: TexCoordIndex0 =	  0;
dword textureTransformFlags0		: TextureTransformFlags0 =	  0;
float4x4 textureTransform0			: TextureTransform0		= float4x4( 1.0, 0.0, 0.0, 0.0, 
																		0.0, 1.0, 0.0, 0.0, 
																		0.0, 0.0, 1.0, 0.0, 
																		0.0, 0.0, 0.0, 1.0  );
// * resultArg[] excluded, lets	you	draw a texture layer to	a different	dest.
// * bump map stuff	excluded: BumpEnvLScale[], BumpEnvLOffset[], BumpEnvMat00[],
//		  BumpEnvMat01[], BumpEnvMat10[], BumpEnvMat11[]

// *** additional pixel	pipe states.
dword shadeMode						: ShadeMode	=			 GOURAUD; // flat/gouraud.

// *** additional vertex pipe states.
//bool normalizeNormals		   : NormalizeNormals =	   false;
//bool colorVertex			  :	ColorVertex	=			 true;
// * multisample stuff excluded: MultiSampleAntialias &	MultiSampleMask.
// * vertex	blended	excluded: VertexBlend, IndexedVertexBlendEnable, TweenFactor.
// * point stuff excluded: PointScale_A/B/C/Enable,	PointSize/Min/Max, PointSpriteEnable,
//		  PointScaleEnable.
// * n-patch stuff excluded: PatchSegments.

//*** Unexcluding vertex blend stuff, since	it's hosing	us without the reset to	defaults. -mf

// sampler states.
dword addressU0						: AddressU0	= WRAP;
dword addressV0						: AddressV0	= WRAP;
dword addressW0						: AddressW0	= WRAP;
dword borderColor0					: BorderColor0 = 0;

technique TBasic
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
		AlphaFunc =	(alphaFunc);
		AlphaRef = (alphaRef);
		AlphaTestEnable	= (alphaTestEnable);
		DestBlend =	(destBlend);
		SrcBlend = (srcBlend);

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

		AlphaArg1[0] = TEXTURE;
		AlphaArg2[0] = CURRENT;
		AlphaOp[0] = (alphaApplyMode);
		
		AlphaArg2[1] = CURRENT;
		AlphaOp[1] = SelectArg2;
		
		AlphaOp[2] = DISABLE;	  // choose	alpha to write as needed.

		ColorArg1[0] = TEXTURE | COMPLEMENT;
		ColorArg2[0] = CURRENT | COMPLEMENT;
		ColorOp[0] = (colorApplyMode);	  // blend lighting	as needed.
		
		ColorArg1[1] = Current;
		ColorArg2[1] = Current | COMPLEMENT;
		ColorOp[1] = SelectArg2;
		
		ColorOp[2] = DISABLE;

		AddressU[0]	= (addressU0);
		AddressV[0]	= (addressV0);

		TexCoordIndex[0] = (texCoordIndex0);
		TextureTransformFlags[0] = (textureTransformFlags0);
		TextureTransform[0]	= (textureTransform0);
	}
}