// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chapter7-SingleTexture"
{
    Properties
    {
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex("MainTex", 2D) = "white"{}
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
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
            float _Gloss;
            sampler2D _MainTex;
            float4 _MainTex_ST; // 必须按这种变量名加ST声明方式，xy存储缩放信息，zw存储平移信息

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcood : TEXCOORD0; // 第一套纹理坐标
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
                ans.uv = v.texcood * _MainTex_ST.xy + _MainTex_ST.zw;
                return ans;
            }

            float4 frag(v2f v) : SV_Target
            {
                float3 worldNormal = normalize(v.worldNormal);
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(v.worldPos));
                float3 albedo = tex2D(_MainTex, v.uv).rgb * _Color.rgb; // 使用纹理计算漫反射率
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                float3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

                float3 viewDir = normalize(UnityWorldSpaceViewDir(v.worldPos));
                float3 halfDir = normalize(viewDir + worldLightDir);
                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                return float4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
