
texture tEnvRefract			: EnvRefract;
texture tEnvReflect			: EnvReflect;
texture tBumpMap			: BumpMap;
texture tScumMap			: ScumMap;

float4x4 cWorldToRefract	: WorldToRefract;
float4x4 cWorldToReflect	: WorldToReflect;

float4	cRefractSize		: RefractSize;
float4	cReflectSize		: ReflectSize;

float4 cScumOffsetLo		: ScumOffsetLo;
float4 cScumOffsetHi		: ScumOffsetHi;
float4 cScumLightDir		: ScumLightDir;
float4 cScumAmbient			: ScumAmbient;
float4 cScumDiffuse			: ScumDiffuse;


// Properties (changed only when changing the character of the water)
float4 cReflectBaseTint			: ReflectBaseTint;
float4 cReflectSpecTint			: ReflectSpecTint;
float4 cRefractBaseTint			: RefractBaseTint;
float4 cRefractSpecTint			: RefractSpecTint;
float4 cRefractSpecAtten		: RefractSpecAtten; // uvScale is w component
float4 cReflectSpecAtten		: ReflectSpecAtten; // uvScale is w component
float4 cRefractOpacity			: RefractOpacity;
float4 cReflectOpacity			: ReflectOpacity;

// Pipeline parameters (independent of water state, just following the camera etc)
float4x4 cWorld2NDC				: WorldToNDC;
float4 cCameraPos				: CameraPos; // world space
float4 cCameraAcross			: CameraAcross;
float4 cCameraUp				: CameraUp;

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


//const float4 kBlack = float4(0.f, 0.f, 0.f, 1.f);

sampler BumpSamp = sampler_state
{
Texture   = <tBumpMap>;
MinFilter = LINEAR;
MagFilter = LINEAR;
MipFilter = LINEAR;

AddressU	= WRAP;
AddressV	= WRAP;
};

sampler EnvSamp = sampler_state
{
MinFilter = LINEAR;
MagFilter = LINEAR;
MipFilter = LINEAR;

AddressU	= CLAMP;
AddressV	= CLAMP;
};

#pragma PACK_MATRIX (ROW_MAJOR)

struct VertIn
{
	float4 Position : POSITION;
	float4 Color    : COLOR0;
};

struct VertOut
{
    float4 Position  : POSITION;
    float4 modColor  : COLOR0;
    float4 addColor  : COLOR1;
	float  Fog       : FOG;
    float4 TexCoord0 : TEXCOORD0; // Ripple texture coords
    float3 EnvCoord1  : TEXCOORD1; // Unperturbed reflection vector
    float3 EnvCoord2  : TEXCOORD2; // Unperturbed reflection vector
};

#include "watersurface.h"

void CalcFinalColors(const in float3 norm, 
					 const in float3 cam2Vtx, 
					 const in float opacMin, 
					 const in float opacScale,
					 const in float colorFilter,
					 const in float opacFilter,
					 const in float4 specTint,
					 const in float4 baseTint,
					 out float4 modColor,
					 out float4 addColor)
{
	// Calculate colors
	// Final color will be
	// rgb = Color1.rgb + Color0.rgb * envMap.rgb
	// alpha = Color0.a

	// Color 0

	// Vertex based Fresnel-esque effect.
	// Input vertex color.b limits how much we attenuate based on angle.
	// So we map 
	// (dot(norm,cam2Vtx)==0) => 1 for grazing angle
	// and (dot(norm,cam2Vtx)==1 => 1-In.Color.b for perpendicular view.
	float normDotPosEye = dot(norm, cam2Vtx);
	float normDotNegEye = dot(norm, -cam2Vtx);
	float normDotEye = max(normDotPosEye, normDotNegEye);
	float atten = saturate(opacMin + normDotEye * opacScale);

	// Filter the color based on depth
	modColor.rgb = colorFilter * atten * specTint * specTint.a;
//modColor.rgb = atten * specTint * specTint.a;

	// Boost the alpha so the reflections fade out faster than the tint
	// and apply the input attenuation factors.
	modColor.a = (atten + 1.0) * 0.5 * opacFilter * baseTint.a;
//modColor.a = (atten + 1.0) * 0.5 * baseTint.a;

	// Color 1 is just a constant.
	addColor = baseTint;

}

