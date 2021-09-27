
float4x4	cameraToUV		: CameraToUV;

texture		shadowMap : ShadowMap = NULL;
texture		shadowMask : ShadowMask = NULL;
texture		normalLUT : TextureLUT = NULL;

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

		FogColor = 0x0;
		
		ZWriteEnable = false;

		AmbientMaterialSource = MATERIAL;
		DiffuseMaterialSource = MATERIAL;
		EmissiveMaterialSource = MATERIAL;
		SpecularMaterialSource = MATERIAL;

		Texture[0] = (shadowMap);
		Texture[1] = (shadowMask);
		Texture[2] = (normalLUT);

		ColorArg1[0] = Texture | AlphaReplicate;
//ColorArg1[0] = Texture;
		ColorArg2[0] = Diffuse;
		ColorOp[0] = MODULATE;
//ColorOp[0] = SelectArg1;

		ColorArg1[1] = Texture;
		ColorArg2[1] = Current;
		ColorOp[1] = Modulate;
		
		ColorArg1[2] = Texture;
		ColorArg2[2] = Current;
		ColorOp[2] = Modulate;

		AlphaArg1[0] = Texture;
		AlphaArg2[0] = Diffuse;
		AlphaOp[0] = SelectArg2;
		
		AlphaArg1[1] = Texture;
		AlphaArg2[1] = Current;
		AlphaOp[1] = SelectArg2;

		AlphaArg1[2] = Texture;
		AlphaArg2[2] = Current;
		AlphaOp[2] = SelectArg2;

		ColorOp[3] = Disable;
		AlphaOp[3] = Disable;

		TexCoordIndex[0] = CameraSpacePosition;
		TextureTransformFlags[0] = Count4 | Projected;
		TextureTransform[0] = (cameraToUV);

		TexCoordIndex[1] = CameraSpacePosition;
		TextureTransformFlags[1] = Count4 | Projected;
		TextureTransform[1] = (cameraToUV);

		TexCoordIndex[2] = CameraSpaceNormal;
		TextureTransformFlags[2] = Count2;
		TextureTransform[2] = (vecCameraToLight);

		// sampler states
		AddressU[0] = CLAMP;
		AddressV[0] = CLAMP;
//AddressU[0] = Wrap;
//AddressV[0] = Wrap;
		AddressU[1] = CLAMP;
		AddressV[1] = CLAMP;

		AddressU[2] = CLAMP;
		AddressV[2] = CLAMP;
	
    }
}

technique TShadowFail
	< float Quality = 0.0; bool NoRender=true; >
{
}

// We could hobble by on the two texture version, which will run
// on anything, but the evelated path version is in code (because
// it's going through the netimmerse pipe instead of BFREffect).
// If the primary technique, TShadowNormal, validates, then
// the evelated path version will be fine too. 
technique TShadowNoNormal
	< float Quality = -1.0; >
{
    pass P0
    {
		AlphaBlendEnable = true;
		AlphaTestEnable = false;

		SrcBlend = Zero;
		DestBlend = InvSrcColor;
//SrcBlend = One;
//DestBlend = Zero;

		AmbientMaterialSource = MATERIAL;
		DiffuseMaterialSource = MATERIAL;
		EmissiveMaterialSource = MATERIAL;
		SpecularMaterialSource = MATERIAL;

		Texture[0] = (shadowMap);
		Texture[1] = (shadowMask);

		ColorArg1[0] = Texture | AlphaReplicate;
//ColorArg1[0] = Texture;
		ColorArg2[0] = Diffuse;
		ColorOp[0] = MODULATE;
//ColorOp[0] = SelectArg1;

		ColorArg1[1] = Texture;
		ColorArg2[1] = Current;
		ColorOp[1] = Modulate;

		AlphaArg1[0] = Texture;
		AlphaArg2[0] = Diffuse;
		AlphaOp[0] = SelectArg2;
		
		AlphaArg1[1] = Texture;
		AlphaArg2[1] = Current;
		AlphaOp[1] = SelectArg2;

		ColorOp[2] = Disable;
		AlphaOp[2] = Disable;

		TexCoordIndex[0] = CameraSpacePosition;
		TextureTransformFlags[0] = Count4 | Projected;
		TextureTransform[0] = (cameraToUV);

		TexCoordIndex[1] = CameraSpacePosition;
		TextureTransformFlags[1] = Count4 | Projected;
		TextureTransform[1] = (cameraToUV);

		// sampler states
		AddressU[0] = CLAMP;
		AddressV[0] = CLAMP;
//AddressU[0] = Wrap;
//AddressV[0] = Wrap;
		AddressU[1] = CLAMP;
		AddressV[1] = CLAMP;
	
    }
}
