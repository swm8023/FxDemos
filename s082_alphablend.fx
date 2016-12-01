/*

% Description of my shader.
% Second line of description for my shader.

keywords: material classic

date: YYMMDD

*/
#include "base.fx"

float AlphaScale <
	string UIName = "AlphaScale";
	string UIWidget = "slider";
	float UIMin = 0.0;
	float UIMax = 1.0;
	float UIStep = 0.05;
> = 1.0;


float4 mainPS(vertexdata IN) : COLOR {
	float4 diffColor = tex2D(Sampler1, IN.coord);
	
	// equal to => if ((diffColor.a - Cutoff) < 0) discard;
	// clip(diffColor.a - Cutoff);
	
	float3 light_color = light_one(diffColor, SpecColor, IN.wdPosition, IN.wdNormal);
	return float4(light_color, diffColor.a * AlphaScale);
}

technique technique0 {
	pass p0 {
		CullMode = None;
		
		ZEnable = TRUE;
		ZWriteEnable = FALSE;
		ZFunc = LESS;
		
		AlphaTestEnable = FALSE;
		AlphaBlendEnable = TRUE;
		AlphaFunc = GREATER;
		AlphaRef = 155;
		SrcBlend = SRCALPHA;
		DestBlend = INVSRCALPHA;
		BlendOp = ADD;
		// src_color * src_alpha + (1 - src_alpha) * dst_color
		VertexShader = compile vs_3_0 common_vs();
		PixelShader = compile ps_3_0 mainPS();
	}
}
