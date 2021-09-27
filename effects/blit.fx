
texture texture0	: Texture0;
float4	tint		: Color;
float4	posSize		: PosSize;

float4x4 identMatrix : IdentityMatrix;

float4x4 textureTransform : TextureTransform;

sampler MapSampler = sampler_state
{
	Texture = (texture0);
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	
	AddressU = Clamp;
	AddressV = Clamp;
};


struct vs_VertIn
{
	float4 Position : POSITION;
	float4 Uv		: TEXCOORD0;
};

struct vs_VertOut
{
    float4 Position  : POSITION;
    float4 Uv		 : TEXCOORD0; // Ripple texture coords
};

struct ps_VertOut
{
	float4 Color : COLOR0;
};

vs_VertOut vs_main(vs_VertIn In)
{
	vs_VertOut Out;
	Out.Position = In.Position;
	Out.Position.xy *= posSize.zw;
	Out.Position.xy += posSize.xy;

	Out.Uv = mul(In.Uv, textureTransform);
	
	return Out;
}

ps_VertOut ps_tint(vs_VertOut In)
{
	ps_VertOut vOut;
	
	vOut.Color = tex2D(MapSampler, In.Uv);
	
	vOut.Color *= tint;	
	
	return vOut;
}



technique T0
{

    pass P0
    {
        // Vertex shader
        VertexShader = compile vs_1_1 vs_main();

        // Pixel shader
        PixelShader = compile ps_1_1 ps_tint();

		// Clip/Raster state
        SrcBlend  = SrcAlpha;
        DestBlend = InvSrcAlpha;

		SpecularEnable = FALSE;
		AlphaBlendEnable = TRUE;
AlphaBlendEnable = false;		
		FogEnable = FALSE;
		CullMode = NONE;
		ZFunc = Always;
		ZWriteEnable=false;
		
		WorldTransform[0] = (identMatrix);
		ViewTransform = (identMatrix);
		ProjectionTransform = (identMatrix);
		
		TextureTransformFlags[0] = Disable;
		TextureTransformFlags[1] = Disable;
		TextureTransformFlags[2] = Disable;
		TextureTransformFlags[3] = Disable;
		TextureTransformFlags[4] = Disable;
		TextureTransformFlags[5] = Disable;
		TextureTransformFlags[6] = Disable;
		TextureTransformFlags[7] = Disable;
		
		TexCoordIndex[0] = 0;
		TexCoordIndex[1] = 1;
		TexCoordIndex[2] = 2;
		TexCoordIndex[3] = 3;
		TexCoordIndex[4] = 4;
		TexCoordIndex[5] = 5;
		TexCoordIndex[6] = 6;
		TexCoordIndex[7] = 7;
    }

}