void CalcEyeRayAndBumpAttenuation(const in float4 wPos, 
								  const in float4 cameraPos, 
								  const in float4 specAtten, 
								  const in float kMinPertAtten,
								  out float3 cam2Vtx, 
								  out float pertAtten)
{
	// Get normalized vec from camera to vertex, saving original distance.
	cam2Vtx = float3(wPos.xyz) - float3(cameraPos.xyz);
	pertAtten = length(cam2Vtx);
	cam2Vtx = cam2Vtx / pertAtten;

	// Calculate our normal perturbation attenuation. This attenuation will be
	// applied to the horizontal components of the normal read from the computed
	// ripple bump map, mostly to fight aliasing. This doesn't attenuate the 
	// color computed from the normal map, it attenuates the "bumps".
	pertAtten = pertAtten + specAtten.x;
	pertAtten = pertAtten * specAtten.y;

	// Clamp, but don't let it get too small
	pertAtten = min(pertAtten, 1.f);
	pertAtten = max(pertAtten, 0.f);
	
	pertAtten = pertAtten * pertAtten; // Square it to account for perspective.

	// And factor in the user scaling	
	pertAtten = pertAtten * specAtten.z;
	
	pertAtten = max(pertAtten, kMinPertAtten);
}


void CalcTexCoords(const in float4 wPos,
					const in float4x4 kWorldToUV,
					const in float4 kUVSize,
					float3 norm, 
					const in float3 kCameraAcross, 
					const in float3 kCameraUp, 
					const in float pertAtten, 
					out float3 envCoord1,
					out float3 envCoord2)
{
	// This matches the env map perfectly to the screen.
	// If a little slop is introduced in the rendering phase,
	// it has to be match here, by making the 0.5f scale
	// larger.
	float4 hpos = mul(wPos, kWorldToUV);
	float2 envCoord = hpos.xy / hpos.w;

	// Perturb our ray to the env map by reflection/refraction
	// from our geometry
	norm.z -= 1.f;	
	float2 perturb;
	perturb.x = dot(kCameraAcross, norm);
	perturb.y = dot(kCameraUp, norm);
	const float kPerturbScale = 0.1f;
	envCoord.xy += perturb * kPerturbScale * kUVSize.xy;
	
	// Compensate for the texbem treating our bump map as 
	// values [0..1] rather than [-1..1].
//	float2 bumpCompensate;
//	bumpCompensate.x = dot(kCameraAcross.xy, pertAtten);
//	bumpCompensate.y = dot(kCameraUp.xy, pertAtten);
//	envCoord.xy += -0.5f * bumpCompensate;
	
	envCoord1.x = kCameraAcross.x * pertAtten * kUVSize.x;
	envCoord1.y = kCameraAcross.y * pertAtten * kUVSize.x;
	envCoord1.z = envCoord.x;
	
	envCoord2.x = kCameraUp.x * pertAtten * kUVSize.y;
	envCoord2.y = kCameraUp.y * pertAtten * kUVSize.y;
	envCoord2.z = envCoord.y;
}


