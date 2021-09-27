
texture tRippleTop			: RippleTop;
texture tRippleBot			: RippleBot;
texture tRippleMask			: RippleMask;

// Pipeline parameters (independent of water state, just following the camera etc)
float4x4 cWorld2NDC				: WorldToNDC;
float4 cCameraPos				: CameraPos; // world space

// Dynamic parameters (changing every frame)
float4 cFrequency				: Frequency;
float4 cPhase					: Phase;
float4 cAmplitude				: Amplitude;
float4 cPosX					: PosX;
float4 cPosY					: PosY;
float4 cDepthOffset				: DepthOffset; // water level is w component
float4 cDepthScale				: DepthScale;
float4 cRampOffset				: RampOffset;
float4 cRampScale				: RampScale;
float4 cK						: K;

// Properties (changed only when changing the character of the water)
float4 cTint					: Tint;

// Texture sliding
float4 cBotUVMap				: BotUVMap;
float4 cTopUVMap				: TopUVMap;

//const float4 kBlack = float4(0.f, 0.f, 0.f, 1.f);

sampler WrapSamp = sampler_state
{
MinFilter = LINEAR;
MagFilter = LINEAR;
MipFilter = LINEAR;

AddressU	= WRAP;
AddressV	= WRAP;
};

sampler MaskSamp = sampler_state
{
MinFilter = LINEAR;
MagFilter = LINEAR;
MipFilter = LINEAR;

AddressU	= WRAP;
AddressV	= CLAMP;
};

#pragma PACK_MATRIX (ROW_MAJOR)

struct VertIn
{
	float4 Position		: POSITION;
	float2 TexCoord0	: TEXCOORD0;
	float4 Color		: COLOR0;
};

struct VertOut
{
    float4 Position  : POSITION;
    float4 BotColor  : COLOR0;
    float4 TopColor  : COLOR1;
	float  Fog       : FOG;
    float2 TexCoord0 : TEXCOORD0; // Ripple bottom layer
    float2 TexCoord1 : TEXCOORD1; // Ripple top layer
    float2 TexCoord2 : TEXCOORD2; // The opacity mask
};

#include "watersurface.h"

void CalcFinalColors(const in float4 tint, 
					 const in float strength,
					 out float4 botColor,
					 out float4 topColor)
{
	botColor.xyz = tint.xyz;
	botColor.w = tint.w * (-strength + 1.f) * 0.5f;
	
	topColor.xyz = tint.xyz;
	topColor.w = tint.w * (strength + 1.f) * 0.5f;
}

void CalcEyeRayAndBumpAttenuation(const in float4 wPos, 
								  const in float4 cameraPos, 
								  out float3 cam2Vtx, 
								  out float pertAtten)
{
	// Get normalized vec from camera to vertex, saving original distance.
	cam2Vtx = float3(wPos.xyz) - float3(cameraPos.xyz);
	pertAtten = length(cam2Vtx);
	cam2Vtx = cam2Vtx / pertAtten;
}

void CalcTexCoords(const in float2 uvIn,
					const in float4 kTex0,
					const in float4 kTex1,
					out float2 uv0,
					out float2 uv1,
					out float2 uv2)
{
	// First two coords are simple transform of input uv.
	// Last one (the mask) is direct copy.
	uv0 = uvIn * kTex0.xy + kTex0.zw;
	uv1 = uvIn * kTex1.xy + kTex1.zw;
	uv2 = uvIn;
}


