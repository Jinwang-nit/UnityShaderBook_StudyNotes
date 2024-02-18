// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chapter7-NormalMapTangentSpace"
{
    Properties
    {
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex("Main Tex", 2D) = "white"{}
        _BumpMap("Normal Map", 2D) = "bump"{}
        _BumpScale("Bump Scale", Float) = 1.0
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
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float4 _Specular;
            float _Gloss;
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
                float4 uv : TEXCOORD0;
                float3 LightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f ans;
                ans.pos = UnityObjectToClipPos(v.vertex);
                // 得到uv坐标
                ans.uv.xy = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
                ans.uv.zw = v.texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
                
                // 将入射光线和观察光线都转到切线坐标下
                TANGENT_SPACE_ROTATION;
                ans.LightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                ans.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

                return ans;
            }

            float4 frag(v2f v) : SV_Target
            {
                float3 tangentLightDir = normalize(v.LightDir);
                float3 tangentViewDir = normalize(v.viewDir);

                // 法线纹理采样
                float4 packedNormal = tex2D(_BumpMap, v.uv.zw); 
                float3 tangentNormal;
                // 直接采样出来的是rgb，需要转成法线向量
                tangentNormal = UnpackNormal(packedNormal);
                // 加入_BumpScale用来控制凹凸程度
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - max(0, dot(tangentNormal.xy, tangentNormal.xy)));

                // 颜色纹理采样
                float3 albedo = tex2D(_MainTex, v.uv.xy).rgb * _Color.rgb;
                // 环境光
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                float3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));
                float3 halfDir = normalize(tangentLightDir + tangentViewDir);
                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(halfDir, tangentNormal)), _Gloss);

                return float4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
