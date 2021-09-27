
texture texture0 : Texture0;

float4x4 textureTransform0		: TextureTransform0;

float4x4 localToWorld			: LocalToWorld;
float4x4 worldToCamera			: WorldToCamera;
float4x4 cameraToNDC			: CameraToNDC;

sampler MapSampler = sampler_state
{
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	
	AddressU	= CLAMP;
	AddressV	= CLAMP;
};


technique T0
{

    pass P0
    {
        // Vertex shader
        VertexShader = 0;

        // Pixel shader
        PixelShader = 0;

        Sampler[0] = (MapSampler);
        
        Texture[0] = (texture0);

		// Clip/Raster state
		AlphaBlendEnable = true;
        SrcBlend  = SrcAlpha;
        DestBlend = InvSrcAlpha;

		Lighting = true;
		SpecularEnable = false;
		FogEnable = true;
		CullMode = None;
		ZFunc = LessEqual;
		ZWriteEnable=false;
		
		ColorArg1[0] = Diffuse;
		ColorArg2[0] = Texture;
		ColorOp[0] = SelectArg1;

// BRIGHTEN HACK SO WE CAN SEE THE LAYOUT TEXTURE
//AlphaBlendEnable = false;
//ColorOp[0] = Modulate;
		
		AlphaArg1[0] = Diffuse;
		AlphaArg2[0] = Texture;
		AlphaOp[0] = Modulate;
		
		ColorOp[1] = Disable;
		AlphaOp[1] = Disable;
		
		AmbientMaterialSource = Material;
		DiffuseMaterialSource = Material;
		EmissiveMaterialSource = Material;
		
		WorldTransform[0] = (localToWorld);
		ViewTransform = (worldToCamera);
		ProjectionTransform = (cameraToNDC);		
		
		TextureTransformFlags[0] = Count2;
		
		TexCoordIndex[0] = 0;
		
		TextureTransform[0] = (textureTransform0);
    }

}

