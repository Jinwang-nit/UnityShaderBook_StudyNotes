// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ForwardRendering"
{
    Properties
    {
        _Color ("Color Pint", Color) = (1, 1, 1, 1)
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Float) = 20
    }
    SubShader
    {
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "Lighting.cginc"

            float4 _Color;
            float4 _Specular;
            float4 _Diffuse;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f ans;
                ans.pos = UnityObjectToClipPos(v.vertex);
                ans.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                ans.worldNormal = UnityObjectToWorldNormal(v.normal);
                return ans;
            }

            float4 frag(v2f v) : SV_Target
            {
                float3 worldNormal = normalize(v.worldNormal);
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(v.worldPos));
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(v.worldPos));

                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldLightDir, worldNormal));

                float3 halfDir = normalize(worldLightDir + worldViewDir);
                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(halfDir, worldNormal)), _Gloss);

                float atten = 1.0; // 光照衰减，平行光是没有衰减所以就直接让他等于1.0就行了
                return float4((ambient + specular + diffuse) * atten, 1.0);
            }
            ENDCG
        }

        Pass
        {
            Tags{"LightMode" = "ForwardAdd"}
            Blend One One // 我们希望两个pass的结果叠加而不是覆盖，所以就打开混合模式

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            #include "Lighting.cginc"
            #include "Autolight.cginc"

            float4 _Color;
            float4 _Specular;
            float4 _Diffuse;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f ans;
                ans.pos = UnityObjectToClipPos(v.vertex);
                ans.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                ans.worldNormal = UnityObjectToWorldNormal(v.normal);
                return ans;
            }

            float4 frag(v2f v) : SV_Target
            {
                float3 worldNormal = normalize(v.worldNormal);
                
                #ifdef USING_DIRECTIONAL_LIGHT
                       float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                       float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - v.worldPos.xyz);
                #endif

                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(v.worldPos));

                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldLightDir, worldNormal));

                float3 halfDir = normalize(worldLightDir + worldViewDir);
                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(halfDir, worldNormal)), _Gloss);

                #ifdef USING_DIRECTIONAL_LIGHT
                       float atten = 1.0;
                #else
                       float3 lightCoord = mul(unity_WorldToLight, float4(v.worldPos, 1)).xyz;
                       fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                #endif

                return float4((specular + diffuse) * atten, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
