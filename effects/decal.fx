// Big huge monolithic fx file using the fixed function pipeline.

#define MATERIAL 0
#define COLOR1 1
#define COLOR2 2
#define ALWAYS 8
#define ADD 1
#define ZERO 1
#define ONE 2
#define KEEP 0x00000001L
#define LESSEQUAL 4
#define CW 2
#define CCW 3
#define DISABLE 1
#define SELECTARG1 2
#define MODULATE 4
#define MODULATE2X 5
#define ADD2X 9
#define SOLID 3
#define GOURAUD 2
#define TRUE 1
#define FALSE 0
#define CURRENT 0x00000001
#define TEXTURE 0x00000002
#define WRAP 1
#define MIRROR 2
#define CLAMP 3
#define BORDER 4
#define MIRRORONCE 5
#define NONE 0
#define POINT 1
#define LINEAR 2

// *** material variables.

float alphaValue				: AlphaValue =				1.0f;

dword specularMaterialSource	: SpecularMaterialSource =	MATERIAL; // D3DMATERIALCOLORSOURCE
dword diffuseMaterialSource		: DiffuseMaterialSource =	MATERIAL; // D3DMATERIALCOLORSOURCE
dword ambientMaterialSource		: AmbientMaterialSource =	MATERIAL; // D3DMATERIALCOLORSOURCE
dword emissiveMaterialSource	: EmissiveMaterialSource =	MATERIAL; // D3DMATERIALCOLORSOURCE

//float4 ambient					: Ambient =					{ 1.0f, 1.0f, 1.0f, 1.0f };
bool localViewer				: LocalViewer =				true; // sets where specular comes from.

// *** alpha
bool alphaBlendEnable	: AlphaBlendEnable =	false;
dword alphaFunc			: AlphaFunc =			ALWAYS;
dword alphaRef			: AlphaRef =			0;
dword alphaTestEnable	: AlphaTestEnable =		FALSE;
dword blendOp			: BlendOp =				ADD; // add/subtract/revsubtract/min/max
dword destBlend			: DestBlend =			ZERO; // see D3DBLEND
dword srcBlend			: SrcBlend =			ONE; // see D3DBLEND.

// *** stencil
bool stencilEnable		: StencilEnable =		false;
dword stencilFail		: StencilFail =			KEEP; // see D3DSTENCILCAPS
dword stencilFunc		: StencilFunc =			ALWAYS; // see D3DCMPFUNC
dword stencilMask		: StencilMask =			0xFFFFFFFF;
dword stencilPass		: StencilPass =			KEEP; // see D3DSTENCILCAPS
int stencilRef			: StencilRef =			0;
dword stencilWriteMask	: StencilWriteMask =	0xFFFFFFFF;
dword stencilZFail		: StencilZFail =		KEEP; // see D3DSTENCILCAPS

// *** z buffer
dword zEnable				: ZEnable =				true;
dword zFunc					: ZFunc =				LESSEQUAL; // see D3DCMPFUNC
dword zWriteEnable			: ZWriteEnable =		FALSE;
float depthBias				: DepthBias =			0;
float slopeScaleDepthBias	: SlopeScaleDepthBias =	0;

// Culling
dword cullMode			: CullMode =			CW; // NONE/CW/CCW

// *** Lighting functions explicitly excluded, set globally from outside.
bool lightingEnable : LightingEnable =			true;

// *** Fog - left out, set globally from outside, except for toggle on and off.
// FogColor, FogDensity, FogEnable, FogEnd, FogStart, FogTableMode, FogVertexMode, RangeFogEnable.
bool fogEnable	: FogEnable =	true;

