// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chapter5-SimpleShader"
{
    Properties
    {
        // ����һ����ɫ����
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
                float4 vertex : POSITION; // ��ģ�͵Ķ���������
                float3 normal : NORMAL; // ��ģ�͵ķ���������
                float4 texcoord : TEXCOORD0; // ��ģ�͵�*��һ��*�������
            };

            struct v2f
            {
                float4 pos : SV_POSITION; // �����ڲü��ռ��λ��
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