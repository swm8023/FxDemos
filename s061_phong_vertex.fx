/*
diffuse light with vertex shader
*/

float4x4 MatrixMVP : WorldViewProjection;
float4x4 MatrixW : World;
float4x4 MatrixIW: WorldInverse;
float4x4 MatrixIV : ViewInverse;

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

// Diffuse
float3 DiffuseColor : Diffuse <
	string UIName =  "Diffuse Color";
	string UIWidget = "Color";
> = {0.3f, 0.4f, 0.5f};

// Specular
float Gloss <
	string UIName = "Gloss";
> = 15;

struct appdata {
	float4 position : POSITION;
	float3 normal: NORMAL; 
};

struct vertexdata {
	float4 position : SV_POSITION;
	float3 color : COLOR;
};


vertexdata main_vs(appdata IN) {
	vertexdata OUT;
	// get light dir in world space
	float3 worldPosition = mul(IN.position, MatrixW).xyz;
	float3 lightDir = normalize(LampPos0 - worldPosition);
	
	// transform the normal from object space to projection space
	float3 worldNormal = normalize(mul(IN.normal, MatrixIW));
	
	// compute diffuse
	float3 diffuseContrb = LampColor0.xyz * saturate(dot(worldNormal, lightDir));
	// compute specular
	float3 viewDir = normalize(MatrixIV[3].xyz - worldPosition);
	float3 reflectDir = normalize(reflect(-lightDir, worldNormal));
	float3 specularContrb = LampColor0.xyz * pow(saturate(dot(reflectDir, viewDir)), Gloss);
	
	// transfrom the vertex from object space to projection space;
	OUT.position = mul(IN.position, MatrixMVP);
	OUT.color = AmbiColor.xyz + DiffuseColor.xyz * (specularContrb + diffuseContrb);
	return OUT;
}

float4 main_ps(vertexdata IN) : SV_Target {
	return float4(IN.color, 1.0);
}

technique technique0 {
	pass p0 {
		CullMode = None;
		VertexShader = compile vs_3_0 main_vs();
		PixelShader = compile ps_3_0 main_ps();
	}
}