// *** Texture functions.	
texture texture0		: Texture0 =		NULL;
texture texture1		: Texture1 =		NULL;
texture texture2		: Texture2 =		NULL;
texture texture3		: Texture3 =		NULL;
dword textureFactor		: TextureFactor =	0xFFFFFFFF;
dword alphaOp0			: AlphaOp0 =		MODULATE;
dword alphaOp1			: AlphaOp1 =		DISABLE;
dword alphaOp2			: AlphaOp2 =		DISABLE;
dword alphaOp3			: AlphaOp3 =		DISABLE;
dword alphaArg00		: AlphaArg00 =		CURRENT;
dword alphaArg01		: AlphaArg01 =		CURRENT;
dword alphaArg02		: AlphaArg02 =		CURRENT;
dword alphaArg03		: AlphaArg03 =		CURRENT;
dword alphaArg10		: AlphaArg10 =		TEXTURE;
dword alphaArg11		: AlphaArg11 =		TEXTURE;
dword alphaArg12		: AlphaArg12 =		TEXTURE;
dword alphaArg13		: AlphaArg13 =		TEXTURE;
dword alphaArg20		: AlphaArg20 =		CURRENT;
dword alphaArg21		: AlphaArg21 =		CURRENT;
dword alphaArg22		: AlphaArg22 =		CURRENT;
dword alphaArg23		: AlphaArg23 =		CURRENT;
dword colorArg00		: ColorArg00 =		CURRENT;
dword colorArg01		: ColorArg01 =		CURRENT;
dword colorArg02		: ColorArg02 =		CURRENT;
dword colorArg03		: ColorArg03 =		CURRENT;
dword colorArg10		: ColorArg10 =		TEXTURE;
dword colorArg11		: ColorArg11 =		TEXTURE;
dword colorArg12		: ColorArg12 =		TEXTURE;
dword colorArg13		: ColorArg13 =		TEXTURE;
dword colorArg20		: ColorArg20 =		CURRENT;
dword colorArg21		: ColorArg21 =		CURRENT;
dword colorArg22		: ColorArg22 =		CURRENT;
dword colorArg23		: ColorArg23 =		CURRENT;
dword colorOp0			: ColorOp0 =		MODULATE;
dword colorOp1			: ColorOp1 =		DISABLE;
dword colorOp2			: ColorOp2 =		DISABLE;
dword colorOp3			: ColorOp3 =		DISABLE;
dword texCoordIndex0	: TexCoordIndex0 =	0;
dword texCoordIndex1	: TexCoordIndex1 =	1;
dword texCoordIndex2	: TexCoordIndex2 =	0;
dword texCoordIndex3	: TexCoordIndex3 =	0;
dword textureTransformFlags0	: TextureTransformFlags0 =	2;		// matrix 3x2.
dword textureTransformFlags1	: TextureTransformFlags1 =	0;
dword textureTransformFlags2	: TextureTransformFlags2 =	0;
dword textureTransformFlags3	: TextureTransformFlags3 =	0;
float4x4 textureTransform0		: TextureTransform0;
float4x4 textureTransform1		: TextureTransform1;
float4x4 textureTransform2		: TextureTransform2;
float4x4 textureTransform3		: TextureTransform3;
// * resultArg[] excluded, lets you draw a texture layer to a different dest.
// * bump map stuff excluded: BumpEnvLScale[], BumpEnvLOffset[], BumpEnvMat00[],
//		BumpEnvMat01[], BumpEnvMat10[], BumpEnvMat11[]

// *** additional pixel pipe states.
dword colorWriteEnable		: ColorWriteEnable =	0x0000000F;
bool ditherEnable			: DitherEnable =		false;
dword fillMode				: FillMode =			SOLID; // solid/point/wireframe
dword lastPixel				: LastPixel =			TRUE; // draw the last pixel or not.
dword shadeMode				: ShadeMode =			GOURAUD; // flat/gouraud.

// *** additional vertex pipe states.
//bool normalizeNormals		: NormalizeNormals =	false;
//bool colorVertex			: ColorVertex =			true;
// * multisample stuff excluded: MultiSampleAntialias & MultiSampleMask.
// * vertex blended excluded: VertexBlend, IndexedVertexBlendEnable, TweenFactor.
// * point stuff excluded: PointScale_A/B/C/Enable, PointSize/Min/Max, PointSpriteEnable,
//		PointScaleEnable.
// * n-patch stuff excluded: PatchSegments.

// sampler states.
dword addressU0			: AddressU0 = CLAMP;
dword addressU1			: AddressU1 = WRAP;
dword addressU2			: AddressU2 = WRAP;
dword addressU3			: AddressU3 = WRAP;
dword addressV0			: AddressV0 = CLAMP;
dword addressV1			: AddressV1 = WRAP;
dword addressV2			: AddressV2 = WRAP;
dword addressV3			: AddressV3 = WRAP;
dword addressW0			: AddressW0 = WRAP;
dword addressW1			: AddressW1 = WRAP;
dword addressW2			: AddressW2 = WRAP;
dword addressW3			: AddressW3 = WRAP;
dword borderColor0		: BorderColor0 = 0;
dword borderColor1		: BorderColor1 = 0;
dword borderColor2		: BorderColor2 = 0;
dword borderColor3		: BorderColor3 = 0;

// This shouldn't be driven by a material, right? It is an engine-driven state IMO!
dword magFilter0		: MagFilter0 = LINEAR;
dword magFilter1		: MagFilter1 = LINEAR;
dword magFilter2		: MagFilter2 = LINEAR;
dword magFilter3		: MagFilter3 = LINEAR;
dword minFilter0		: MinFilter0 = LINEAR;
dword minFilter1		: MinFilter1 = LINEAR;
dword minFilter2		: MinFilter2 = LINEAR;
dword minFilter3		: MinFilter3 = LINEAR;
dword mipFilter0		: MipFilter0 = NONE;
dword mipFilter1		: MipFilter1 = LINEAR;
dword mipFilter2		: MipFilter2 = NONE;
dword mipFilter3		: MipFilter3 = NONE;

