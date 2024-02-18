Shader "Custom/Chapter8-AlphaBlendZWrite"
{
    Properties
    {
        _Color("Color Pint", Color) = (1, 1, 1, 1)
        _MainTex("Main Tex", 2D) = "whit"{}
        _AlphaScale("Alpha Scale", range(0, 1)) = 1
    }
    SubShader
    {
        Tags{"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}

        Pass
        {
            ZWrite On
            ColorMask 0
        }

        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _AlphaScale;

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
                float4 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f ans;
                ans.pos = UnityObjectToClipPos(v.vertex);
                ans.worldNormal = UnityObjectToWorldNormal(v.normal);
                ans.worldPos = mul(unity_ObjectToWorld, v.vertex);
                ans.uv = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
                return ans;
            }

            float4 frag(v2f v) : SV_Target
            {
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(v.worldPos));
                float3 worldNormal = normalize(v.worldNormal);

                float4 texColor = tex2D(_MainTex, v.uv);
                float3 albedo = texColor.rgb * _Color.rgb;
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                float3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

                return float4(ambient + diffuse, texColor.a * _AlphaScale);
            }
            ENDCG
        }
    }
    FallBack "Transparent/VertexLit"
}
