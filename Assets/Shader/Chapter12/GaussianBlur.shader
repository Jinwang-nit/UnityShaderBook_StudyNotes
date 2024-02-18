// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/GaussianBlur"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "white"{}
        _BlurSize("Blur Size", Float) = 1.0
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        float _BlurSize;

        struct v2f
        {
            float4 pos : SV_POSITION;
            float2 uv[5] : TEXCOORD0;
        };

        v2f vertBlurVertical(appdata_img v)
        {
            v2f ans;
            ans.pos = UnityObjectToClipPos(v.vertex);
            ans.uv[0] = v.texcoord;
            ans.uv[1] = v.texcoord + float2(0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
            ans.uv[2] = v.texcoord - float2(0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
            ans.uv[3] = v.texcoord + float2(0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
            ans.uv[4] = v.texcoord - float2(0, _MainTex_TexelSize.y * 2.0) * _BlurSize;

            return ans;
        }

        v2f vertBlurHorizontal(appdata_img v)
        {
            v2f ans;
            ans.pos = UnityObjectToClipPos(v.vertex);
            ans.uv[0] = v.texcoord;
            ans.uv[1] = v.texcoord + float2(_MainTex_TexelSize.x * 1.0, 0) * _BlurSize;
            ans.uv[2] = v.texcoord - float2(_MainTex_TexelSize.x * 1.0, 0) * _BlurSize;
            ans.uv[3] = v.texcoord + float2(_MainTex_TexelSize.x * 2.0, 0) * _BlurSize;
            ans.uv[4] = v.texcoord - float2(_MainTex_TexelSize.x * 2.0, 0) * _BlurSize;

            return ans;
        }

        float4 fragBlur(v2f i) : SV_Target
        {
            float weight[3] = {0.4026, 0.2442, 0.0545};
            float3 sum = tex2D(_MainTex, i.uv[0]).rgb * weight[0];
            for (int it = 1; it < 3; it++)
            {
                sum += tex2D(_MainTex, i.uv[it * 2 - 1]).rgb * weight[it];
                sum += tex2D(_MainTex, i.uv[it * 2]).rgb * weight[it];
            }

            return float4(sum, 1.0);
        }
        ENDCG

        ZTest Always Cull Off ZWrite Off
        Pass
        {
			NAME "GAUSSIAN_BLUR_VERTICAL"
			
			CGPROGRAM
			  
			#pragma vertex vertBlurVertical  
			#pragma fragment fragBlur
			  
			ENDCG  
        }

        Pass
        {
			NAME "GAUSSIAN_BLUR_HORIZONTAL"
			
			CGPROGRAM
			  
			#pragma vertex vertBlurVertical  
			#pragma fragment fragBlur
			  
			ENDCG  
        }
    }
    FallBack Off
}
