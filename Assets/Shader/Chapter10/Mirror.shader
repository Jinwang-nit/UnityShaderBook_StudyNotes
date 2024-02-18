Shader "Custom/Mirror"
{
    Properties
    {
        _MainTex ("Mian Tex", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 texcoord : TEXCOORD0;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f ans;
                ans.pos = UnityObjectToClipPos(v.vertex);
                ans.uv = v.texcoord;
                ans.uv.x = 1 - ans.uv.x; // ¾µ×ÓµÄÍ¼ÏñÊÇ×óÓÒµßµ¹
                return ans;
            }

            float4 frag(v2f i) : SV_Target
            {
                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
