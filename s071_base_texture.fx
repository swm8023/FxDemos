/*

% Description of my shader.
% Second line of description for my shader.

keywords: material classic

date: YYMMDD

*/

float4x4 MatrixWVP :WorldViewProjection;

Texture2D ColorTexture
<
	string UIName = "Color Texture";
	string ReourceType = "2D";
>;

SamplerState ColorSampler
{
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = CLAMP;
	AddressV = WRAP;
};


struct appdata {
	float4 position : POSITION;
	float2 coord : TEXCOORD0;
	float3 normal : NORMAL;
};

struct vertexdata {
	float4 position : SV_POSITION;
	float2 coord : TEXCOORD0;
};



vertexdata mainVS(appdata IN){
	vertexdata OUT;
	OUT.position = mul(IN.position, MatrixWVP);
	OUT.coord = IN.coord * 2;
	return OUT;
}

float4 mainPS(vertexdata IN) : COLOR {
	return ColorTexture.Sample(ColorSampler, IN.coord);
}

technique technique0 {
	pass p0 {
		CullMode = None;
		VertexShader = compile vs_3_0 mainVS();
		PixelShader = compile ps_3_0 mainPS();
	}
}
