/*

% Description of my shader.
% Second line of description for my shader.

keywords: material classic

date: YYMMDD

*/

#include "base.fx"

float4 RampTex_st;
Texture2D RampTex;
sampler Sampler2 = sampler_state
{
	Texture = <RampTex>;
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;

};

struct appdata {
	float4 position : POSITION;
	float3 normal : NORMAL;
	float4 coord : TEXCOORD0;
};

struct vertexdata {
	float4 position : POSITION;
	float3 wdNormal : TEXCOORD0;
	float3 wdPosition : TEXCOORD1;
	float2 coord : TEXCOORD02;
};



vertexdata mainVS(appdata IN) {
	vertexdata OUT;
	OUT.coord = IN.coord.xy * RampTex_st.xy + RampTex_st.zw;
	OUT.wdNormal = mul(IN.normal, MatrixIW);
	OUT.wdPosition = mul(IN.position , MatrixW);


	return OUT;
}

float4 mainPS(vertexdata IN) : COLOR {
	// bump	
	float3 lightDir = normalize(LampPos0 - IN.wdPosition);
	float3 viewDir = normalize(MatrixIV[3].xyz - IN.wdPosition);
	
	// ambient color
	float3 ambi = AmbiColor.xyz;
	// diffuse color
	float halfLam = 0.5 * dot(wdNormal, lightDir) + 0.5;
	float3 diff = tex2D(Sampler2, IN.coord.xy);
	float3 diff = DiffColor.xyz + LampColor0.rgb * saturate(dot(bumpNormal, lightDir));
	// specular
	float3 halfDir = normalize(lightDir + viewDir);
	float3 spec = SpecColor * LampColor0.xyz * pow(saturate(dot(bumpNormal, halfDir)), Gloss);
	return float4(ambi + diff + spec, 1.0);
	// return float4(bumpNormal, 1.0);
}


technique technique0 {
	pass p0 {
		CullMode = None;
		VertexShader = compile vs_3_0 mainVS();
		PixelShader = compile ps_3_0 mainPS();
	}
}