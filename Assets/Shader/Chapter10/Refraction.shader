// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Refraction"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _RefracColor("Refraction Color", Color) = (1, 1, 1, 1)
        _RefracAmount("Refraction Amount", Range(0, 1)) = 1
        _RefracRatio("Refraction Ratio", Range(0.1, 1)) = 0.5
        _Cubemap("Refraction Cubemap", Cube) = "_Skybox"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            float4 _Color;
            float4 _RefracColor;
            float _RefracAmount;
            float _RefracRatio;
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
                float3 worldRefr : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v)
            {
                v2f ans;
                ans.pos = UnityObjectToClipPos(v.vertex);
                ans.worldNormal = UnityObjectToWorldNormal(v.normal);
                ans.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                ans.worldViewDir = UnityWorldSpaceViewDir(ans.worldPos);
                ans.worldRefr = refract(-normalize(ans.worldViewDir), normalize(ans.worldNormal), _RefracRatio);
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

                float3 refraction = texCUBE(_Cubemap, i.worldRefr).rgb * _RefracColor.rgb;
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                float3 color = ambient + lerp(diffuse, refraction, _RefracAmount) * atten;

                return float4(color, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
