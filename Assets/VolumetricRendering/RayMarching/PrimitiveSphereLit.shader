Shader "Holistic/PrimitiveSphereLit"
{
    SubShader
    {
        Tags { "Queue" = "Transparent" }
        
        Blend SrcAlpha OneMinusSrcAlpha
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
        
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                //float3 normal : NORMAL;
            };

            struct v2f
            {
                float3 wPos : TEXCOORD0; //World Position
                float4 pos : SV_POSITION;
                float3 posObj : TEXCOORD1;
                //fixed4 diff : COLOR0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.wPos = mul(unity_ObjectToWorld, v.vertex.xyz);
                o.posObj = mul(unity_ObjectToWorld, float4(0.0,0.0,0.0,1.0) );

                //half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                //half normalLighting = max(0, dot(worldNormal,_WorldSpaceLightPos0.xyz));
                //o.diff = normalLighting * _LightColor0;

                return o;
            }

            #define STEPS 128
            #define STEP_SIZE 0.01
            
            bool SphereHit (float3 position, float3 center, float radius)
            {
                return distance(position, center) < radius;
            }

            float3 RaymarchHit (float3 position, float3 direction, float3 center)
            {
                for (int i = 0; i<STEPS; i++)
                {                           //Center      //Radius
                    //if (SphereHit(position, float3(0,0,0), 0.5))
                    if (SphereHit(position, center, 0.5))
                        return position;

                    position += direction * STEP_SIZE;
                }

                return float3(0,0,0);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 viewDirection = normalize(i.wPos - _WorldSpaceCameraPos);
                float3 worldPositionPixel = i.wPos;
                float3 depth = RaymarchHit(worldPositionPixel, viewDirection, i.posObj);

                half3 worldNormal = depth - i.posObj;
                half normalLighting = max(0, dot(worldNormal,_WorldSpaceLightPos0.xyz));

                if (length(depth) != 0)
                    {
                        depth *= normalLighting * _LightColor0 * 2; //Mulitply by 2 because it's a bit dark
                        return fixed4 (depth,1);
                    }
                else
                    return fixed4 (1,1,1,0);
            }
            ENDCG
        }
    }
}