VertOut vs_main(VertIn vIn,
				uniform float4x4 kWorld2NDC,
				uniform float4 kTint,
				uniform float4 kFrequency,
				uniform float4 kPhase,
				uniform float4 kAmplitude,
				uniform float4 kPosX,
				uniform float4 kPosY,
				uniform float4 kCameraPos, // world space
				uniform float4 kDepthOffset, // water level is w component
				uniform float4 kDepthScale,
				uniform float4 kRampOffset,
				uniform float4 kRampScale,
				uniform float4 kK,
				uniform float4 kBotUVMap,
				uniform float4 kTopUVMap
				)
{
	VertOut vOut;

	// Evaluate world space base position. All subsequent calculations in world space.
	float4 wPos = vIn.Position;
	wPos.w = 1.f;

/*
vOut.Position = mul(wPos, kWorld2NDC);
vOut.modColor = float4(1.f, 1.f, 1.f, 1.f);
vOut.addColor = float4(1.f, 0.f, 0.f, 1.f);
vOut.Fog = 1.f;
vOut.TexCoord0 = float4(0.f, 0.f, 0.f, 0.f);
vOut.EnvCoord = float2(0.f, 0.f);
return vOut;
*/



	// Get our depth based filters. 
	float3 dFilter = CalcDepthFilter(kDepthOffset, kDepthScale, wPos, kDepthOffset.w);

	// Build our 4 waves
	float4 kDirX = wPos.xxxx - kPosX;
	float4 kDirY = wPos.yyyy - kPosY;
	float4 kDirSq = kDirX * kDirX + kDirY * kDirY;
	float4 kInvDir = rsqrt(kDirSq);
	kDirX *= kInvDir;
	kDirY *= kInvDir;
	float4 kDists = 1.f / kInvDir;

	float4 sines;
	float4 cosines;
	float strength = CalcSinCos(kDists, 
		kAmplitude, 
		kFrequency, 
		kPhase, 
		kRampOffset, kRampScale,
		dFilter.z, 
		sines, cosines);
		
	float4 kDirXK = kDirX * kK;
	float4 kDirYK = kDirY * kK;

	wPos = CalcFinalPosition(wPos, sines, cosines, kDepthOffset.w, kDirXK, kDirYK);

	// We have our final position. We'll be needing normalized vector from camera 
	// to vertex several times, so we go ahead and grab it.
	float3 cam2Vtx;
	float pertAtten;
	CalcEyeRayAndBumpAttenuation(wPos, 
			kCameraPos, 
			cam2Vtx, 
			pertAtten);

	float3 eyeRay = cam2Vtx;

	float4 kKW = kK * kFrequency;
	float4 kDirXW = kDirX * kFrequency;
	float4 kDirYW = kDirY * kFrequency;

	float3 norm;
	CalcNormal(sines, cosines, 
		kDirXW,
		kDirYW,
		kKW,
		norm);

	// Calc screen position and fog
	CalcScreenPosAndFog(kWorld2NDC, wPos, vOut.Position, vOut.Fog.x);
	
	CalcFinalColors(kTint, 
					strength, 
					vOut.BotColor,
					vOut.TopColor);

	CalcTexCoords(vIn.TexCoord0, 
				kBotUVMap, 
				kTopUVMap, 
				vOut.TexCoord0, 
				vOut.TexCoord1,
				vOut.TexCoord2);

	return vOut;
}


PixelShader ps_shore =
			asm
			{
				ps_1_1
				
//				def c0, -0.1, -0.1, -0.1, 1.f;

				tex t0;
				tex t1;
				tex t2;

				mul		r0.rgb, v0, t0;
				+mul	r0.a, t0, v0;
				mad		r0.rgb, v1, t1, r0;
				+mad	r0.a, t1, v1, r0;
//+mul r0.a, t1, r0;
				mul		r0.a, r0, t2;
		
/*
mov r0.rgb, t2;
+mov r0.a, c0;
*/
			};

technique T0
	<bool NoRender=0; >
{
	pass P0
	{
		VertexShader = compile vs_1_1 vs_main(cWorld2NDC,
											cTint,
											cFrequency,
											cPhase,
											cAmplitude,
											cPosX,
											cPosY,
											cCameraPos,
											cDepthOffset,
											cDepthScale,
											cRampOffset,
											cRampScale,
											cK,
											cBotUVMap,
											cTopUVMap);

		PixelShader = (ps_shore);

		Sampler[0] = (WrapSamp);
		Sampler[1] = (WrapSamp);
		Sampler[2] = (MaskSamp);
//Sampler[2] = (WrapSamp);
		
		Texture[0] = (tRippleBot);
		Texture[1] = (tRippleTop);
		Texture[2] = (tRippleMask);
		
		CullMode = NONE;

		SrcBlend  = SrcAlpha;
		DestBlend = InvSrcAlpha;
        
//        DepthBias = 4;
        
        ZEnable=true;
        ZWriteEnable=false;
        ZFunc=lessequal;
        
		AlphaTestEnable = true;
        AlphaFunc = greater;
        AlphaRef = 0;
        AlphaBlendEnable = true;
        
//        Wrap0 = Coord0 | Coord1;
//        Wrap1 = Coord0 | Coord1;
//        Wrap2 = Coord0 | Coord1;
        
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