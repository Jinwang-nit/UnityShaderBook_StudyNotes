// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/EdgeDetectNormalAndDepth"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "white"{}
        _EdgeOnly("Edge Only", Float) = 1.0
        _EdgeColor("Edge Color", Color) = (0, 0, 0, 1)
        _BackgroundColor("BackgroundColor", Color) = (1, 1, 1, 1)
        _SampleDistance("SampleDistance", Float) = 1.0
        _Sensitivity("Sensitivity", Vector) = (1, 1, 1, 1)
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        float _EdgeOnly;    
        float4 _EdgeColor;
        float4 _BackgroundColor;
        float _SampleDistance;
        float4 _Sensitivity;
        sampler2D _CameraDepthNormalsTexture;

        struct v2f
        {
            float4 pos : SV_POSITION;
            float2 uv[5] : TEXCOORD0;
        };

        // 检查对角是否存在边界
        float CheckSame(float4 center, float4 sample)
        {
            float2 centerNormal = center.xy;
            float centerDepth = DecodeFloatRG(center.zw);
            float2 sampleNormal = sample.xy;
            float sampleDepth = DecodeFloatRG(sample.zw);

            float2 diffNormal = abs(centerNormal - sampleNormal) * _Sensitivity.x;
            int isSameNormal = (diffNormal.x + diffNormal.y) < 0.1;
            float diffDepth = abs(centerDepth - sampleDepth) * _Sensitivity.y;
            int isSameDepth = diffDepth < 0.1 * centerDepth;

            return isSameDepth * isSameNormal ? 1.0 : 0.0;
        }



        v2f vert(appdata_img v)
        {
            v2f ans;
            ans.pos = UnityObjectToClipPos(v.vertex);
            float2 uv = v.texcoord;
            ans.uv[0] = uv;

			#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
				uv.y = 1 - uv.y;
			#endif

            ans.uv[1] = uv + _MainTex_TexelSize.xy * float2(1, 1) * _SampleDistance;
            ans.uv[2] = uv + _MainTex_TexelSize.xy * float2(-1, -1) * _SampleDistance;
            ans.uv[3] = uv + _MainTex_TexelSize.xy * float2(-1, 1) * _SampleDistance;
            ans.uv[4] = uv + _MainTex_TexelSize.xy * float2(1, -1) * _SampleDistance;

            return ans;
        }

        float4 fragRobertsCrossDepthAndNormal(v2f i) : SV_Target
        {
            float4 sample1 = tex2D(_CameraDepthNormalsTexture, i.uv[1]);
            float4 sample2 = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
            float4 sample3 = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
            float4 sample4 = tex2D(_CameraDepthNormalsTexture, i.uv[4]);

            float edge = 1.0;

            edge *= CheckSame(sample1, sample2);
            edge *= CheckSame(sample3, sample4);

            float4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[0]), edge);
            float4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);

            return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
        }
        ENDCG
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment fragRobertsCrossDepthAndNormal
            ENDCG
        }
    }
    FallBack Off
}
