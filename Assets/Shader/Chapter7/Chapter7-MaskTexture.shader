// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chapter7-MaskTexture"
{
    Properties
    {
        _Color("Color Pint", Color) = (1, 1, 1, 1)
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
        _SpecularScale("SpecularScale", Float) = 1.0
        _MainTex("Main Tex", 2D) = "white"{}
        _BumpTex("Normal Map", 2D) = "bump"{}
        _BumpScale("BumpScale", Float) = 1.0
        _SpecularMask("Specular Mask", 2D) = "white"{}
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
            sampler2D _MainTex;
            float4 _MainTex_ST; // 三张纹理都使用同一个纹理属性变量
            sampler2D _BumpTex;
            sampler2D _SpecularMask;
            float _Gloss;
            float _SpecularScale;
            float _BumpScale;

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
                float2 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f ans;
                ans.pos = UnityObjectToClipPos(v.vertex);
                ans.uv = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
                // 在切线空间中处理光照
                TANGENT_SPACE_ROTATION;
                ans.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                ans.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
                return ans;
            }

            float4 frag(v2f v) : SV_Target
            {
                float3 tangentLightDir = normalize(v.lightDir);
                float3 tangentViewDir = normalize(v.viewDir);

                float3 tangentNormal = UnpackNormal(tex2D(_BumpTex, v.uv));
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - dot(tangentNormal.xy, tangentNormal.xy));

                float3 albedo = tex2D(_MainTex, v.uv).rgb * _Color.rgb;
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                float3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

                float3 halfDir = normalize(tangentViewDir + tangentLightDir);
                float specularMask = tex2D(_SpecularMask, v.uv).r * _SpecularScale;
                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(halfDir, tangentNormal)), _Gloss) * specularMask;
                
                return float4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
