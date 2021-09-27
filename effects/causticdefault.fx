
#define	WRAP 1

float4x4	cameraToCaustic0	: CameraToCaustic0;
float4x4	cameraToCaustic1	: CameraToCaustic1;
float4x4	cameraToHeight		: CameraToHeight;

texture	texture0					: Texture0 =		NULL;
dword texCoordIndex0				: TexCoordIndex0 =	  0;
dword textureTransformFlags0		: TextureTransformFlags0 =	  0;
float4x4 textureTransform0			: TextureTransform0		= float4x4( 1.0, 0.0, 0.0, 0.0, 
																		0.0, 1.0, 0.0, 0.0, 
																		0.0, 0.0, 1.0, 0.0, 
																		0.0, 0.0, 0.0, 1.0  );
dword addressU0						: AddressU0	= WRAP;
dword addressV0						: AddressV0	= WRAP;
dword addressW0						: AddressW0	= WRAP;

texture		causticMap0		: CausticMap0 = NULL;
texture		causticMap1		: CausticMap1 = NULL;
texture		heightLUT		: HeightLUT = NULL;

#define	COLOR1 1
dword diffuseMaterialSource			: DiffuseMaterialSource	=	 COLOR1; //	D3DMATERIALCOLORSOURCE


technique TCaustic
	< float Quality = 0.1; bool AlphaSort = false; >
{
    pass P0
    {
		ZWriteEnable = false;
		AlphaBlendEnable = true;

		SrcBlend = SrcAlpha;
		DestBlend = One;
//DestBlend = Zero;

		FogColor = 0;

		AmbientMaterialSource = MATERIAL;
		DiffuseMaterialSource = (diffuseMaterialSource);
		EmissiveMaterialSource = MATERIAL;
		SpecularMaterialSource = MATERIAL;

		Texture[0] = (texture0);
		Texture[1] = (causticMap0);
		Texture[2] = (causticMap1);
		Texture[3] = (heightLUT);

		ColorArg1[0] = Texture | AlphaReplicate;
		ColorArg2[0] = Diffuse;
		ColorOp[0] = Modulate;
//ColorOp[0] = SelectArg1;

		ColorArg1[1] = Texture;
		ColorArg2[1] = Current;
		ColorOp[1] = Modulate;
		
		ColorArg1[2] = Texture;
		ColorArg2[2] = Current;
		ColorOp[2] = Modulate;
//ColorOp[2] = SelectArg1;

		ColorArg1[3] = Texture;
		ColorArg2[3] = Current;
		ColorOp[3] = Modulate;
//ColorOp[3] = SelectArg2;

		ColorOp[4] = Disable;

		AlphaArg1[0] = Texture;
		AlphaArg2[0] = Diffuse;
		AlphaOp[0] = SelectArg2;
		
		AlphaArg1[1] = Texture;
		AlphaArg2[1] = Current;
		AlphaOp[1] = SelectArg2;

		AlphaArg1[2] = Texture;
		AlphaArg2[2] = Current;
		AlphaOp[2] = SelectArg2;

		AlphaArg1[3] = Texture;
		AlphaArg2[3] = Current;
		AlphaOp[3] = SelectArg2;

		AlphaOp[4] = Disable;

		TexCoordIndex[0] = (texCoordIndex0);
		TextureTransformFlags[0] = (textureTransformFlags0);
		TextureTransform[0]	= (textureTransform0);
		
		TexCoordIndex[1] = CameraSpacePosition;
		TextureTransformFlags[1] = Count2;
		TextureTransform[1] = (cameraToCaustic0);

		TexCoordIndex[2] = CameraSpacePosition;
		TextureTransformFlags[2] = Count2;
		TextureTransform[2] = (cameraToCaustic1);

		TexCoordIndex[3] = CameraSpacePosition;
		TextureTransformFlags[3] = Count2;
		TextureTransform[3] = (cameraToHeight);

		// sampler states
		AddressU[0]	= (addressU0);
		AddressV[0]	= (addressV0);
		AddressU[1] = Wrap;
		AddressV[1] = Wrap;
		AddressU[2] = Wrap;
		AddressV[2] = Wrap;

		AddressU[3] = CLAMP;
		AddressV[3] = CLAMP;
	
    }
}

technique TCausticFail
	< float Quality = 0.0; bool NoRender=true; >
{
}

