Shader "Custom/GlassRefraction"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "white"{}
        _BumpMap("Normal Map", 2D) = "bump"{}
        _Cubemap("Environment Cubemap", Cube) = "_Skybox"{}
        _Distortion("Distortion", Range(0, 100)) = 10 // 控制折射时图像的扭曲程度
        _RefractAmount("Refract Amount", Range(0.0, 1.0)) = 1.0 // 折射程度
    }
    SubShader
    {
        Tags{"Queue" = "Transparent" "RenderType" = "Opaque"}
        GrabPass{"_RefractionTex"}
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
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			samplerCUBE _Cubemap;
			float _Distortion;
			fixed _RefractAmount;
			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;
            
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord : TEXCOORD0;
            };
            struct v2f
            {
				float4 pos : SV_POSITION;
				float4 scrPos : TEXCOORD0;
				float4 uv : TEXCOORD1;
				float4 TtoW0 : TEXCOORD2;  
			    float4 TtoW1 : TEXCOORD3;  
			    float4 TtoW2 : TEXCOORD4; 
            };

            v2f vert(a2v v)
            {
                v2f ans;
                ans.pos = UnityObjectToClipPos(v.vertex);
                ans.scrPos = ComputeGrabScreenPos(ans.pos);
                ans.uv.xy = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
                ans.uv.zw = v.texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 
				
				ans.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);  
				ans.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);  
				ans.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  
                return ans;
            }

            float4 frag(v2f i) : SV_Target
            {
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));

                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                i.scrPos.xy = offset + i.scrPos.xy;
                float3 refrColor = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w).rgb;
                bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
                float3 reflDir = reflect(-worldViewDir, bump);
                float4 texColor = tex2D(_MainTex, i.uv.xy);
                float3 reflColor = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb;
                float3 finaColor = reflColor * (1 - _RefractAmount) + refrColor * _RefractAmount;

                return float4(finaColor, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
