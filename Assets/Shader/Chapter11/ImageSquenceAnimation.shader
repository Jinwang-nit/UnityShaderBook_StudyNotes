// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ImageSquenceAnimation"
{
    Properties
    {
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex("Main Tex", 2D) = "white"{}
        _HorizontalAmount("Horizontal Amount", Float) = 4
        _VerticalAmount("Vertical Amount", Float) = 4
        _Speed("Speed", Range(1, 100)) = 30
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _HorizontalAmount;
            float _VerticalAmount;
            float _Speed;
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f ans;
                ans.pos = UnityObjectToClipPos(v.vertex);
                ans.uv = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
                return ans;
            }

            float4 frag(v2f i) : SV_Target
            {
                float time = floor(_Time.y * _Speed);
                float row = floor(time / _HorizontalAmount);
                float col = time - row * _HorizontalAmount;

                float2 uv = float2(i.uv.x / _HorizontalAmount, i.uv.y / _VerticalAmount);
                uv.x += col / _HorizontalAmount;
                uv.y -= row / _VerticalAmount;

                float4 color = tex2D(_MainTex, uv);
                color.rgb *= _Color;

                return color;
            }
            ENDCG
        }

    }
    FallBack "Transparent/vertexLit"
}
