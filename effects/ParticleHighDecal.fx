
#include "watersurface.h"

#pragma PACK_MATRIX (ROW_MAJOR)

texture tBaseTexture	: Texture0;
texture tAlphaMask		: Texture1;

DWORD		srcBlend		: SrcBlend	= 5;	// default SrcAlpha
DWORD		dstBlend		: DestBlend = 6;	// default InvSrcAlpha

float4x4	cWorld2NDC		:	WorldToNDC;
float4		cAmplitude		:	Amplitude;
float4		cFrequency		:	Frequency;
float4		cPhase			:	Phase;
float4		cPosX			:	PosX;
float4		cPosY			:	PosY;
float4		cDepthOffset	:	DepthOffset;
float4		cDepthScale		:	DepthScale;
float4		cRampOffset		:	RampOffset;
float4		cRampScale		:	RampScale;
float4		cK				:	K;

sampler mainSamp = sampler_state
{
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;

	AddressU	= CLAMP;
	AddressV	= CLAMP;
//AddressU = WRAP;
//AddressV = WRAP;
};

struct VertIn
{
	float4 position : POSITION;
	float4 color    : COLOR0;
    float2 texCoord0 : TEXCOORD0; // Ripple texture coords
    float2 texCoord1 : TEXCOORD1; // Alpha mask texture coords
};

struct VertOut
{
    float4 position  : POSITION;
    float4 color	 : COLOR0;
	float  fog       : FOG;
    float2 texCoord0 : TEXCOORD0; // Ripple texture coords
    float2 texCoord1 : TEXCOORD1; // Alpha mask texture coords
};

VertOut vs_main(VertIn vIn)
{
	VertOut vOut;

	// Evaluate world space base position. All subsequent calculations in world space.
	float4 wPos = vIn.position;
	wPos.w = 1.f;

	vOut.texCoord0 = vIn.texCoord0 * float2(0.5f, 0.5f) + float2(0.5f, 0.5f); 
	vOut.texCoord1 = vIn.texCoord1 * float2(0.5f, 0.5f) + float2(0.5f, 0.5f); 

	// Get our depth based filters. 
	float3 dFilter = CalcDepthFilter(cDepthOffset, cDepthScale, wPos, cDepthOffset.w);

	// Build our 4 waves
	float4 kDirX = wPos.xxxx - cPosX;
	float4 kDirY = wPos.yyyy - cPosY;
	float4 kDirSq = kDirX * kDirX + kDirY * kDirY;
	float4 kInvDir = rsqrt(kDirSq);
	kDirX *= kInvDir;
	kDirY *= kInvDir;
	float4 kDists = 1.f / kInvDir;

	float4 sines;
	float4 cosines;
	CalcSinCos(kDists, 
		cAmplitude, 
		cFrequency, 
		cPhase, 
		cRampOffset, cRampScale,
		dFilter.z, 
		sines, cosines);
		
	float4 kDirXK = kDirX * cK;
	float4 kDirYK = kDirY * cK;

	wPos = CalcFinalPosition(wPos, sines, cosines, cDepthOffset.w, kDirXK, kDirYK);


	// Calc screen position and fog
	CalcScreenPosAndFog(cWorld2NDC, wPos, vOut.position, vOut.fog.x);

	vOut.color = vIn.color;

	return vOut;
}

PixelShader ps_2Tex = 
			asm
			{
				ps_1_1

				tex t0;
				tex t1;

				mul			r0.rgb, 1-t0, 1-v0;				
				+mul		r0.a, t0, v0;
				mov			r0.rgb, 1-r0;
				+mul		r0.a, r0, t1;
/*				
				def c0, 1.0, 0.0, 0.0, 1.0;
				mov	r0, c0;
*/
			};

technique T0
	<bool NoRender=0; >
{
	pass P0
	{
		VertexShader = compile vs_1_1 vs_main();

		PixelShader = (ps_2Tex); 

		Sampler[0] = (mainSamp);
		Sampler[1] = (mainSamp);

		Texture[0] = (tBaseTexture);
		Texture[1] = (tAlphaMask);
		
		CullMode = NONE;
		
        SrcBlend  = (srcBlend);
        DestBlend = (dstBlend);

		AlphaTestEnable = true;
        AlphaFunc = greater;
        AlphaRef = 0;
        AlphaBlendEnable = true;
//AlphaTestEnable=false;
//AlphaBlendEnable=false;
        
        ZEnable=true;
//ZEnable=false;
        ZWriteEnable=false;
        ZFunc=lessequal;

//FillMode=WIREFRAME;

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
