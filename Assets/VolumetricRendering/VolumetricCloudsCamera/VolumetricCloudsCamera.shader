Shader "Holistic/VolumetricCloudsCamera"
{
    Properties
    {
        _MainTex ("", 2D) = "white" {}  
    }

    SubShader
    {
        ZTest Always Cull Off ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {                
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 view : TEXCOORD1;
            };

            float _MinHeight;
            float _MaxHeight;
            float _FadeDist;
            float _Scale;
            float _StepScale;
            float _Steps;
            float4 _SunDir;
            sampler2D _CameraDepthTexture;

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            sampler2D _ValueNoise;

            float4x4 _FrustumCornersWS;
            float4 _CameraPosWS;
            float4x4 _CameraInvViewMatrix;

            fixed4 integrate (fixed4 sum, float diffuse, float density, fixed4 bgcol, float t)
            {
                fixed3 lighting = fixed3 (0.65,0.68,0.7) * 1.3 + 0.5 * fixed3 (0.7,0.5,0.3) * diffuse;
                
                //You can make light red
                //fixed3 lighting = fixed3 (1,0,0) * 1.3 + 0.5 * fixed3 (0.7,0.5,0.3) * diffuse;
                
                fixed3 colrgb = lerp(fixed3(1.0,0.95,0.8), fixed3(0.65,0.65,0.65), density);
                fixed4 col = fixed4 (colrgb.r,colrgb.g,colrgb.b,density);
                col.rgb *= lighting;
                col.rgb = lerp(col.rgb, bgcol, 1.0 - exp(-0.003*t*t));
                col.a *= 0.5;
                col.rgb *= col.a;

                return sum + col*(1.0-sum.a);
            }

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

            float NoiseFromImage(float3 x)
            {
                x *= _Scale;
                float3 p = floor(x);
                float3 f = frac(x);
                f = smoothstep(0,1,f);

                float2 uv = (p.xy + float2(37.0,-17.0) * p.z + f.xy);
                float2 rg = tex2Dlod(_ValueNoise, float4(uv/256,0,0)).rg;
                return -1.0 + 2.0 * lerp(rg.g, rg.r, f.z);
            }

            float map5 (float3 q) //We can copy map1 function and even do a different one
            {
                float3 p = q;
                float f; //Accumulation of noise (consider it a frequency)
                f = 0.5 * NoiseFromImage(q);

                q = q * 2;
                f += 0.25 * NoiseFromImage(q); // We can acumulate the values of f

                q = q * 3;
                f += 0.125 * NoiseFromImage(q); // We can acumulate the values of f

                q = q * 4;
                f += 0.0625 * NoiseFromImage(q); // We can acumulate the values of f

                q = q * 5;
                f += 0.03125 * NoiseFromImage(q); // We can acumulate the values of f

                //try leaving NOISEPROC out and returning just f to see the effect.
                return NOISEPROC(f, p);
            }

            float map4 (float3 q) //We can copy map1 function and even do a different one
            {
                float3 p = q;
                float f; //Accumulation of noise (consider it a frequency)
                f = 0.5 * NoiseFromImage(q);

                q = q * 2;
                f += 0.25 * NoiseFromImage(q); // We can acumulate the values of f

                q = q * 3;
                f += 0.125 * NoiseFromImage(q); // We can acumulate the values of f

                q = q * 4;
                f += 0.0625 * NoiseFromImage(q); // We can acumulate the values of f

                q = q * 5;
                f += 0.03125 * NoiseFromImage(q); // We can acumulate the values of f

                q = q * 6;
                f += 0.015625 * NoiseFromImage(q); // We can acumulate the values of f
                
                //try leaving NOISEPROC out and returning just f to see the effect.
                return NOISEPROC(f, p);
            }

            float map3 (float3 q) //We can copy map1 function and even do a different one
            {
                float3 p = q;
                float f; //Accumulation of noise (consider it a frequency)
                f = 0.5 * NoiseFromImage(q);

                q = q * 2;
                f += 0.25 * NoiseFromImage(q); // We can acumulate the values of f

                q = q * 3;
                f += 0.125 * NoiseFromImage(q); // We can acumulate the values of f

                q = q * 4;
                f += 0.0625 * NoiseFromImage(q); // We can acumulate the values of f

                //try leaving NOISEPROC out and returning just f to see the effect.
                return NOISEPROC(f, p);
            }

            float map2 (float3 q) //We can copy map1 function and even do a different one
            {
                float3 p = q;
                float f; //Accumulation of noise (consider it a frequency)
                f = 0.5 * NoiseFromImage(q);

                q = q * 2;
                f += 0.25 * NoiseFromImage(q); // We can acumulate the values of f

                q = q * 3;
                f += 0.125 * NoiseFromImage(q); // We can acumulate the values of f

                //try leaving NOISEPROC out and returning just f to see the effect.
                return NOISEPROC(f, p);
            }

            float map1 (float3 q)
            {
                float3 p = q;
                float f; //Accumulation of noise (consider it a frequency)
                f = 0.5 * NoiseFromImage(q);

                q = q * 2;
                f += 0.25 * NoiseFromImage(q); // We can acumulate the values of f
                //try leaving NOISEPROC out and returning just f to see the effect.
                return NOISEPROC(f, p);
            }

            fixed4 raymarch (float3 cameraPos, float3 viewDir, fixed4 bgcolor, float depth)
            {
                fixed4 col = fixed4(0,0,0,0);
                float ct = 0; //number of acumulated steps already done

                MARCH(_Steps, map1, cameraPos, viewDir, bgcolor, col, depth, ct) //col comes out automatically through the macro                
                MARCH(_Steps, map2, cameraPos, viewDir, bgcolor, col, depth * 2, ct) //you can other macro steps using different maps
                MARCH(_Steps, map3, cameraPos, viewDir, bgcolor, col, depth * 3, ct) //you can other macro steps using different maps
                MARCH(_Steps, map4, cameraPos, viewDir, bgcolor, col, depth * 4, ct) //you can other macro steps using different maps
                MARCH(_Steps, map5, cameraPos, viewDir, bgcolor, col, depth * 5, ct) //you can other macro steps using different maps

                return clamp(col, 0.0, 1.0);
            }

            v2f vert (appdata_img v)
            {
                v2f o;
                
                half index = v.vertex.z;
                v.vertex.z = 0.1; //Move it just behind the cameraPos
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy;

                #if UNITY_UV_START_AT_TOP
                    if (_MainTexSize.y < 0)
                        o.uv.y = 1 - o.uv.y; //Turn the camera around
                #endif

                o.view = _FrustumCornersWS[(int)index];
                o.view /= abs(o.view.z);
                o.view = mul(_CameraInvViewMatrix, o.view); //Changing the view direction into the space of the camera itself

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 start = _CameraPosWS;
                float2 duv = i.uv;

                #if UNITY_UV_START_AT_TOP
                    if (_MainTexSize.y < 0)
                        duv.y = 1 - duv.y; //Turn the camera around
                #endif

                float depth = LinearEyeDepth(tex2D(_CameraDepthTexture, duv).r);
                depth *= length(normalize(i.view));

                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 sum = raymarch(start, normalize(i.view), col, depth);

                return fixed4(col * (1.0 - sum.a) + sum.rgb, 1.0);
            }
            ENDCG
        }
    }
}
