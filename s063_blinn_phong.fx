float4x4 MatrixMVP : WorldViewProjection;
float4x4 MatrixW : World;
float4x4 MatrixIW: WorldInverse;
float4x4 MatrixIV : ViewInverse;

// LAMP0
float3 LampPos0 : Position <
	// bind with object PolintLight0
	string Object = "PointLight0";
	string Space = "World";
> = {0.0f,0.0f,0.0f};

float3 LampColor0 : Specular <
	string Object = "PointLight0";
	string UIWidget = "Color";
> = {1.0f,1.0f,1.0f};

// Ambient
float3 AmbiColor : Ambient <
	string UIName =  "Ambient Light";
	string UIWidget = "Color";
> = {0.07f,0.07f,0.07f};

// Diffuse
Texture2D DiffTex;

SamplerState DiffSampler
{
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = CLAMP;
	AddressV = WRAP;
};

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

struct appdata {
	float4 position : POSITION;
	float3 normal: NORMAL;
	float2 coord : TEXCOORD0;
};

struct vertexdata {
	float4 position : SV_POSITION;
	float2 coord: TEXCOORD0;
	float3 normalWorld : TEXCOORD1;
	float3 lightDir : TEXCOORD2;
	float3 viewDir : TEXCOORD3;
	
};


vertexdata main_vs(appdata IN) {
	vertexdata OUT;
	// get light dir in world space
	float3 worldPosition = mul(IN.position, MatrixW).xyz;
	// transform the normal from object space to projection space
	OUT.position = mul(IN.position, MatrixMVP);
	OUT.normalWorld = mul(IN.normal, MatrixIW);
	OUT.lightDir = LampPos0 - worldPosition;
	OUT.viewDir = MatrixIV[3].xyz - worldPosition;
	OUT.coord = IN.coord;
	return OUT;
}

float4 main_ps(vertexdata IN) : SV_Target {
	// ambient color
	float3 ambi = AmbiColor.xyz;
	// diffuse color
	float3 diffClr = DiffTex.Sample(DiffSampler, IN.coord);
	float3 normalWorld = normalize(IN.normalWorld);
	float3 lightDir = normalize(IN.lightDir);
	float3 viewDir = normalize(IN.viewDir);
	float3 diff = diffClr * LampColor0.xyz * saturate(dot(normalWorld, lightDir));
	// specular
	float3 halfDir = normalize(lightDir + viewDir);
	float3 spec = SpecColor * LampColor0.xyz * pow(saturate(dot(normalWorld, halfDir)), Gloss);
	return float4(ambi + diff + spec, 1.0);
}

technique technique0 {
	pass p0 {
		CullMode = None;
		VertexShader = compile vs_3_0 main_vs();
		PixelShader = compile ps_3_0 main_ps();
	}
}


