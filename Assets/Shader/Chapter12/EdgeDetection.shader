// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/EdgeDetection"
{
    Properties
    {
        _MainTex("Base", 2D) = "white"{}
        _EdgeColor("Edge Color", Color) = (1, 1, 1, 1)
        _EdgeOnly("Edge Only", Float) = 1.0
        _BackgroundColor("Background Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        ZTest Always Cull Off ZWrite Off // 防止对透明物体操作，标配
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            uniform float4 _MainTex_TexelSize;
            float4 _EdgeColor;
            float4 _BackgroundColor;
            float _EdgeOnly;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv[9] : TEXCOORD0;
            };

            v2f vert(appdata_img v)
            {
                v2f ans;
                ans.pos = UnityObjectToClipPos(v.vertex);
                ans.uv[0] = v.texcoord + _MainTex_TexelSize * float2(-1, -1);
                ans.uv[1] = v.texcoord + _MainTex_TexelSize * float2(0, -1);
                ans.uv[2] = v.texcoord + _MainTex_TexelSize * float2(1, -1);
                ans.uv[3] = v.texcoord + _MainTex_TexelSize * float2(-1, 0);
                ans.uv[4] = v.texcoord + _MainTex_TexelSize * float2(0, 0);
                ans.uv[5] = v.texcoord + _MainTex_TexelSize * float2(1, 0);
                ans.uv[6] = v.texcoord + _MainTex_TexelSize * float2(-1, 1);
                ans.uv[7] = v.texcoord + _MainTex_TexelSize * float2(0, 1);
                ans.uv[8] = v.texcoord + _MainTex_TexelSize * float2(1, 1);

                return ans;
            }

            float luminance(float4 color)
            {
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }

            float Sobel(v2f i)
            {
                const float Gx[9] = {-1, -2, -1,
                                     0, 0, 0,
                                     1, 2, 1 };
                const float Gy[9] = {-1, 0, 1,
                        -2, 0, 2,
                        -1, 0, 1 };

                float texColor;
                float edgeX = 0;
                float edgeY = 0;
                for (int it = 0; it < 9; it++)
                {
                    texColor = luminance(tex2D(_MainTex, i.uv[it]));
                    edgeX += texColor * Gx[it];
                    edgeY += texColor * Gy[it];
                }

                return 1 - abs(edgeX) - abs(edgeY);
            }

            float4 frag(v2f i) : SV_Target
            {
                float edge = Sobel(i); // 得到当前像素的梯度值
                float4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edge);
                float4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);
                return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
            }
            ENDCG
        }
    }
    FallBack Off
}
