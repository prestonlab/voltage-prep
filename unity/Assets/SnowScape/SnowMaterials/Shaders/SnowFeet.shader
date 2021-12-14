// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "SnowFeet"
{
	Properties 
	{
_MainTex("_MainTex", 2D) = "white" {}
_Color("_Color", Color) = (1,1,1,1)
_MainNormal("_MainNormal", 2D) = "black" {}
_CutOffAngle("_CutOffAngle", Range(0,0.5) ) = 0
_Specular("Specular", Color) = (1,1,1,1)
_Gloss("Gloss", Range(0,1) ) = 0.5

	}
	
	SubShader 
	{
		Tags
		{
"Queue"="Geometry"
"IgnoreProjector"="False"
"RenderType"="TransparentCutout"

		}

		
Cull Back
ZWrite On
ZTest LEqual
ColorMask RGBA
Fog{
}


		CGPROGRAM
#pragma surface surf BlinnPhongEditor  vertex:vert
#pragma target 2.0


sampler2D _MainTex;
float4 _Color;
sampler2D _MainNormal;
float _CutOffAngle;
float4 _Specular;
float _Gloss;

			struct EditorSurfaceOutput {
				half3 Albedo;
				half3 Normal;
				half3 Emission;
				half3 Gloss;
				half Specular;
				half Alpha;
				half4 Custom;
			};
			
			inline half4 LightingBlinnPhongEditor_PrePass (EditorSurfaceOutput s, half4 light)
			{
half3 spec = light.a * s.Gloss;
half4 c;
c.rgb = (s.Albedo * light.rgb + light.rgb * spec);
c.a = s.Alpha;
return c;

			}

			inline half4 LightingBlinnPhongEditor (EditorSurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
			{
				half3 h = normalize (lightDir + viewDir);
				
				half diff = max (0, dot ( lightDir, s.Normal ));
				
				float nh = max (0, dot (s.Normal, h));
				float spec = pow (nh, s.Specular*128.0);
				
				half4 res;
				res.rgb = _LightColor0.rgb * diff;
				res.w = spec * Luminance (_LightColor0.rgb);
				res *= atten * 2.0;

				return LightingBlinnPhongEditor_PrePass( s, res );
			}
			
			struct Input {
				float2 uv_MainTex;
float2 uv_MainNormal;
float3 sWorldNormal;

			};

			void vert (inout appdata_full v, out Input o) {
float4 VertexOutputMaster0_0_NoInput = float4(0,0,0,0);
float4 VertexOutputMaster0_1_NoInput = float4(0,0,0,0);
float4 VertexOutputMaster0_2_NoInput = float4(0,0,0,0);
float4 VertexOutputMaster0_3_NoInput = float4(0,0,0,0);

o.sWorldNormal = mul((float3x3)unity_ObjectToWorld, SCALED_NORMAL);

			}
			

			void surf (Input IN, inout EditorSurfaceOutput o) {
				o.Normal = float3(0.0,0.0,1.0);
				o.Alpha = 1.0;
				o.Albedo = 0.0;
				o.Emission = 0.0;
				o.Gloss = 0.0;
				o.Specular = 0.0;
				o.Custom = 0.0;
				
float4 Sampled2D0=tex2D(_MainTex,IN.uv_MainTex.xy);
float4 Multiply0=Sampled2D0 * _Color;
float4 Tex2DNormal0=float4(UnpackNormal( tex2D(_MainNormal,(IN.uv_MainNormal.xyxy).xy)).xyz, 1.0 );
float4 Dot0=dot( float4( 0,1,0,0).xyz, float4( IN.sWorldNormal.x, IN.sWorldNormal.y,IN.sWorldNormal.z,1.0 ).xyz ).xxxx;
float4 Multiply1=float4( 0.5,0.5,0.5,0.5 ) * Dot0;
float4 Subtract1=_Color - Multiply1;
float4 Subtract0=Sampled2D0.aaaa - Subtract1;
float4 Master0_2_NoInput = float4(0,0,0,0);
float4 Master0_5_NoInput = float4(1,1,1,1);
float4 Master0_7_NoInput = float4(0,0,0,0);
clip( Subtract0 );
o.Albedo = Multiply0;
o.Normal = Tex2DNormal0;
o.Specular = _Gloss.xxxx;
o.Gloss = _Specular;

				o.Normal = normalize(o.Normal);
			}
		ENDCG
	}
	Fallback "Diffuse"
}