VertOut vs_main(VertIn In,
				uniform float4x4 kWorld2NDC,
				uniform float4x4 kWorldToUV,
				uniform float4 kUVSize,
				uniform float4 kSpecTint,
				uniform float4 kBaseTint,
				uniform float4 kFrequency,
				uniform float4 kPhase,
				uniform float4 kAmplitude,
				uniform float4 kPosX,
				uniform float4 kPosY,
				uniform float4 kSpecAtten, // uvScale is w component
				uniform float4 kOpacity,
				uniform float4 kCameraPos, // world space
				uniform float4 kCameraAcross,
				uniform float4 kCameraUp,
				uniform float4 kDepthOffset, // water level is w component
				uniform float4 kDepthScale,
				uniform float4 kRampOffset,
				uniform float4 kRampScale,
				uniform float4 kK
				)
{
	VertOut vOut;

	// Evaluate world space base position. All subsequent calculations in world space.
	float4 wPos = In.Position;
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



	// Calculate ripple UV from position
	vOut.TexCoord0.xy = wPos.xy * kSpecAtten.ww;
	vOut.TexCoord0.z = 0.f;
	vOut.TexCoord0.w = 1.f;

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
	CalcSinCos(kDists, 
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
			kSpecAtten, 
			kOpacity.w,
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
	
	CalcFinalColors(norm, 
					cam2Vtx, 
					kOpacity.x,
					kOpacity.y - kOpacity.x,
					dFilter.y,
					dFilter.x,
					kSpecTint,
					kBaseTint,
					vOut.modColor,
					vOut.addColor);

	CalcTexCoords(wPos, 
				kWorldToUV, 
				kUVSize,
				norm, 
				kCameraAcross, 
				kCameraUp, 
				kSpecAtten.z * pertAtten, 
//kSpecAtten.z,
				vOut.EnvCoord1, 
				vOut.EnvCoord2);

	return vOut;
}


PixelShader ps_CubeSpec =
			asm
			{
				ps_1_1

				tex t0 
				texm3x3pad   t1,  t0_bx2   
				texm3x3pad   t2,  t0_bx2   
				texm3x3vspec t3,  t0_bx2  

				mad			r0.rgb, t3, v0, v1;
				+mov		r0.a, v0; 
			};

PixelShader ps_NoBump =
			asm
			{
			ps_1_1
			
			tex t0;
			tex t1;
			
			mov		r0.rgb, t1;
			+mov	r0.a, v0;
			};

PixelShader ps_FlatSpec =
			asm
			{
				ps_1_1

				tex t0;
				texm3x2pad	t1, t0_bx2;
				texm3x2tex	t2, t0_bx2;

				mad			r0.rgb, t2, v0, v1;
				+mov		r0.a, v0; 

/*
def c0, 0.f, 1.f, 0.f, 1.f;
mov r0, c0;
*/

/*
mul_sat r0.rgb, t1_bx2, v0;
add r0.rgb, r0, v1;
+mov r0.a, v0;
*/
			};

PixelShader ps_HighSpec =
			asm
			{
				ps_1_1
				
				def c0, -0.1, -0.1, -0.1, 0.f;

				tex t0;
				texbem t1, t0;

				mad_x2_sat r0.rgb, t1, v0, c0;
				add r0.rgb, r0, v1;
				+mov r0.a, v0;
			};

technique T0
	<bool NoRender=0; >
{
	pass P0
	{
		VertexShader = compile vs_1_1 vs_main(cWorld2NDC,
											cWorldToRefract,
											cRefractSize,
											cRefractSpecTint,
											cRefractBaseTint,
											cFrequency,
											cPhase,
											cAmplitude,
											cPosX,
											cPosY,
											cRefractSpecAtten,
											cRefractOpacity,
											cCameraPos,
											-cCameraAcross,
											-cCameraUp,
											cDepthOffset,
											cDepthScale,
											cRampOffset,
											cRampScale,
											cK);

		PixelShader = (ps_FlatSpec);

		Sampler[0] = (BumpSamp);
		Sampler[1] = (EnvSamp);
		Sampler[2] = (EnvSamp);
		
		Texture[1] = (tEnvRefract);
		Texture[2] = (tEnvRefract);
		
		CullMode = NONE;

        SrcBlend  = SrcAlpha;
        DestBlend = InvSrcAlpha;
//SrcBlend = Zero;
//DestBlend = One;

        ZEnable=true;
        ZWriteEnable=false;
        ZFunc=lessequal;
        
		AlphaTestEnable = true;
        AlphaFunc = greater;
        AlphaRef = 0;
        AlphaBlendEnable = true;

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
	pass P1
	{
		VertexShader = compile vs_1_1 vs_main(cWorld2NDC,
											cWorldToReflect,
											cReflectSize,
											cReflectSpecTint,
											cReflectBaseTint,
											cFrequency,
											cPhase,
											cAmplitude,
											cPosX,
											cPosY,
											cReflectSpecAtten,
											cReflectOpacity,
											cCameraPos,
											cCameraAcross,
											cCameraUp,
											cDepthOffset,
											cDepthScale,
											cRampOffset,
											cRampScale,
											cK);

		PixelShader = (ps_FlatSpec); 

		Sampler[0] = (BumpSamp);
		Sampler[1] = (EnvSamp);
		Sampler[2] = (EnvSamp);

		Texture[1] = (tEnvReflect);
		Texture[2] = (tEnvReflect);
		
		CullMode = NONE;

        SrcBlend  = SrcAlpha;
        DestBlend = InvSrcAlpha;
//SrcBlend = Zero;
//DestBlend = One;

		AlphaTestEnable = true;
        AlphaFunc = greater;
        AlphaRef = 0;
        AlphaBlendEnable = true;
        
        ZEnable=true;
        ZWriteEnable=true;
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