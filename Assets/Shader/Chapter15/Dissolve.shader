// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Dissolve"
{
    Properties
    {
        _BurnAmount("Burn Amount", Range(0.0, 1.0)) = 0.0 // 消融程度
        _LineWidth("Line Width", Range(0.0, 0.2)) = 0.1 // 模拟烧焦效果的线宽
        _MainTex("Main Tex", 2D) = "white"{}
        _BumpMap("Normal Map", 2D) = "bump"{}
        _BurnFirstColor("Burn First Color", Color) = (1, 0, 0, 1)
        BurnSecondColor("Burn Second Color", Color) = (1, 0, 0, 1)
        _BurnMap("Burn Map", 2D) = "white"{} // 噪声纹理
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
            #pragma multi_compile_fwdbase

            fixed _BurnAmount;
			fixed _LineWidth;
			sampler2D _MainTex;
			sampler2D _BumpMap;
			fixed4 _BurnFirstColor;
			fixed4 _BurnSecondColor;
			sampler2D _BurnMap;
			
			float4 _MainTex_ST;
			float4 _BumpMap_ST;
			float4 _BurnMap_ST;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uvMainTex : TEXCOORD0;
                float2 uvBumpMap : TEXCOORD1;
                float2 uvBurnMap : TEXCOORD2;
                float3 lightDir : TEXCOORD3;
                float3 worldPos : TEXCOORD4;
                SHADOW_COORDS(5)
            };

            v2f vert(a2v v)
            {
                v2f ans;
                ans.pos = UnityObjectToClipPos(v.vertex);
                ans.uvMainTex = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                ans.uvBumpMap = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                ans.uvBurnMap = v.texcoord.xy * _BurnMap_ST.xy + _BurnMap_ST.zw;

                TANGENT_SPACE_ROTATION;

                ans.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                ans.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                TRANSFER_SHADOW(ans);
                return ans;
            }
            float4 frag(v2f i) : SV_Target
            {
                float3 burn = tex2D(_BurnMap, i.uvBurnMap).rgb;
                clip(burn.r - _BurnAmount);

                float3 tangentLightDir = normalize(i.lightDir);
                float3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uvBumpMap));

                float3 albedo = tex2D(_MainTex, i.uvMainTex).rgb;
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                float3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentLightDir, tangentNormal));

                float t = 1 - smoothstep(0.0, _LineWidth, burn.r - _BurnAmount); // 平滑过度
                float3 burnColor = lerp(_BurnFirstColor, _BurnSecondColor, t);
                burnColor = pow(burnColor, 5);

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                float3 finalColor = lerp(ambient + diffuse * atten, burnColor, t * step(0.0001, _BurnAmount));

                return float4(finalColor, 1);
            }
            ENDCG
        }

        Pass
        {
            Tags {"LightMode" = "ShadowCaster"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

			fixed _BurnAmount;
			sampler2D _BurnMap;
			float4 _BurnMap_ST;
            struct v2f
            {
                V2F_SHADOW_CASTER;
                float2 uvBurnMap : TEXCOORD1;
            };

            v2f vert(appdata_base v)
            {
                v2f ans;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(ans);
                ans.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);
                return ans;
            };

            float4 frag(v2f i) : SV_Target
            {
                float3 burn  = tex2D(_BurnMap, i.uvBurnMap).rgb;
                clip(burn.r - _BurnAmount);
                SHADOW_CASTER_FRAGMENT(i)
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
