// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chapter7-RampTexture"
{
    Properties
    {
        _Color("Color Pint", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(9.0, 256)) = 20
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _RampTex("Ramp Tex", 2D) = "white"{}
    }
    SubShader
    {
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            float4 _Color;
            float4 _Specular;
            sampler2D _RampTex;
            float4 _RampTex_ST;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f ans;
                ans.pos = UnityObjectToClipPos(v.vertex);
                ans.worldNormal = UnityObjectToWorldNormal(v.normal);
                ans.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                ans.uv = v.texcoord * _RampTex_ST.xy + _RampTex_ST.zw;
                return ans;
            }

            float4 frag(v2f v) : SV_Target
            {
                float3 worldNormal = normalize(v.worldNormal);
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(v.worldPos));
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                float halfLambert = 0.5 * dot(worldLightDir, worldNormal) + 0.5;
                float3 diffuseColor = tex2D(_RampTex, float2(halfLambert, halfLambert)).rgb * _Color.rgb;
                float3 diffuse = _LightColor0.rgb * diffuseColor;

                float3 viewDir = normalize(UnityWorldSpaceViewDir(v.worldPos));
                float3 halfDir = normalize(worldNormal + viewDir);
                float3 specular = _LightColor0.rgb * _Specular * pow(max(0, dot(halfDir, worldNormal)), _Gloss);
                
                return float4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
