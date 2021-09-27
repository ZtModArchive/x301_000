
float4x4	identMatrix		: IdentityMatrix = float4x4(		1.f,		0.f, 0.f, 0.f, 
																0.f,		1.f, 0.f, 0.f,
																0.f,		0.f, 1.f, 0.f,
																0.f,		0.f, 0.f, 1.f);
texture		sourceTexture	: SourceTexture = NULL;

float4		offset : UVOffset = float4(0.0005f, -0.0005f, 0.f, 1.f);
//float4		scale = float4(0.25f, 0.25f, 0.25f, 0.25f);
//float4		scale = float4(0.125f, 0.125f, 0.125f, 0.125f);
float4		scale = float4(0.5f, 0.5f, 0.5f, 0.5f);

sampler MapSampler = sampler_state
{
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	
	AddressU = Clamp;
	AddressV = Clamp;
};


struct vs_VertIn
{
	float4 Position : POSITION;
	float2 Uv		: TEXCOORD0;
};

struct vs_VertOut
{
    float4 Position  : POSITION;
    float2 Uv0		 : TEXCOORD0; 
    float2 Uv1		 : TEXCOORD1; 
    float2 Uv2		 : TEXCOORD2; 
    float2 Uv3		 : TEXCOORD3; 
};

struct ps_VertOut
{
	float4 Color : COLOR0;
};

vs_VertOut vs_main(vs_VertIn In)
{
	vs_VertOut Out;
	Out.Position = In.Position;

float2 offset = float2(0.001f, -0.001f);
//float2 offset = float2(0.0025f, -0.0025f);

	Out.Uv0 = In.Uv.xy + offset.xx;
	Out.Uv1 = In.Uv.xy + offset.xy;
	Out.Uv2 = In.Uv.xy + offset.yx;
	Out.Uv3 = In.Uv.xy + offset.yy;
	
	return Out;
}

ps_VertOut ps_blur(vs_VertOut In)
{
	ps_VertOut vOut;
	
	vOut.Color = tex2D(MapSampler, In.Uv0).aaaa * scale;
	vOut.Color += tex2D(MapSampler, In.Uv1).aaaa * scale;
	vOut.Color += tex2D(MapSampler, In.Uv2).aaaa * scale;
	vOut.Color += tex2D(MapSampler, In.Uv3).aaaa * scale;
		
	return vOut;
}



technique T0
{

    pass P0
    {
        // Vertex shader
        VertexShader = compile vs_1_1 vs_main();

        // Pixel shader
        PixelShader = compile ps_1_1 ps_blur();

		// Clip/Raster state
        SrcBlend  = SrcAlpha;
        DestBlend = InvSrcAlpha;

		SpecularEnable = true;
		AlphaBlendEnable = false;		
		FogEnable = FALSE;
		CullMode = NONE;
		ZFunc = Always;
		ZWriteEnable=false;

SrcBlend  = One;
DestBlend = One;
AlphaBlendEnable = true;
		
		WorldTransform[0] = (identMatrix);
		ViewTransform = (identMatrix);
		ProjectionTransform = (identMatrix);

		Texture[0] = (sourceTexture);
		Texture[1] = (sourceTexture);
		Texture[2] = (sourceTexture);
		Texture[3] = (sourceTexture);
		
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

