/*

% Description of my shader.
% Second line of description for my shader.

keywords: material classic

date: YYMMDD

*/
float4x4 MatrixWVP : WorldViewProjection;
float4x4 MatrixIV : ViewInverse;
float4x4 MatrixW : World;
float4x4 MatrixIW : WorldInverse;

// LAMP0
float3 LampPos0 : Position <
	// bind with object PolintLight0
	string Object = "PointLight0";
	string UIName =  "Lamp 0 Position";
	string Space = "World";
> = {0.0f,0.0f,0.0f};

float3 LampColor0 : Specular <
	string Object = "PointLight0";
	string UIName =  "Lamp 0 Color";
	string UIWidget = "Color";
> = {1.0f,1.0f,1.0f};

// Ambient
float3 AmbiColor : Ambient <
	string UIName =  "Ambient Light";
	string UIWidget = "Color";
> = {0.07f,0.07f,0.07f};

// Specular
float Gloss <
	string UIName = "Gloss";
	string UIWidget = "slider";
	float UIMin = 1.0;
	float UIMax = 255.0;
	float UIStep = 1.0;
> = 15;

float3 SpecColor : Specular <
	string UIWidget = "Color";
>; 


// texture scale and transport
float4 BumpTex_st;
float4 DiffuseTex_st;

// textures
Texture2D DiffTex;
Texture2D BumpTex;

SamplerState ColorSampler
{
	Filter = MIN_MAG_MIP_POINT;
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
	//OUT.coord.xy = IN.coord.xy * DiffuseTex_st.xy + DiffuseTex_st.zw;
	// OUT.coord.zw = IN.coord.xy * BumpTex_st.xy + BumpTex_st.zw;
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
	float4 BumpColor = BumpTex.Sample(ColorSampler, IN.coord);
	float4 DiffColor = DiffTex.Sample(ColorSampler, IN.coord);
		
	BumpColor = (BumpColor * 2.0f) - 1.0f;
	float3 bumpNormal = (BumpColor.x * IN.tangent) + (BumpColor.y * IN.binormal) + (BumpColor.z * IN.normal);
	bumpNormal = normalize(bumpNormal);
	
	
	// ambient color
	float3 ambi = AmbiColor.xyz;
	// diffuse color

	float3 lightDir = normalize(IN.lightDir);
	float3 viewDir = normalize(IN.viewDir);
	float3 diff = DiffColor.rgb * LampColor0.rgb * saturate(dot(bumpNormal, lightDir));
	// specular
	float3 halfDir = normalize(lightDir + viewDir);
	float3 spec = SpecColor * LampColor0.xyz * pow(saturate(dot(bumpNormal, halfDir)), Gloss);
	return float4(diff, 1.0);
	// return float4(bumpNormal, 1.0);
}

technique technique0 {
	pass p0 {
		CullMode = None;
		VertexShader = compile vs_3_0 mainVS();
		PixelShader = compile ps_3_0 mainPS();
	}
}
