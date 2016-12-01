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
float3 CameraPos : CameraPosition;


// Lamp0
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
float3 SpecColor : Specular <
	string UIWidget = "Color";
>; 

// Gloss
float Gloss <
	string UIName = "Gloss";
	string UIWidget = "slider";
	float UIMin = 1.0;
	float UIMax = 255.0;
	float UIStep = 1.0;
> = 15;

// Diffuse
Texture2D DiffTex;
sampler Sampler1 = sampler_state
{
	Texture = <DiffTex>;
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;

};

#ifndef CUSTOM_DEFDATA

struct appdata {
	float4 position : POSITION;
	float3 normal : NORMAL;
	float4 coord : TEXCOORD0;
#ifdef NEED_BINORMAL
	float3 tangent: TANGENT;
	float3 binormal : BINORMAL;
#endif
};

struct vertexdata {
	float4 position : POSITION;
	float3 wdPosition : TEXCOORD0;
	float3 wdNormal : NORMAL;
	float4 coord : TEXCOORD1;
#ifdef NEED_BINORMAL
	float3 wdTangent: TANGENT;
	float3 wdBinormal : BINORMAL;
#endif
};

#endif


vertexdata common_vs(appdata IN) {
	vertexdata OUT;
	OUT.coord = IN.coord;
	
	OUT.position = mul(IN.position, MatrixWVP);
	OUT.wdPosition = mul(IN.position, MatrixW);
	OUT.wdNormal = normalize(mul(IN.normal, MatrixIW));
	
#ifdef NEED_BINORMAL
	OUT.wdTangent = normalize(mul(IN.tangent, MatrixW));
	OUT.wdBinormal = normalize(mul(IN.binormal, MatrixW));
#endif
	
	return OUT;
}

float3 light_one(float3 mdiff, float3 mspec, float3 wdPosition, float3 wdNormal) {
	// lightDir and viewDir
	float3 lightDir = normalize(LampPos0 - wdPosition);
	float3 viewDir = normalize(CameraPos - wdPosition);
	// ambi
	float3 ambi = AmbiColor;
	
#ifdef LIGHT_NO_HALF_LAMBERT
	float3 diff = LampColor0.xyz * mdiff * saturate(dot(lightDir, wdNormal));
#else
	// default half lambert
	float3 diff = LampColor0.xyz * mdiff * (dot(lightDir, wdNormal) * 0.5 + 0.5);
#endif
	
#ifdef LIGHT_NO_BLINN_PHOHG
	float3 reflDir = normalize(reflect(-lightDir, wdNormal));
	float3 spec = LampColor0.xyz * mspec * pow(max(0, dot(viewDir, reflDir)), Gloss);
#else
	// default blinn-phong
	float3 halfDir = normalize(viewDir + lightDir);
	float3 spec = LampColor0.xyz * mspec * pow(max(0, dot(wdNormal, halfDir)), Gloss);
#endif
	return ambi + diff + spec;
}

float4 common_ps(vertexdata IN) : COLOR {
	float4 diffColor = tex2D(Sampler1, IN.coord);
	
	// equal to => if ((diffColor.a - Cutoff) < 0) discard;
	// clip(diffColor.a - Cutoff);
	
	float3 light_color = light_one(diffColor, SpecColor, IN.wdPosition, IN.wdNormal);
	return float4(light_color, diffColor.a);
}


