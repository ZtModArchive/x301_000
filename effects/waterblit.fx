
texture tBumpMap0 : Texture0;
texture tBumpMap1 : Texture1;
texture tBumpMap2 : Texture2;
texture tBumpMap3 : Texture3;

float4x4 identMatrix : IdentityMatrix;

float4		cScale : TextureScale;
float4		cScroll : TextureOffset;

float4		cCoefBase = float4(0.25f, 0.25f, 1.f, 1.f);
float4		cCoefUpper = float4(0.25f, 0.25f, 0.f, 1.f);

sampler BumpMapSampler = sampler_state
{
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	
	AddressU	= WRAP;
	AddressV	= WRAP;
};


struct VertIn
{
	float4 Position : POSITION;
	float4 Uv		: TEXCOORD0;
};

struct VertOut
{
    float4 Position  : POSITION;
    float4 Uv0		 : TEXCOORD0; // Ripple texture coords
    float4 Uv1		 : TEXCOORD1; // Ripple texture coords
    float4 Uv2		 : TEXCOORD2; // Ripple texture coords
    float4 Uv3		 : TEXCOORD3; // Ripple texture coords
};

VertOut vs_main(VertIn In,
			uniform float4 scale,
			uniform float4 scroll)
{
	VertOut Out;
	Out.Position = In.Position;

//	float4 uv = In.Uv * scale + scroll;
	float4 uv = In.Uv * scale;
	
	// As is
	Out.Uv0 = In.Uv * scale[0];
	Out.Uv0.x += scroll[0];
	Out.Uv1 = In.Uv * scale[1];
	Out.Uv1.x += scroll[1];
	Out.Uv2 = In.Uv * scale[2];
	Out.Uv2.y += scroll[2];
	Out.Uv3 = In.Uv * scale[3];
	Out.Uv3.y += scroll[3];

	/*
	Out.Uv0 = In.Uv * scale[0] + scroll[0];
	Out.Uv1 = In.Uv * scale[1] + scroll[1];
	Out.Uv2 = In.Uv * scale[2] + scroll[2];
	Out.Uv3 = In.Uv * scale[3] + scroll[3];
	*/


	return Out;
}

PixelShader ps_sum = 
            asm
            {
				// Composite the normals of the waves together.
				// Keep in mind that when adding these unnormalized derivatives,
				// you sum x and y, but z remains constant.

				ps_1_1
				
//				def c0, 0.5f, 0.5f, 0.75f, 1.f;


				tex		t0;
				tex		t1;
				tex		t2;
				tex		t3;

				mul		r0, t0, c0;
				mad		r0, t1, c1, r0;
				mad		r0, t2, c2, r0;
				mad		r0, t3, c3, r0;

/*
mul r0, t0, c0;
mad		r0, t0, c1, r0;
mad		r0, t0, c2, r0;
mad		r0, t0, c3, r0;
*/
//mov r0, c0;
            };

technique T0
{

    pass P0
    {
        // Vertex shader
        VertexShader = compile vs_1_1 vs_main(cScale, cScroll);

        // Pixel shader
        PixelShader = (ps_sum);

        PixelShaderConstant1[0] = <cCoefBase>;
        PixelShaderConstant1[1] = <cCoefBase>;
        PixelShaderConstant1[2] = <cCoefBase>;
        PixelShaderConstant1[3] = <cCoefBase>;

        Sampler[0] = (BumpMapSampler);
        Sampler[1] = (BumpMapSampler);
        Sampler[2] = (BumpMapSampler);
        Sampler[3] = (BumpMapSampler);
        
        Texture[0] = (tBumpMap0);
        Texture[1] = (tBumpMap1);
        Texture[2] = (tBumpMap2);
        Texture[3] = (tBumpMap3);

		// Clip/Raster state
        SrcBlend  = One;
        DestBlend = One;

		SpecularEnable = FALSE;
		AlphaBlendEnable = TRUE;
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

