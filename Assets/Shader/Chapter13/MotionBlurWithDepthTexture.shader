// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/MotionBlurWithDepthTexture"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "white"{}
        _BlurSize("Blur Size", Float) = 1.0
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCg.cginc"

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        float4x4 _CurrentViewProjectionInverseMatrix;
        float4x4 _PreviousViewProjectionMatrix;
        float _BlurSize;

        struct v2f
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            float2 uv_depth : TEXCOORD1;
        };

        v2f vert(appdata_img v)
        {
            v2f ans;
            ans.pos = UnityObjectToClipPos(v.vertex);
            ans.uv = v.texcoord;
            ans.uv_depth = v.texcoord;

            #if UNITY_UV_STARTS_AT_TOP
                ans.uv_depth.y = 1 - ans.uv_depth.y;
            #endif

            return ans;
        }
        
        float4 frag(v2f i) : SV_Target
        {
            float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth); // 先将深度采样出来
            float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1); // 反映射回去, NDC坐标下的位置
            float4 D = mul(_CurrentViewProjectionInverseMatrix, H);
            float4 worldPos = D / D.w; 
            
            float4 currentPos = H;
            float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);
            previousPos /= previousPos.w;

            float2 velocity = (currentPos.xy - previousPos.xy) / 2.0f;

            float2 uv = i.uv;
            float4 c = tex2D(_MainTex, uv);
            uv += velocity * _BlurSize;

            for (int it = 0; it < 3; it++, uv += velocity * _BlurSize)
            {
                float4 currentColor = tex2D(_MainTex, uv);
                c += currentColor;
            }
            c /= 3;

            return float4(c.rgb, 1.0);
        }
        ENDCG

        Pass 
        {      
		    ZTest Always Cull Off ZWrite Off
			    	
		    CGPROGRAM  
			
		    #pragma vertex vert  
		    #pragma fragment frag  
			  
		    ENDCG  
		}
    }
    FallBack "Diffuse"
}
