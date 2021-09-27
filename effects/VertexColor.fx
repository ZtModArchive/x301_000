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

// *** additional pixel pipe states.
dword shadeMode				: ShadeMode =			GOURAUD; // flat/gouraud.

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

		// Textures
		AlphaOp[0] = DISABLE;
		ColorOp[0] = DISABLE;
    }
}