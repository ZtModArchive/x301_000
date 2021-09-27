// Terrain rendering effect file.
#define SELECTARG2 3
#define SOLID 3

// *** Texture functions.	
texture baseTexture		: BaseTexture =		NULL;
texture detailTexture	: DetailTexture =	NULL;
dword detailOp			: DetailOp =		SELECTARG2;

// *** additional pixel pipe states.
dword fillMode				: FillMode =			SOLID; // solid/point/wireframe

technique TAdvanced
	< float Quality = 1.0; >
{
    pass P0
    {
        // material
        MaterialAmbient = float4( 1.0f, 1.0f, 1.0f, 1.0f );
        MaterialDiffuse = float4( 1.0f, 1.0f, 1.0f, 1.0f );
        MaterialEmissive = float4( 0.0f, 0.0f, 0.0f, 0.0f );
		SpecularEnable = false;

		// NDL will never use these states after initialization,
		// therefor, we shouldn't use them, otherwise it will trash
		// NDL's state.
		DiffuseMaterialSource = MATERIAL;

		FillMode = (fillMode);

		// Textures

		Texture[0] = (baseTexture);
		Texture[1] = (detailTexture);

		ColorArg1[0] = TEXTURE;
		ColorArg2[0] = CURRENT;

		ColorArg1[1] = TEXTURE;
		ColorArg2[1] = CURRENT;

		ColorOp[0] = MODULATE;
		ColorOp[1] = (detailOp);
		ColorOp[2] = DISABLE;

		TexCoordIndex[0] = 0;
		TexCoordIndex[1] = 1;

		// sampler states
		AddressU[0] = CLAMP;
		AddressV[0] = CLAMP;

		AddressU[1] = WRAP;
		AddressV[1] = WRAP;
    }
}

technique TBasic
	< float Quality = 0.0; >
{
    pass P0
    {
        // material
        MaterialAmbient = float4( 1.0f, 1.0f, 1.0f, 1.0f );
        MaterialDiffuse = float4( 1.0f, 1.0f, 1.0f, 1.0f );
        MaterialEmissive = float4( 0.0f, 0.0f, 0.0f, 0.0f );
		SpecularEnable = false;

		// NDL will never use these states after initialization,
		// therefor, we shouldn't use them, otherwise it will trash
		// NDL's state.
		DiffuseMaterialSource = MATERIAL;

		FillMode = (fillMode);

		// Textures

		Texture[0] = (baseTexture);

		ColorArg1[0] = TEXTURE;
		ColorArg2[0] = CURRENT;

		ColorOp[0] = MODULATE;
		ColorOp[1] = DISABLE;

		TexCoordIndex[0] = 0;

		// sampler states
		AddressU[0] = CLAMP;
		AddressV[0] = CLAMP;
    }
}
