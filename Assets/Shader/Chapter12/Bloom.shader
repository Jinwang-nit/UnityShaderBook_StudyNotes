// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Bloom"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
		_Bloom ("Bloom (RGB)", 2D) = "black" {} // 高斯模糊之后较亮的区域
		_LuminanceThreshold ("Luminance Threshold", Float) = 0.5 // 阈值
		_BlurSize ("Blur Size", Float) = 1.0
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        sampler2D _Bloom;
        float _LuminanceThreshold;
        float _BlurSize;

        struct v2f
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
        };

        v2f VertExtractBright(appdata_img v)
        {
            v2f ans;
            ans.pos = UnityObjectToClipPos(v.vertex);
            ans.uv = v.texcoord;
            return ans;
        }

        float luminance(float4 color)
        {
            return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
        }

        float4 fragExtractBright(v2f i) : SV_Target
        {
            float4 c = tex2D(_MainTex, i.uv);
            float val = clamp(luminance(c) - _LuminanceThreshold, 0, 1.0);
            return c * val;
        }

		struct v2fBloom {
			float4 pos : SV_POSITION; 
			half4 uv : TEXCOORD0;
		};

        v2fBloom vertBloom(appdata_img v)
        {
            v2fBloom ans;
            ans.pos = UnityObjectToClipPos(v.vertex);
            ans.uv.xy = v.texcoord;
            ans.uv.zw = v.texcoord;

            #if UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0.0)
                ans.uv.w = 1 - ans.uv.w;
            #endif
            return ans;
        }

        float4 fragBloom(v2fBloom i) : SV_Target
        {
            return tex2D(_MainTex, i.uv.xy) + tex2D(_Bloom, i.uv.zw);
        }
        ENDCG

        ZTest Always Cull Off ZWrite Off
        Pass
        {
			CGPROGRAM  
			#pragma vertex VertExtractBright  
			#pragma fragment fragExtractBright  
			
			ENDCG  
        }

        UsePass "Custom/GaussianBlur/GAUSSIAN_BLUR_VERTICAL"
        UsePass "Custom/GaussianBlur/GAUSSIAN_BLUR_HORIZONTAL"

        Pass
        {
			CGPROGRAM  
			#pragma vertex vertBloom  
			#pragma fragment fragBloom  
			
			ENDCG  
        }
    }
    FallBack Off
}
