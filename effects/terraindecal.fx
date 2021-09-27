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
#define	SOLID 3
#define	GOURAUD	2
#define	TRUE 1
#define	FALSE 0
#define	SELECTARG2 3
#define	SELECTARG1 2

// *** material	variables.
float4 materialDiffuse				: MaterialDiffuse =			{ 1.0f,	1.0f, 1.0f,	1.0f };

// *** alpha
bool alphaBlendEnable				: AlphaBlendEnable =		false;
dword alphaTestEnable				: AlphaTestEnable =			FALSE;
dword alphaFunc						: AlphaFunc	=				ALWAYS;
dword alphaRef						: AlphaRef =				0;

// set the apply mode.
dword detailApplyOp					: DetailApplyOp	=			SELECTARG2;	// arg1	= texture, arg2	= current.
dword lightApplyOp					: LightApplyOp =			SELECTARG1;	// arg1	= diffuse, arg2	= current.

// *** Texture functions.
texture	baseTexture					: BaseTexture =				NULL;
texture	detailTexture				: DetailTexture	=			NULL;

dword texCoordIndex0			: TexCoordIndex0 =	0;
dword texCoordIndex1			: TexCoordIndex1 =	1;
dword textureTransformFlags0	: TextureTransformFlags0 =	0;
dword textureTransformFlags1	: TextureTransformFlags1 =	0;
float4x4 textureTransform0		: TextureTransform0;
float4x4 textureTransform1		: TextureTransform1;

// *** additional vertex pipe states.
//bool normalizeNormals		   : NormalizeNormals =	   false;
//bool colorVertex			  :	ColorVertex	=			 true;
// * multisample stuff excluded: MultiSampleAntialias &	MultiSampleMask.
// * vertex	blended	excluded: VertexBlend, IndexedVertexBlendEnable, TweenFactor.
// * point stuff excluded: PointScale_A/B/C/Enable,	PointSize/Min/Max, PointSpriteEnable,
//		  PointScaleEnable.
// * n-patch stuff excluded: PatchSegments.

technique TDecal // this technique needs to keep 2 textures because the detail map is used for 'important' stuff
	< float Quality = 0.0; >
{
	pass P0
	{
		// material
		MaterialAmbient = float4( 1.0f, 1.0f, 1.0f, 1.0f );
		MaterialSpecular = float4( 1.0f, 1.0f, 1.0f, 1.0f );
		MaterialDiffuse	= (materialDiffuse); 
		MaterialEmissive = float4( 0.3f, 0.3f, 0.3f, 1.0f );
		MaterialPower = 20.0f;
		SpecularEnable = true;
		LocalViewer = true;

		// NDL will	never use these	states after initialization,
		// therefor, we	shouldn't use them,	otherwise it will trash
		// NDL's state.
        SpecularMaterialSource = MATERIAL;
        AmbientMaterialSource = MATERIAL;
        DiffuseMaterialSource = MATERIAL;
        EmissiveMaterialSource = MATERIAL;

		// alpha
		// can we use conditionals here	to avoid setting everything?
		AlphaBlendEnable = (alphaBlendEnable);
		SrcBlend = SRCALPHA;
		DestBlend =	INVSRCALPHA;
		AlphaTestEnable	= (alphaTestEnable);
		AlphaFunc =	(alphaFunc);
		AlphaRef = (alphaRef);

		// z buffer.
		ZEnable	= true;
		ZWriteEnable = false;

		// Culling
//		CullMode = (cullMode);

		// additional pixel	pipe states.

		// additional vertex pipe states.
		// This	shouldn't be in	the	material...	it should be driven	by the engine
		// NormalizeNormals	= (normalizeNormals);

		// NDL never sets this state after initialization,
		// therefor, if	we change it, we will break	NDL.
		// ColorVertex = (colorVertex);

		// Textures
		Texture[0] = (baseTexture);
		Texture[1] = (detailTexture);

		AlphaArg1[0] = TEXTURE;
		AlphaArg2[0] = CURRENT;
		AlphaArg1[1] = TEXTURE;
		AlphaArg2[1] = CURRENT;
		AlphaArg1[2] = DIFFUSE;
		AlphaArg2[2] = CURRENT;

		AlphaOp[0] = MODULATE;			// modulate	with incoming vertex alpha.
		AlphaOp[1] = (detailApplyOp);
		AlphaOp[2] = DISABLE;				// blend alpha.

		ColorArg1[0] = TEXTURE;
		ColorArg2[0] = CURRENT;
		ColorArg1[1] = TEXTURE;
		ColorArg2[1] = CURRENT;

		ColorOp[0] = (lightApplyOp);			// select the texture.
		ColorOp[1] = (detailApplyOp);
		ColorOp[2] = DISABLE;		// blend lighting as needed.

		AddressU[0]	= CLAMP;
		AddressV[0]	= CLAMP;
		AddressU[1]	= WRAP;
		AddressV[1]	= WRAP;

		TexCoordIndex[0] = (texCoordIndex0);
		TexCoordIndex[1] = (texCoordIndex1);

		TextureTransformFlags[0] = (textureTransformFlags0);
		TextureTransformFlags[1] = (textureTransformFlags1);

		TextureTransform[0]	= (textureTransform0);
		TextureTransform[1]	= (textureTransform1);
		
		MinFilter[0] = LINEAR;	// bilinear filter.
		MagFilter[0] = LINEAR;
		MipFilter[0] = NONE;
		MinFilter[1] = LINEAR;	// trilinear filter.
		MagFilter[1] = LINEAR;
		MipFilter[1] = LINEAR;
	}
}
