// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Fresnel"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _FresnelScale("Fresnel Scale", Range(0, 1)) = 0.5
        _Cubemap("Cubemap", Cube) = "_Skybox"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            float4 _Color;
            float _FresnelScale;
            samplerCUBE _Cubemap;

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
                float3 worldViewDir : TEXCOORD2;
                float3 worldRefl : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v)
            {
                v2f ans;
                ans.pos = UnityObjectToClipPos(v.vertex);
                ans.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                ans.worldNormal = UnityObjectToWorldNormal(v.normal);
                ans.worldViewDir = UnityWorldSpaceViewDir(ans.worldPos);
                ans.worldRefl = reflect(-ans.worldViewDir, ans.worldNormal);

                TRANSFER_SHADOW(ans);
                return ans;
            }

            float4 frag(v2f i) : SV_Target
            {
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldViewDir = normalize(i.worldViewDir);
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                float3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldLightDir, worldNormal));

                float3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb;
                float3 fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(worldViewDir, worldNormal), 5);
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                float3 color = ambient + lerp(diffuse, reflection, max(0, fresnel)) * atten;
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
