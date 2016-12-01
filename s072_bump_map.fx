/*

% Description of my shader.
% Second line of description for my shader.

keywords: material classic

date: YYMMDD

*/

//#define LIGHT_NO_HALF_LAMBERT
//#define LIGHT_NO_BLINN_PHOHG





float4 BumpTex_st;
Texture2D BumpTex;
sampler Sampler2 = sampler_state
{
	Texture = <BumpTex>;
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;

};


#define NEED_BINORMAL
#include "base.fx"



float4 mainPS(vertexdata IN) : COLOR {
	// bump	
	float3 diffColor = tex2D(Sampler1, IN.coord);
	float3 bumpColor = tex2D(Sampler2, IN.coord);

	bumpColor = (bumpColor * 2.0f) - 1.0f;
	float3x3 bumpMat = float3x3(IN.wdTangent, IN.wdBinormal, IN.wdNormal);
	float3 bumpNormal = mul(bumpColor, bumpMat);
	bumpNormal = normalize(bumpNormal);
	
	float3 light_color = light_one(diffColor, SpecColor, IN.wdPosition, bumpNormal);
	return float4(light_color, 1.0);
}




technique technique0 {
	pass p0 {
		CullMode = None;
		VertexShader = compile vs_3_0 common_vs();
		PixelShader = compile ps_3_0 mainPS();
	}
}