
float4x4	cameraToCaustic0		: CameraToCaustic0;
float4x4	cameraToCaustic1		: CameraToCaustic1;
float4x4	cameraToHeight			: CameraToHeight;

texture		causticMap0 : CausticMap0 = NULL;
texture		causticMap1 : CausticMap1 = NULL;
texture		heightLUT : HeightLUT = NULL;


technique TCaustic
	< float Quality = 0.1; >
{
    pass P0
    {
		ZWriteEnable = false;
		AlphaBlendEnable = true;
		AlphaTestEnable = false;

		SrcBlend = One;
//SrcBlend = DestColor;
		DestBlend = One;
//DestBlend = Zero;

		FogColor = 0;

		DiffuseMaterialSource = MATERIAL;
		SpecularMaterialSource = MATERIAL;
		AmbientMaterialSource = COLOR1;
		EmissiveMaterialSource = MATERIAL;

		Texture[0] = (causticMap0);
		Texture[1] = (causticMap1);
		Texture[2] = (heightLUT);

		ColorArg1[0] = Texture;
		ColorArg2[0] = Diffuse;
		ColorOp[0] = Modulate;
//ColorOp[0] = SelectArg2;

		ColorArg1[1] = Texture;
		ColorArg2[1] = Current;
		ColorOp[1] = Modulate;
//ColorOp[1] = SelectArg2;

		ColorArg1[2] = Texture;
		ColorArg2[2] = Current;
		ColorOp[2] = Modulate;
//ColorOp[2] = SelectArg2;
		
		ColorOp[3] = Disable;

		AlphaArg1[0] = Texture;
		AlphaArg2[0] = Diffuse;
		AlphaOp[0] = SelectArg2;
		
		AlphaArg1[1] = Texture;
		AlphaArg2[1] = Current;
		AlphaOp[1] = SelectArg2;

		AlphaArg1[2] = Texture;
		AlphaArg2[2] = Current;
		AlphaOp[2] = SelectArg2;

		AlphaOp[3] = Disable;
		
		TexCoordIndex[0] = CameraSpacePosition;
		TextureTransformFlags[0] = Count2;
		TextureTransform[0] = (cameraToCaustic0);

		TexCoordIndex[1] = CameraSpacePosition;
		TextureTransformFlags[1] = Count2;
		TextureTransform[1] = (cameraToCaustic1);

		TexCoordIndex[2] = CameraSpacePosition;
		TextureTransformFlags[2] = Count2;
		TextureTransform[2] = (cameraToHeight);

		AddressU[0] = Wrap;
		AddressV[0] = Wrap;
		MinFilter[0] = Linear;
		MagFilter[0] = Linear;
		AddressU[1] = Wrap;
		AddressV[1] = Wrap;
		MinFilter[1] = Linear;
		MagFilter[1] = Linear;
		AddressU[2] = Clamp;
		AddressV[2] = Clamp;
		MinFilter[2] = Linear;
		MagFilter[2] = Linear;

    }
}

technique TCausticFail
	< float Quality = 0.0; bool NoRender=true; >
{
}

