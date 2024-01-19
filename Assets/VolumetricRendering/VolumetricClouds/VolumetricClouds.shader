Shader "Holistic/VolumetricClouds"
{
    Properties
    {
        _Scale ("Scale", Range(0.1,10.0)) = 2.0
        _StepScale ("Step Scale", Range(0.1,100.0)) = 1.0
        _Steps ("Number of Steps", Range(1,200)) = 60
        _MinHeight ("Min Height", Range(0,5)) = 0
        _MaxHeight ("Max Height", Range(6.0,10.0)) = 10
        _FadeDist ("Fade Distance", Range(0.0,10.0)) = 0.5
        _SunDir ("Sun Direction", Vector) = (1,0,0,0)       
    }

    SubShader
    {
        Tags { "Queue"="Transparent" }

        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off Lighting Off ZWrite Off
        ZTest Always //Allow to put objects within the fog

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {                
                float4 pos : SV_POSITION;
                //float2 uv : TEXCOORD0;
                float3 view : TEXCOORD1;
                float4 projPos : TEXCOORD2;
                float3 wpos : TEXCOORD3;
            };

            float _MinHeight;
            float _MaxHeight;
            float _FadeDist;
            float _Scale;
            float _StepScale;
            float _Steps;
            float4 _SunDir;
            sampler2D _CameraDepthTexture;

            #define MARCH(steps, noiseMap, cameraPos, viewDir, bgcol, sum, depth, t) { \
                for (int i = 0; i < steps  + 1; i++) \
                { \
                    if(t > depth) \
                        break; \
                    float3 pos = cameraPos + t * viewDir; \
                    if (pos.y < _MinHeight || pos.y > _MaxHeight || sum.a > 0.99) \
                    {\
                        t += max(0.1, 0.02*t); \
                        continue; \
                    }\
                    \
                    float density = noiseMap(pos); \
                    if (density > 0.01) \
                    { \
                        float diffuse = clamp((density - noiseMap(pos + 0.3 * _SunDir)) / 0.6, 0.0, 1.0);\
                        sum = integrate(sum, diffuse, density, bgcol, t); \
                    } \
                    t += max(0.1, 0.02 * t); \
                } \
            } 

            //NOISEPROC makes for a smoother cutout

            #define NOISEPROC(N, P) 1.75 * N * saturate((_MaxHeight - P.y)/_FadeDist)

            float map1 (float3 q)
            {
                float3 p = q;
                float f; //Accumulation of noise (consider it a frequency)
                f = 0.5 * noise3d(q);
                //try leaving NOISEPROC out and returning just f to see the effect.
                return NOISEPROC(f, p);
            }

            fixed4 raymarch (float3 cameraPos, float3 viewDir, fixed4 bgcolor, float depth)
            {
                fixed4 col = fixed4(0,0,0,0);
                float ct = 0; //number of acumulated steps already done

                MARCH(_Steps, map1, cameraPos, viewDir, bgcolor, col, depth, ct)

                return clamp(col, 0.0, 1.0);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.wpos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.view = o.wpos - _WorldSpaceCameraPos;
                o.projPos = ComputeScreenPos(o.pos);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float depth = 1;
                depth *= length(i.view);
                fixed4 col = fixed4(1,1,1,0);
                fixed4 clouds = raymarch(_WorldSpaceCameraPos, normalize(i.view) * _StepScale, col, depth);
                fixed3 mixedCol = col * (1.0 - clouds.a) + clouds.rgb;

                return fixed4(mixedCol,clouds.a);
            }
            ENDCG
        }
    }
}
