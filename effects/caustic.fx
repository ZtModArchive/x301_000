
float4x4	cameraToCaustic		: CameraToCaustic;
float4x4	cameraToHeight		: CameraToHeight;

texture		baseTexture : BaseTex = NULL;
texture		causticMap : CausticMap = NULL;
texture		heightLUT : HeightLUT = NULL;


technique TCaustic
	< float Quality = 0.1; >
{
    pass P0
    {
		ZWriteEnable = false;
		AlphaBlendEnable = true;

		SrcBlend = SrcAlpha;
		DestBlend = One;

		FogColor = 0;

		AmbientMaterialSource = MATERIAL;
		DiffuseMaterialSource = MATERIAL;
		EmissiveMaterialSource = MATERIAL;
		SpecularMaterialSource = MATERIAL;

		Texture[0] = (baseTexture);
		Texture[1] = (causticMap);
		Texture[2] = (causticMap);
		Texture[3] = (heightLUT);

		ColorArg1[0] = Texture;
		ColorArg2[0] = Diffuse;
		ColorOp[0] = SelectArg2;

		ColorArg1[1] = Texture;
		ColorArg2[1] = Current;
		ColorOp[1] = SelectArg1;
		
		ColorArg1[2] = Texture;
		ColorArg2[2] = Current;
		ColorOp[2] = Add;

		ColorArg1[3] = Texture;
		ColorArg2[3] = Current;
		ColorOp[3] = Modulate;

		AlphaArg1[0] = Texture;
		AlphaArg2[0] = Diffuse;
		AlphaOp[0] = SelectArg1;
		
		AlphaArg1[1] = Texture;
		AlphaArg2[1] = Current;
		AlphaOp[1] = SelectArg2;

		AlphaArg1[2] = Texture;
		AlphaArg2[2] = Current;
		AlphaOp[2] = SelectArg2;

		AlphaArg1[3] = Texture;
		AlphaArg2[3] = Current;
		AlphaOp[3] = SelectArg2;

		ColorOp[4] = Disable;
		AlphaOp[4] = Disable;

		TexCoordIndex[0] = 0;
		TextureTransformFlags[0] = Disable;
		
		TexCoordIndex[1] = CameraSpacePosition;
		TextureTransformFlags[1] = Count2;
		TextureTransform[1] = (cameraToCaustic);

		TexCoordIndex[2] = CameraSpacePosition;
		TextureTransformFlags[2] = Count2;
		TextureTransform[2] = (cameraToCaustic);

		TexCoordIndex[3] = CameraSpacePosition;
		TextureTransformFlags[3] = Count2;
		TextureTransform[3] = (cameraToHeight);

		// sampler states
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

