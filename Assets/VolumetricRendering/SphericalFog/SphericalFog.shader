Shader "Holistic/SphericalFog"
{
    Properties
    {
        _FogCenter ("Fog Center / Radius", Vector) = (0,0,0,0.5) //First 3 values are center, Last value is radius
        _FogColor ("Fog Color", Color) = (1,1,1,1)
        _InnerRatio ("Inner Ratio", Range(0.0,0.9)) = 0.5
        _Density ("Density", Range (0.0,1.0)) = 0.5
        _Steps ("March Steps", Range (1,30)) = 10
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

            half _Steps;

            float CalculateFogIntensity (float3 sphereCenter, float sphereRadius, float innerRatio, float fogDensity, 
                                         float3 cameraPosition, float3 viewDirection, float maxDistance)
            {
                //Calculate ray-sphere intersection.
                //For the math of the calculation check the intersections between a ray and a circle.
                //a = D^2
                //b = 2 * camera * D
                //c = camera^2 - R^2

                float3 localCam = cameraPosition - sphereCenter;
                float a = dot(viewDirection,viewDirection); //This is the vector squared
                float b = 2 * dot(viewDirection, localCam);
                float c = dot (localCam, localCam) - sphereRadius * sphereRadius;

                float d = b * b - 4 * a * c; //the discriminant from the quadratic solution equation

                if (d <= 0.0)
                    return 0;
                
                //It's possible for the ray not to hit the sphere twice. For example if the ray is not long enough 
                //or de camera is inside the sphere.

                float distanceSquared = sqrt(d);
                float dist = max((-b - distanceSquared)/2*a , 0);
                float dist2 = max((-b + distanceSquared)/2*a , 0);

                //Now that we have the intersection points we're going to do Ray marching between them from front to back.

                float backDepth = min (maxDistance, dist2);
                float sampleA = dist;
                float step_distance = (backDepth - dist) / _Steps; //Make X amount of steps.
                float step_contribution = fogDensity; //How much more fog is going to be added for each step taken into the sphere

                float centerValue = 1/(1-innerRatio);

                //Marching
                float clarity = 1; //Full clear

                for (int seg = 0; seg < _Steps; seg ++)
                {
                    float3 position = localCam + viewDirection * sampleA;
                    float val = saturate(centerValue * (1 - length(position)/sphereRadius));
                    float fog_amount = saturate(val * step_contribution);
                    clarity *= (1 - fog_amount);
                    sampleA += step_distance;
                }

                return 1 - clarity;
            }

            struct v2f
            {
                float3 view : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 projPos : TEXCOORD1;
            };

            float4 _FogCenter;
            fixed4 _FogColor;
            float _InnerRatio;
            float _Density;
            sampler2D _CameraDepthTexture;

            v2f vert (appdata_base v)
            {
                v2f o;
                float4 wPos = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.view = wPos.xyz - _WorldSpaceCameraPos;
                o.projPos = ComputeScreenPos(o.pos);
                
                float inFrontOf = (o.pos.z/o.pos.w) > 0; //Test to see if pixel is behind the near plane to bring it forward
                o.pos.z *= inFrontOf;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half4 col = half4(1,1,1,1);
                
                //Max depth that we're getting from our camera for a particular pixel when we project it through the screen
                float depth = LinearEyeDepth (UNITY_SAMPLE_DEPTH (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD (i.projPos))));
                float3 viewDir = normalize (i.view);

                float calculatedFog = CalculateFogIntensity(_FogCenter.xyz, _FogCenter.w, _InnerRatio, _Density, 
                                                  _WorldSpaceCameraPos, viewDir, depth);

                col.rgb = _FogColor.rgb;
                col.a = calculatedFog;
                
                return col;
            }
            ENDCG
        }
    }
}
