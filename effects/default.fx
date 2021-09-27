

float4 materialAmbient			: MaterialAmbient =			{ 0.0f, 0.0f, 0.0f, 1.0f };
float4 materialDiffuse			: MaterialDiffuse =			{ 0.0f, 0.0f, 0.0f, 1.0f };
float4 materialEmissive			: MaterialEmissive =		{ 1.0f, 1.0f, 1.0f, 1.0f };
float4 materialSpecular			: MaterialSpecular =		{ 0.0f, 0.0f, 0.0f, 0.0f };
float materialPower				: MaterialPower =			1.0f;

bool AlphaSort = true;

technique T0
{

    pass P0
    {
		// Clip/Raster state
		AlphaBlendEnable = true;
		AlphaTestEnable = false;

        SrcBlend  = One;
        DestBlend = One;

		Lighting = true;
		SpecularEnable = false;
		CullMode = None;
		ZFunc = LessEqual;
		ZWriteEnable=true;
		ZEnable=true;
		
		FogEnable=false;

        MaterialAmbient = (materialAmbient); 
        MaterialDiffuse = (materialDiffuse); 
        MaterialSpecular = (materialSpecular); 
        MaterialEmissive = (materialEmissive);
        MaterialPower = (materialPower);
		
		ColorArg1[0] = Diffuse;
		ColorArg2[0] = Diffuse;
		ColorOp[0] = SelectArg1;

		AlphaArg1[0] = Diffuse;
		AlphaArg2[0] = Diffuse;
		AlphaOp[0] = SelectArg1;

				
		ColorOp[1] = Disable;
		AlphaOp[1] = Disable;
		
		AmbientMaterialSource = Material;
		DiffuseMaterialSource = Material;
		EmissiveMaterialSource = Material;
		
    }

}

technique T1
{

    pass P0
    {
		// Clip/Raster state
		AlphaBlendEnable = true;
		AlphaTestEnable = false;

        SrcBlend  = DestColor;
        DestBlend = SrcColor;

		Lighting = true;
		SpecularEnable = false;
		CullMode = None;
		ZFunc = LessEqual;
		ZWriteEnable=true;
		ZEnable=true;

        MaterialAmbient = (materialAmbient); 
        MaterialDiffuse = (materialDiffuse); 
        MaterialSpecular = (materialSpecular); 
        MaterialEmissive = (materialEmissive);
        MaterialPower = (materialPower);
		
		ColorArg1[0] = Diffuse;
		ColorArg2[0] = Diffuse;
		ColorOp[0] = SelectArg1;

		AlphaArg1[0] = Diffuse;
		AlphaArg2[0] = Diffuse;
		AlphaOp[0] = SelectArg1;

				
		ColorOp[1] = Disable;
		AlphaOp[1] = Disable;
		
		AmbientMaterialSource = Material;
		DiffuseMaterialSource = Material;
		EmissiveMaterialSource = Material;
		
    }

}
