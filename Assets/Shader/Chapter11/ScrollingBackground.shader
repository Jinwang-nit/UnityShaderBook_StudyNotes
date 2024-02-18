// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ScrollingBackground"
{
    Properties
    {
        _MainTex ("Base Layer (RGB)", 2D) = "white" {}
		_DetailTex ("2nd Layer (RGB)", 2D) = "white" {}
		_ScrollX ("Base layer Scroll Speed", Float) = 1.0
		_Scroll2X ("2nd layer Scroll Speed", Float) = 1.0
		_Multiplier ("Layer Multiplier", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        Pass
        { 
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
            #include "AutoLight.cginc"
			
			sampler2D _MainTex;
			sampler2D _DetailTex;
			float4 _MainTex_ST;
			float4 _DetailTex_ST;
			float _ScrollX;
			float _Scroll2X;
			float _Multiplier;

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f ans;
                ans.pos = UnityObjectToClipPos(v.vertex);
                ans.uv.xy = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw + frac(float2(_ScrollX, 0.0) * _Time.y);
                ans.uv.zw = v.texcoord * _DetailTex_ST.xy + _DetailTex_ST.zw + frac(float2(_Scroll2X, 0.0) * _Time.y);
                return ans;
            }

            float4 frag(v2f i) : SV_Target
            {
                float4 firstLayer = tex2D(_MainTex, i.uv.xy);
                float4 secondLayer = tex2D(_DetailTex, i.uv.zw);

                float4 color = lerp(firstLayer, secondLayer, secondLayer.a);
                color.rgb *= _Multiplier;

                return color;
            }

            ENDCG
        }
    }
    FallBack "VertexLit"
}
