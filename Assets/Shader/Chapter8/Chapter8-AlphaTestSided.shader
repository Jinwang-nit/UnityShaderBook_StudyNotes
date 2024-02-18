Shader "Custom/Chapter8-AlphaTestSided"
{
    Properties
    {
        _Color("Color Pint", Color) = (1, 1, 1, 1)
        _MainTex("Main Tex", 2D) = "white"{}
        _Cutoff("Alpha Cutoff", range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags{"Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout"}
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Cutoff;
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
                ans.uv = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
                return ans;
            }

            float4 frag(v2f v) : SV_Target
            {
                float3 worldNormal = normalize(v.worldNormal);
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(v.worldPos));

                float4 texColor = tex2D(_MainTex, v.uv);
                clip(texColor.a - _Cutoff); // 如果小于阈值就完全透明
                float3 albedo = texColor.rgb * _Color.rgb;

                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                float3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

                return float4(ambient + diffuse, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Transparent/Cutout/VertexLit"
}
