// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Reflection"
{
    Properties
    {
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _ReflectColor("Reflect Color", Color) = (1, 1, 1, 1)
        _ReflectAmount("Reflect Amount", Range(0, 1)) = 1 // ∑¥…‰≥Ã∂»
        _Cubemap("Reflection Cubemap", Cube) = "_Skybox"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            float4 _Color;
            float4 _ReflectColor;
            float _ReflectAmount;
            samplerCUBE _Cubemap;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldRefl : TEXCOORD2;
                float3 worldPos : TEXCOORD1;
                float3 worldViewDir : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v)
            {
                v2f ans;
                ans.pos = UnityObjectToClipPos(v.vertex);
                ans.worldNormal = UnityObjectToWorldNormal(v.normal);
                ans.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                ans.worldViewDir = UnityWorldSpaceViewDir(ans.worldPos);
                ans.worldRefl = reflect(-ans.worldViewDir, ans.worldNormal);
                TRANSFER_SHADOW(ans);
                return ans;
            }

            float4 frag(v2f i) : SV_Target
            {
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 worldViewDir = normalize(i.worldViewDir);

                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                float3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldLightDir, worldNormal));
                float3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb * _ReflectColor;
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                float3 color = ambient + lerp(diffuse, reflection, _ReflectAmount) * atten;
                return float4(color, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
