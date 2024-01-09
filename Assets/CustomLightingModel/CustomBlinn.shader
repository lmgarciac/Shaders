Shader "Holistic/CustomBlinn"
{
    Properties {
        _Colour ("Colour", Color) = (1,1,1,1)
    }

    SubShader {

      Tags{
      "Queue" = "Geometry"
      }  

      CGPROGRAM
        #pragma surface surf CustomBlinn
        
        //This is actually the basic Blinn model

        half4 LightingCustomBlinn (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
        {
            half3 h = normalize(lightDir + viewDir);

            half diff = max (0,dot (s.Normal, lightDir));

            float nh = max (0,dot (s.Normal,h));
            float spec = pow (nh,48.0); //48 is what Unity uses

            half4 c;
            c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten;

            //Use this instead and press Play for time effect.
            //c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten * _SinTime; 

            c.a = s.Alpha;
            return c;
        }

        float4 _Colour;

        struct Input {
            float2 uv_MainTex;
        };
        
        void surf (Input IN, inout SurfaceOutput o) {
                o.Albedo = _Colour.rgb;
            }
      
      ENDCG
    }
    Fallback "Diffuse"
}
