// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chapter7-NormalMapWorldSpace"
{
    Properties
    {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_BumpScale ("Bump Scale", Float) = 1.0
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
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
            float _Gloss;
            float4 _Specular;
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
                // 将变换矩阵分行存贮
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
            };

            v2f vert(a2v v)
            {
                v2f ans;
                ans.pos = UnityObjectToClipPos(v.vertex);
                ans.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                ans.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                ans.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                ans.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                ans.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
                return ans;
            }

            float4 frag(v2f v) : SV_Target
            {
                float3 worldPos = float3(v.TtoW0.w, v.TtoW1.w, v.TtoW2.w);
                float3 LightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                float3 ViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                float3 bump = UnpackNormal(tex2D(_BumpMap, v.uv.zw));
                bump *= _BumpScale;
                bump.z = sqrt(1.0 - max(0, dot(bump.xy, bump.xy)));
                // 将法线转成世界坐标
                bump = normalize(half3(dot(v.TtoW0.xyz, bump), dot(v.TtoW1.xyz, bump), dot(v.TtoW2.xyz, bump)));

                float3 albedo = tex2D(_MainTex, v.uv).rgb * _Color.rgb;
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                float3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, LightDir));
                float3 halfDir = normalize(LightDir + ViewDir);
                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)), _Gloss);

                return float4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
