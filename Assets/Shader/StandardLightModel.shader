// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/StandardLightModel"
{
    Properties
    {
        _Color("Color Pint", Color) = (1, 1, 1, 1)
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _MainTex("Main Tex", 2D) = "white"{}
        _BumpMap("Normal Map", 2D) = "bump"{}
        _BumpScale("Normal Scale", Float) = 1.0
        _Gloss("Gloss", range(0, 256)) = 20
        //_Cutoff("Cutoff", range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        //Tags {"Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout"}
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "Autolight.cginc"

            float4 _Color;
            float4 _Specular;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            float _Gloss;
            //float _Cutoff;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };
            struct v2f
            {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;  
				float4 TtoW1 : TEXCOORD2;  
				float4 TtoW2 : TEXCOORD3;
				SHADOW_COORDS(4)
            };

            v2f vert(a2v v)
            {
                v2f ans;
                ans.pos = UnityObjectToClipPos(v.vertex);

                ans.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                ans.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                ans.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                ans.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                ans.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                TRANSFER_SHADOW(ans);
                return ans;
            }

            float4 frag(v2f v) : SV_Target
            {
                float3 worldPos = float3(v.TtoW0.w, v.TtoW1.w, v.TtoW2.w);
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                
                float3 bump = UnpackNormal(tex2D(_BumpMap, v.uv.zw));
                bump.xy *= _BumpScale;
                bump.z = sqrt(1.0 - max(0, dot(bump.xy, bump.xy)));
                bump = normalize(float3(dot(v.TtoW0.xyz, bump), dot(v.TtoW1.xyz, bump), dot(v.TtoW2.xyz, bump)));

                float4 texColor = tex2D(_MainTex, v.uv.xy);
                // TODO : Í¸Ã÷¶È²âÊÔ
                // clip(texColor.a - _Cutoff);
                //
                
                float3 albedo = texColor.rgb * _Color.rgb;
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                float3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldLightDir, bump));

                float3 halfDir = normalize(worldLightDir + worldViewDir);
                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)), _Gloss);

                UNITY_LIGHT_ATTENUATION(atten, v, worldPos);
                return float4(ambient + (diffuse + specular) * atten, 1.0);
            }
            ENDCG
        }

        Pass
        {
            Tags{"LightMode" = "ForwardAdd"}
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            #include "Lighting.cginc"
            #include "Autolight.cginc"

            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;

            struct a2v
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };
            struct v2f
            {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;  
				float4 TtoW1 : TEXCOORD2;  
				float4 TtoW2 : TEXCOORD3;
				SHADOW_COORDS(4)
            };

            v2f vert(a2v v)
            {
                v2f ans;
                ans.pos = UnityObjectToClipPos(v.vertex);
                ans.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                ans.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
                ans.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                ans.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                ans.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                TRANSFER_SHADOW(ans);
                return ans;
            }

            float4 frag(v2f v) : SV_Target
            {
                float3 worldPos = float3(v.TtoW0.w, v.TtoW1.w, v.TtoW2.w);
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                
                float3 bump = UnpackNormal(tex2D(_BumpMap, v.uv.zw));
                bump.xy *= _BumpScale;
                bump.z = sqrt(1.0 - max(0, dot(bump.xy, bump.xy)));
                bump = normalize(float3(dot(v.TtoW0.xyz, bump), dot(v.TtoW1.xyz, bump), dot(v.TtoW2.xyz, bump)));

                float4 texColor = tex2D(_MainTex, v.uv.xy);
                float3 albedo = texColor.rgb * _Color.rgb;
                float3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldLightDir, bump));


                UNITY_LIGHT_ATTENUATION(atten, v, worldPos);
                return float4(diffuse * atten, 1.0);
            }
            ENDCG
        }
    }
    // FallBack "Transparent/Cutout/VertexLit"
    FallBack "Specular"
}
