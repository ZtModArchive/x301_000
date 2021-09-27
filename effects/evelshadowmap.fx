
/// This effect has never actually been used to render geometry. It's
/// just a placeholder to validate and see if the elevated path shadow
/// back cull is viable. It should be just about right, but again, it's
/// never actually been used, so YMMV.

float4x4	cameraToUV		: CameraToUV;

texture		baseMap			: BaseMap = NULL;
texture		shadowMap		: ShadowMap = NULL;
texture		shadowMask		: ShadowMask = NULL;
texture		normalLUT		: TextureLUT = NULL;

// These two are filled out by the renderer.
float4x4 vecCameraToLight		: VecCameraToLight;


technique TShadowNormal
	< float Quality = 0.1; >
{
    pass P0
    {
		AlphaBlendEnable = true;
		AlphaTestEnable = false;

		SrcBlend = Zero;
		DestBlend = InvSrcColor;
//SrcBlend = One;
//DestBlend = Zero;

		FogColor = 0xffffff;

		AmbientMaterialSource = MATERIAL;
		DiffuseMaterialSource = MATERIAL;
		EmissiveMaterialSource = MATERIAL;
		SpecularMaterialSource = MATERIAL;

		Texture[0] = (baseMap);
		Texture[1] = (shadowMap);
		Texture[2] = (shadowMask);
		Texture[3] = (normalLUT);

		ColorArg1[0] = Texture | AlphaReplicate;
		ColorArg2[0] = Diffuse;
		ColorOp[0] = MODULATE;

		ColorArg1[1] = Texture | AlphaReplicate;
		ColorArg2[1] = Diffuse;
		ColorOp[1] = MODULATE;

		ColorArg1[2] = Texture;
		ColorArg2[2] = Current;
		ColorOp[2] = Modulate;
		
		ColorArg1[3] = Texture;
		ColorArg2[3] = Current;
		ColorOp[3] = Modulate;

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

		ColorOp[4] = Disable;
		AlphaOp[4] = Disable;

		TexCoordIndex[0] = 0;
		TextureTransformFlags[0] = Disable;

		TexCoordIndex[1] = CameraSpacePosition;
		TextureTransformFlags[1] = Count4 | Projected;
		TextureTransform[1] = (cameraToUV);

		TexCoordIndex[2] = CameraSpacePosition;
		TextureTransformFlags[2] = Count4 | Projected;
		TextureTransform[2] = (cameraToUV);

		TexCoordIndex[3] = CameraSpaceNormal;
		TextureTransformFlags[3] = Count2;
		TextureTransform[3] = (vecCameraToLight);

		// sampler states
		AddressU[0] = CLAMP;
		AddressV[0] = CLAMP;
//AddressU[0] = Wrap;
//AddressV[0] = Wrap;
		AddressU[1] = CLAMP;
		AddressV[1] = CLAMP;

		AddressU[2] = CLAMP;
		AddressV[2] = CLAMP;
	
		AddressU[3] = CLAMP;
		AddressV[3] = CLAMP;
	
    }
}

technique TShadowFail
	< float Quality = 0.0; bool NoRender=true; >
{
}
