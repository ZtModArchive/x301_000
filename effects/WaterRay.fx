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
dword diffuseMaterialSource			: DiffuseMaterialSource	=	 COLOR1; //	D3DMATERIALCOLORSOURCE
dword ambientMaterialSource			: AmbientMaterialSource	=	 MATERIAL; // D3DMATERIALCOLORSOURCE
dword emissiveMaterialSource		: EmissiveMaterialSource =	  MATERIAL;	// D3DMATERIALCOLORSOURCE

float4 materialSpecular				: MaterialSpecular =			{ 0.0f,	0.0f, 0.0f,	0.0f };
float4 materialAmbient				: MaterialAmbient =			   { 1.0f, 1.0f, 1.0f, 1.0f	};
float4 materialDiffuse				: MaterialDiffuse =			   { 0.0f, 0.0f, 0.0f, 1.0f	};
float4 materialEmissive				: MaterialEmissive =		{ 0.0f,	0.0f, 0.0f,	0.0f };
float materialPower					: MaterialPower	=			 1.0f;

dword ambientColor					: AmbientColor = 0;

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
dword textureTransformFlags0		: TextureTransformFlags0 =	  2;
float4x4 textureTransform0			: TextureTransform0		= float4x4( 1.0, 0.0, 0.0, 0.0, 
																		0.0, 1.0, 0.0, 0.0, 
																		0.0, 0.0, 1.0, 0.0, 
																		0.0, 0.0, 0.0, 1.0  );
texture	texture1					: Texture1 =		NULL;
dword texCoordIndex1				: TexCoordIndex1 =	  0;
dword textureTransformFlags1		: TextureTransformFlags1 =	  2;
float4x4 textureTransform1			: TextureTransform1		= float4x4( 1.0, 0.0, 0.0, 0.0, 
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
dword addressU1						: AddressU1	= WRAP;
dword addressV1						: AddressV1	= WRAP;
dword addressW1						: AddressW1	= WRAP;
dword borderColor0					: BorderColor0 = 0;

technique TBasic
{
	pass P0
	{
		// material
		// NDL will	never use these	states after initialization,
		// therefor, we	shouldn't use them,	otherwise it will trash
		// NDL's state.
		LocalViewer	= true;
		MaterialAmbient	= (materialAmbient); 
		MaterialDiffuse	= (materialDiffuse); 
		MaterialSpecular = (materialSpecular); 
		MaterialEmissive = (materialEmissive);
		MaterialPower =	(materialPower);
		
		AmbientMaterialSource = Color1;
		DiffuseMaterialSource = Material;
		EmissiveMaterialSource = Material;
		SpecularMaterialSource = Material;
		SpecularEnable = false;
//Ambient = float4(0.2, 0.2, 0.2, 0.2);
		Ambient = (ambientColor);

//FillMode=WIREFRAME;

		// alpha
		// can we use conditionals here	to avoid setting everything?
		AlphaBlendEnable = (alphaBlendEnable);
//AlphaBlendEnable = false;
		AlphaFunc =	(alphaFunc);
		AlphaRef = (alphaRef);
		AlphaTestEnable	= (alphaTestEnable);
		DestBlend =	(destBlend);
		SrcBlend = (srcBlend);

		// z buffer.
		ZEnable	= (zEnable);
		ZWriteEnable = (zWriteEnable);
		ZFunc = Always;

		// Culling
		CullMode = (cullMode);

		// additional pixel	pipe states.
		ShadeMode =	(shadeMode);
		FogEnable =	(fogEnable);
FogEnable = false;
				
		// additional vertex pipe states.
		// This	shouldn't be in	the	material...	it should be driven	by the engine
		// NormalizeNormals	= (normalizeNormals);

		// NDL never sets this state after initialization,
		// therefor, if	we change it, we will break	NDL.
		// ColorVertex = (colorVertex);

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
		AlphaOp[0] = SelectArg2;
		
		AlphaArg2[1] = Current;
		AlphaOp[1] = SelectArg2;
		
		AlphaOp[2] = Disable;	  // choose	alpha to write as needed.

		ColorArg1[0] = Texture;
		ColorArg2[0] = Diffuse;
		ColorOp[0] = (colorApplyMode);	  // blend lighting	as needed.
//ColorOp[0] = SelectArg2;
		
		ColorArg1[1] = Texture;
		ColorArg2[1] = Current;
		ColorOp[1] = Modulate;
//ColorOp[1] = SelectArg2;

		ColorOp[2] = Disable;

		// Textures
		Texture[0] = (texture0);
		Texture[1] = (texture1);

		AddressU[0]	= (addressU0);
		AddressV[0]	= (addressV0);

		AddressU[1]	= (addressU1);
		AddressV[1]	= (addressV1);

		TexCoordIndex[0] = (texCoordIndex0);
		TextureTransformFlags[0] = (textureTransformFlags0);
		TextureTransform[0]	= (textureTransform0);

		TexCoordIndex[1] = (texCoordIndex1);
		TextureTransformFlags[1] = (textureTransformFlags1);
		TextureTransform[1]	= (textureTransform1);
	}
}