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
#define TRUE 1
#define FALSE 0
#define WRAP 1

// *** material variables.
float4 materialSpecular				: MaterialSpecular =            { 0.0f, 0.0f, 0.0f, 0.0f };
float4 materialAmbient				: MaterialAmbient =            { 1.0f, 1.0f, 1.0f, 1.0f };
float4 materialDiffuse				: MaterialDiffuse =            { 1.0f, 1.0f, 1.0f, 1.0f };
float4 materialEmissive				: MaterialEmissive =        { 0.0f, 0.0f, 0.0f, 0.0f };
float4 materialE					: MaterialEmissive =        { 0.0f, 0.0f, 0.0f, 0.0f };
float materialPower					: MaterialPower =            1.0f;
bool specularEnable					: SpecularEnable =            false;

dword diffuseMaterialSource			: DiffuseMaterialSource =    COLOR1; // D3DMATERIALCOLORSOURCE
dword ambientMaterialSource			: AmbientMaterialSource =    MATERIAL; // D3DMATERIALCOLORSOURCE
dword emissiveMaterialSource		: EmissiveMaterialSource =    MATERIAL; // D3DMATERIALCOLORSOURCE

// *** alpha
bool alphaBlendEnable				: AlphaBlendEnable =    false;
dword alphaFunc						: AlphaFunc =            ALWAYS;
dword alphaRef						: AlphaRef =            0;
dword alphaTestEnable				: AlphaTestEnable =        FALSE;
dword destBlend						: DestBlend =            ZERO; // see D3DBLEND
dword srcBlend						: SrcBlend =            ONE; // see D3DBLEND.

// *** z buffer
dword zEnable						: ZEnable =                true;
dword zWriteEnable					: ZWriteEnable =        TRUE;

// Culling
dword cullMode						: CullMode =            CW; // NONE/CW/CCW

// *** Fog - left out, set globally from outside, except for toggle on and off.
// FogColor, FogDensity, FogEnable, FogEnd, FogStart, FogTableMode, FogVertexMode, RangeFogEnable.
bool fogEnable						: FogEnable =    true;

dword alphaApplyMode				: AlphaApplyMode =            MODULATE;
dword colorApplyMode				: ColorApplyMode =            MODULATE;

// *** Texture functions.    
texture texture0					: Texture0 =        NULL;
texture texture1					: Texture1 =        NULL;

dword texCoordIndex0				: TexCoordIndex0 =    0;
dword texCoordIndex1				: TexCoordIndex1 =    0;
dword textureTransformFlags0		: TextureTransformFlags0 =    0;
dword textureTransformFlags1		: TextureTransformFlags1 =    0;
float4x4 textureTransform0			: TextureTransform0		= float4x4( 1.0, 0.0, 0.0, 0.0, 
																		0.0, 1.0, 0.0, 0.0, 
																		0.0, 0.0, 1.0, 0.0, 
																		0.0, 0.0, 0.0, 1.0  );
float4x4 textureTransform1			: TextureTransform1		= float4x4( 1.0, 0.0, 0.0, 0.0, 
																		0.0, 1.0, 0.0, 0.0, 
																		0.0, 0.0, 1.0, 0.0, 
																		0.0, 0.0, 0.0, 1.0  );
// * resultArg[] excluded, lets you draw a texture layer to a different dest.
// * bump map stuff excluded: BumpEnvLScale[], BumpEnvLOffset[], BumpEnvMat00[],
//        BumpEnvMat01[], BumpEnvMat10[], BumpEnvMat11[]

// *** additional pixel pipe states.
dword shadeMode						: ShadeMode =            GOURAUD; // flat/gouraud.

// *** additional vertex pipe states.
//bool normalizeNormals        : NormalizeNormals =    false;
//bool colorVertex            : ColorVertex =            true;
// * multisample stuff excluded: MultiSampleAntialias & MultiSampleMask.
// * vertex blended excluded: VertexBlend, IndexedVertexBlendEnable, TweenFactor.
// * point stuff excluded: PointScale_A/B/C/Enable, PointSize/Min/Max, PointSpriteEnable,
//        PointScaleEnable.
// * n-patch stuff excluded: PatchSegments.

// sampler states.
dword addressU0						: AddressU0 = WRAP;
dword addressU1						: AddressU1 = WRAP;
dword addressV0						: AddressV0 = WRAP;
dword addressV1						: AddressV1 = WRAP;
dword addressW0						: AddressW0 = WRAP;
dword addressW1						: AddressW1 = WRAP;
dword borderColor0					: BorderColor0 = 0;
dword borderColor1					: BorderColor1 = 0;

technique TMedium
	< float Quality = 1.0; >
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
        Texture[1] = (texture1);

        AlphaArg1[0] = TEXTURE;
        AlphaArg2[0] = CURRENT;
        AlphaArg1[1] = TEXTURE;
        AlphaArg2[1] = CURRENT;
        AlphaArg1[2] = DIFFUSE;
        AlphaArg2[2] = CURRENT;

        // alpha 'applymode' lighting
        AlphaOp[0] = SELECTARG1;
        AlphaOp[1] = SELECTARG2;
        AlphaOp[2] = (alphaApplyMode);
        AlphaOp[3] = DISABLE;

        ColorArg1[0] = TEXTURE;
        ColorArg2[0] = CURRENT;
        ColorArg1[1] = TEXTURE;
        ColorArg2[1] = CURRENT;
        ColorArg1[2] = DIFFUSE;
        ColorArg2[2] = CURRENT;

        // ( color * dark ) 'applymode' lighting
        ColorOp[0] = SELECTARG1;
        ColorOp[1] = MODULATE;
        ColorOp[2] = (colorApplyMode);
        ColorOp[3] = DISABLE;

        // sampler states
        AddressU[0] = (addressU0);
        AddressV[0] = (addressV0);
        AddressW[0] = (addressW0);
        AddressU[1] = (addressU1);
        AddressV[1] = (addressV1);
        AddressW[1] = (addressW1);

        TexCoordIndex[0] = (texCoordIndex0);
        TexCoordIndex[1] = (texCoordIndex1);

        TextureTransformFlags[0] = (textureTransformFlags0);
        TextureTransformFlags[1] = (textureTransformFlags1);

        TextureTransform[0] = (textureTransform0);
        TextureTransform[1] = (textureTransform1);
    }
}

technique TLow
	< float Quality = 0.0; >
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

        AlphaArg1[0] = TEXTURE;
        AlphaArg2[0] = CURRENT;

        // alpha 'applymode' lighting
        AlphaOp[0] = (alphaApplyMode);
        AlphaOp[1] = DISABLE;

        ColorArg1[0] = TEXTURE;
        ColorArg2[0] = CURRENT;

        // color 'applymode' lighting
        ColorOp[0] = (colorApplyMode);
        ColorOp[1] = DISABLE;

        // sampler states
        AddressU[0] = (addressU0);
        AddressV[0] = (addressV0);

        TexCoordIndex[0] = (texCoordIndex0);
        TextureTransformFlags[0] = (textureTransformFlags0);
        TextureTransform[0] = (textureTransform0);
    }
}