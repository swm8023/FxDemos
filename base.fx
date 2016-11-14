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

// textures
Texture2D DiffTex;
sampler Sampler1 = sampler_state
{
	Texture = <DiffTex>;
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;

};

// texture scale and transport
float4 DiffuseTex_st;

