// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/BrightnessSaturationAndContrast"
{
    Properties
    {
        _MainTex("Base", 2D) = "white"{}
        _Brightness("Brightness", Float) = 1
        _Saturation("饱和度", Float) = 1
        _Contrast("Contrast", Float) = 1
    }
    SubShader
    {
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"


            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Brightness;
            float _Saturation;
            float _Contrast;
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

            float4 frag(v2f i) : SV_Target
            {
                float4 renderTex = tex2D(_MainTex, i.uv);

                // 亮度
                float3 finalColor = renderTex.rgb * _Brightness;

                // 饱和度
                float luminance = 0.2125 * renderTex.r + 0.7145 * renderTex.g + 0.0721 * renderTex.b;
                float3 luminanceColor = float3(luminance, luminance, luminance);
                finalColor = lerp(luminanceColor, finalColor, _Saturation);

                // 对比度
                float3 avgColor = float3(0.5, 0.5, 0.5);
                finalColor = lerp(avgColor, finalColor, _Contrast);

                return float4(finalColor, renderTex.a);
            }
            ENDCG
        }
    }
    FallBack Off
}
