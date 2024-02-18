// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chapter6-BlinnPhong"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8, 256)) = 20
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

            fixed3 _Diffuse;
            fixed3 _Specular;
            float _Gloss;
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOODRD0;
                float3 worldPos : TEXCOODRD1;
            };
            
            v2f vert(a2v v)
            {
                v2f ans;
                ans.pos = UnityObjectToClipPos(v.vertex);
                ans.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                ans.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return ans;
            }

            float4 frag(v2f v) : SV_Target
            {
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                float3 worldNormal = normalize(v.worldNormal);
                float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldLightDir, worldNormal));

                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - v.worldPos.xyz);
                float3 halfDir = normalize(viewDir + worldLightDir);
                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal, halfDir)), _Gloss);
                return float4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
