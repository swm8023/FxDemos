/*

% Description of my shader.
% Second line of description for my shader.

keywords: material classic

date: YYMMDD

*/

#include "base.fx"


float4 BumpTex_st;
Texture2D BumpTex;
sampler Sampler2 = sampler_state
{
	Texture = <BumpTex>;
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;

};

struct appdata {
	float4 position : POSITION;
	float3 normal : NORMAL;
	float3 tangent: TANGENT;
	float3 binormal : BINORMAL;
	float4 coord : TEXCOORD0;
};

struct vertexdata {
	float4 position : POSITION;
	float4 coord : TEXCOORD0;
	
	float3 normal : NORMAL;
	float3 tangent: TANGENT;
	float3 binormal : BINORMAL;
	float3 lightDir : TEXCOORD1;
	float3 viewDir : TEXCOORD2;
};



vertexdata mainVS(appdata IN) {
	vertexdata OUT;
	IN.position.w = 1.0f;
	OUT.coord = IN.coord;
	OUT.coord.xy = IN.coord.xy * DiffuseTex_st.xy + DiffuseTex_st.zw;
	OUT.coord.zw = IN.coord.xy * BumpTex_st.xy + BumpTex_st.zw;
	OUT.position = mul(IN.position, MatrixWVP);
	
	
	float3 wpos = mul(IN.position, MatrixW).xyz;
	OUT.lightDir = normalize(LampPos0 - wpos);
	OUT.viewDir = normalize(MatrixIV[3].xyz - wpos);
	
	OUT.normal = normalize(mul(IN.normal, MatrixIW));
	OUT.tangent = normalize(mul(IN.tangent, MatrixW));
	OUT.binormal = normalize(mul(IN.binormal, MatrixW));
	return OUT;
}

float4 mainPS(vertexdata IN) : COLOR {
	// bump	
	float3 DiffColor = tex2D(Sampler1, IN.coord.xy);
	float3 BumpColor = tex2D(Sampler2, IN.coord.zw);

	BumpColor = (BumpColor * 2.0f) - 1.0f;
	float3 bumpNormal = (BumpColor.x * IN.tangent) + (BumpColor.y * IN.binormal) + (BumpColor.z * IN.normal);
	bumpNormal = normalize(bumpNormal);
	
	// ambient color
	float3 ambi = AmbiColor.xyz;
	// diffuse color
	float3 lightDir = normalize(IN.lightDir);
	float3 viewDir = normalize(IN.viewDir);
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