// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chapter6-DiffusePixelLevel"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
		Pass
		{
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
			};

			fixed4 _Diffuse;

			v2f vert(a2v v)
			{
				v2f ans;
				ans.pos = UnityObjectToClipPos(v.vertex);
				ans.worldNormal = mul(v.normal, (float3x3) unity_WorldToObject);
				return ans;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				// fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (0.5 * dot(worldNormal, worldLightDir) + 0.5);
				fixed3 color = ambient + diffuse;
				return fixed4(color, 1.0);
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}
