// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/MotionBlur"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "white"{}
        _BlurAmount("Blur Amount", Float) = 1.0
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        float _BlurAmount;

        struct v2f
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
        };

        v2f vert(appdata_img v)
        {
            v2f ans;
            ans.pos = UnityObjectToClipPos(v.vertex);
            ans.uv = v.texcoord;
            return ans;
        }

        float4 fragRGB(v2f i) : SV_Target
        {
            return float4(tex2D(_MainTex, i.uv).rgb, _BlurAmount);
        }
        float4 fragA(v2f i) : SV_Target
        {
            return tex2D(_MainTex, i.uv);
        }
        ENDCG

        ZTest Always Cull Off ZWrite Off
		Pass {
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			
			CGPROGRAM
			
			#pragma vertex vert  
			#pragma fragment fragRGB  
			
			ENDCG
		}
		
		Pass {   
			Blend One Zero
			ColorMask A
			   	
			CGPROGRAM  
			
			#pragma vertex vert  
			#pragma fragment fragA
			  
			ENDCG
		}
    }
    FallBack Off
}
