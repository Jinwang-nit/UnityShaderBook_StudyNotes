// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chapter5-SimpleShader"
{
    Properties
    {
        // 声明一个颜色属性
        _Color("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            fixed4 _Color;

            struct a2v
            {
                float4 vertex : POSITION; // 用模型的顶点填充变量
                float3 normal : NORMAL; // 用模型的法线填充变量
                float4 texcoord : TEXCOORD0; // 用模型的*第一套*纹理填充
            };

            struct v2f
            {
                float4 pos : SV_POSITION; // 顶点在裁剪空间的位置
                float3 color : COLOR0;
            };

            v2f vert(a2v v)
            {
                v2f ans;
                ans.pos = UnityObjectToClipPos(v.vertex);
                ans.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
                return ans;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 c = i.color;
                c *= _Color.rgb;
                return fixed4(c, 1.0);
            }

            ENDCG
        }
    }

    FallBack "Diffuse"
}