technique TBasic
{
    pass P0
    {
		// Lighting
		Lighting = (lightingEnable);
    
        // material

		// NDL will never use these states after initialization,
		// therefor, we shouldn't use them, otherwise it will trash
		// NDL's state.
		SpecularMaterialSource = (specularMaterialSource);
		AmbientMaterialSource = (ambientMaterialSource);
		DiffuseMaterialSource = (diffuseMaterialSource);
		EmissiveMaterialSource = (emissiveMaterialSource);
//		Ambient = (ambient);
		LocalViewer = (localViewer);

        // alpha
        // can we use conditionals here to avoid setting everything?
        AlphaBlendEnable = (alphaBlendEnable);
        AlphaFunc = (alphaFunc);
        AlphaRef = (alphaRef);
        AlphaTestEnable = (alphaTestEnable);
        BlendOp = (blendOp);
        DestBlend = (destBlend);
        SrcBlend = (srcBlend);

		// stencil.
		StencilEnable = (stencilEnable);
		StencilFail = (stencilFail);
		StencilFunc = (stencilFunc);
		StencilMask = (stencilMask);
		StencilPass = (stencilPass);
		StencilRef = (stencilRef);
		StencilWriteMask = (stencilWriteMask);
		StencilZFail = (stencilZFail);

		// z buffer.
		ZEnable = (zEnable);
		ZFunc = (zFunc);
		ZWriteEnable = (zWriteEnable);
		DepthBias =	(depthBias);
		SlopeScaleDepthBias = (slopeScaleDepthBias);

		// Culling
		CullMode = (cullMode);

		// additional pixel pipe states.
		ColorWriteEnable = (colorWriteEnable);
		DitherEnable = (ditherEnable);
		FillMode = (fillMode);
		LastPixel =	(lastPixel);
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
		Texture[1] = (texture1);
		Texture[2] = (texture2);
		Texture[3] = (texture3);

		TextureFactor = (textureFactor);

		AlphaOp[0] = (alphaOp0);
		AlphaOp[1] = (alphaOp1);
		AlphaOp[2] = (alphaOp2);
		AlphaOp[3] = (alphaOp3);
		AlphaArg0[0] = (alphaArg00);
		AlphaArg0[1] = (alphaArg01);
		AlphaArg0[2] = (alphaArg02);
		AlphaArg0[3] = (alphaArg03);
		AlphaArg1[0] = (alphaArg10);
		AlphaArg1[1] = (alphaArg11);
		AlphaArg1[2] = (alphaArg12);
		AlphaArg1[3] = (alphaArg13);
		AlphaArg2[0] = (alphaArg20);
		AlphaArg2[1] = (alphaArg21);
		AlphaArg2[2] = (alphaArg22);
		AlphaArg2[3] = (alphaArg23);
		ColorArg0[0] = (colorArg00);
		ColorArg0[1] = (colorArg01);
		ColorArg0[2] = (colorArg02);
		ColorArg0[3] = (colorArg03);
		ColorArg1[0] = (colorArg10);
		ColorArg1[1] = (colorArg11);
		ColorArg1[2] = (colorArg12);
		ColorArg1[3] = (colorArg13);
		ColorArg2[0] = (colorArg20);
		ColorArg2[1] = (colorArg21);
		ColorArg2[2] = (colorArg22);
		ColorArg2[3] = (colorArg23);
		ColorOp[0] = (colorOp0);
		ColorOp[1] = (colorOp1);
		ColorOp[2] = (colorOp2);
		ColorOp[3] = (colorOp3);
		TexCoordIndex[0] = (texCoordIndex0);
		TexCoordIndex[1] = (texCoordIndex1);
		TexCoordIndex[2] = (texCoordIndex2);
		TexCoordIndex[3] = (texCoordIndex3);

		TextureTransformFlags[0] = (textureTransformFlags0);
		TextureTransformFlags[1] = (textureTransformFlags1);
		TextureTransformFlags[2] = (textureTransformFlags2);
		TextureTransformFlags[3] = (textureTransformFlags3);

		// sampler states
		AddressU[0] = (addressU0);
		AddressU[1] = (addressU1);
		AddressU[2] = (addressU2);
		AddressU[3] = (addressU3);
		AddressV[0] = (addressV0);
		AddressV[1] = (addressV1);
		AddressV[2] = (addressV2);
		AddressV[3] = (addressV3);
		AddressW[0] = (addressW0);
		AddressW[1] = (addressW1);
		AddressW[2] = (addressW2);
		AddressW[3] = (addressW3);
		BorderColor[0] = (borderColor0);
		BorderColor[1] = (borderColor1);
		BorderColor[2] = (borderColor2);
		BorderColor[3] = (borderColor3);
		MagFilter[0] = (magFilter0);
		MagFilter[1] = (magFilter1);
		MagFilter[2] = (magFilter2);
		MagFilter[3] = (magFilter3);
		MinFilter[0] = (minFilter0);
		MinFilter[1] = (minFilter1);
		MinFilter[2] = (minFilter2);
		MinFilter[3] = (minFilter3);
		MipFilter[0] = (mipFilter0);
		MipFilter[1] = (mipFilter1);
		MipFilter[2] = (mipFilter2);
		MipFilter[3] = (mipFilter3);

    }
}
