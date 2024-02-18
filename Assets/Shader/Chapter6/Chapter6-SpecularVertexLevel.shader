// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chapter6-SpecularVertexLevel"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1) // 反射系数
        _Specular("Specular", Color) = (1, 1, 1, 1) // 反射颜色
        _Gloss("Gloss", Range(8.0, 256)) = 20 // 反射区域
    }
    SubShader
    {
        Pass
        {
            Tags{"LightMode" = "ForwardBase"} // 指明光照模式
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;
            struct a2v  
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 color : COLOR;
            };

            v2f vert(a2v v)
            {
                v2f ans;
                ans.pos = UnityObjectToClipPos(v.vertex);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz; // 获取环境光
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject)); // 世界坐标下的法线
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir)); // 漫反射
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal)); // 计算反射光线
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

                ans.color = ambient + diffuse + specular;
                return ans;

            }

            fixed4 frag(v2f v) : SV_Target
            {
                return  fixed4(v.color, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Specular"
}
