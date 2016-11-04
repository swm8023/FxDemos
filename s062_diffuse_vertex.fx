/*

% Description of my shader.
% Second line of description for my shader.

keywords: material classic

date: YYMMDD

*/

float4x4 WorldViewProj : WorldViewProjection;
float4x4 InverseWorldMatrix: WorldInverseTranspose;		

// LAMP0
float3 Lamp0Pos : Position <
    string Object = "PointLight0";
    string UIName =  "Lamp 0 Position";
    string Space = "World";
> = {-0.5f,2.0f,1.25f};
float3 Lamp0Color : Specular <
    string UIName =  "Lamp 0";
    string Object = "Pointlight0";
    string UIWidget = "Color";
> = {1.0f,1.0f,1.0f};

// Ambient Color
float3 AmbiColor : Ambient <
    string UIName =  "Ambient Light";
    string UIWidget = "Color";
> = {0.07f,0.07f,0.07f};

// Diffuse Color
float3 DiffuseColor : Diffuse <
> = {0.3f, 0.4f, 0.5f};

struct VS_INPUT {
	float4 position : POSITION;
	float3 normal: NORMAL; 
};

struct VS_OUTPUT {
	float4 position : SV_POSITION;
	float3 color : COLOR;
};


VS_OUTPUT main_vs(VS_INPUT IN) {
	VS_OUTPUT O;
	float4 wp = mul(IN.position, WorldViewProj);
	float3 lightDir = normalize(Lamp0Pos - wp.xyz);
	
	float3 worldNormal = normalize(mul(IN.normal, InverseWorldMatrix));
	float3 diffuse = Lamp0Color.xyz * DiffuseColor.xyz * clamp(dot(worldNormal, lightDir), 0.0, 1.0);
	
	O.position = wp;
	O.color = diffuse + AmbiColor;
	
	 //mul(float4(pos.xyz, 1.0), WorldViewProj);
	return O;
}

float4 main_ps(VS_OUTPUT IN) : SV_Target {
	return float4(IN.color, 1.0);
}

technique technique0 {
	pass p0 {
		CullMode = None;
		VertexShader = compile vs_3_0 main_vs();
		PixelShader = compile ps_3_0 main_ps();
	}
}
