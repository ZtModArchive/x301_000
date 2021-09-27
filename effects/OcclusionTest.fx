
// This useless parameter is just so the BFREffect won't choke on not
// having any parameters.
bool fogEnable						: FogEnable	=	 false;

technique TBasic
{
	pass P0
	{
		// material
		// NDL will	never use these	states after initialization,
		// therefor, we	shouldn't use them,	otherwise it will trash
		// NDL's state.
		LocalViewer	= true;
		MaterialAmbient	= float4(0.f, 0.f, 0.f, 1.f); 
		MaterialDiffuse	= float4(0.f, 0.f, 0.f, 1.f); 
		MaterialSpecular = float4(0.f, 0.f, 0.f, 1.f); 
		MaterialEmissive = float4(0.f, 1.f, 1.f, 1.f);
		MaterialPower =	0.f;
		
		AmbientMaterialSource = Material;
		DiffuseMaterialSource = Material;
		EmissiveMaterialSource = Material;
		SpecularMaterialSource = Material;
		SpecularEnable = false;
		Ambient = 0;

		// alpha
		// can we use conditionals here	to avoid setting everything?
		AlphaBlendEnable = true;
		AlphaTestEnable	= false;
		DestBlend =	One;
		SrcBlend = Zero;
//SrcBlend = One;

		// z buffer.
		ZEnable	= true;
		ZWriteEnable = false;
		ZFunc = Less;

		// Culling
		CullMode = None;

		// additional pixel	pipe states.
		ShadeMode =	GOURAUD;
		FogEnable =	false;
				
		ColorArg1[0] = Diffuse;
		ColorArg2[0] = Diffuse;
		ColorOp[0] = SelectArg2;	  // blend lighting	as needed.

		ColorOp[1] = Disable;

		AlphaArg1[0] = Diffuse;
		AlphaArg2[0] = Diffuse;
		AlphaOp[0] = SelectArg2;
		
		AlphaOp[1] = Disable;	  // choose	alpha to write as needed.
	}
}