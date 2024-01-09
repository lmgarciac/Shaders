Shader "Holistic/CustomToonRamp"
{
    Properties {
        _Colour ("Colour", Color) = (1,1,1,1)
        _RampTex ("Ramp Texture", 2D) = "white" {}
    }

    SubShader {

      Tags{
      "Queue" = "Geometry"
      }  

      CGPROGRAM
        #pragma surface surf CustomToonRamp

        float4 _Colour;
        sampler2D _RampTex;        

        half4 LightingCustomToonRamp (SurfaceOutput s, half3 lightDir, half atten)
        {
            float diff = dot (s.Normal, lightDir);
            float h = diff * 0.5 + 0.5; //This is done to actually calculate the corresponding UV value for the ramp texture 
            float2 rh = h; //This will retur a "UV" value between (0,0) and (1,1)
            float3 ramp = tex2D(_RampTex, rh).rgb;

            float4 c;
            c.rgb = s.Albedo * _LightColor0.rgb * (ramp);
            c.a = s.Alpha;
            return c;
        }


        struct Input {
            float2 uv_MainTex;
            float3 viewDir;
        };
        
        void surf (Input IN, inout SurfaceOutput o) {
            
            o.Albedo = _Colour.rgb;

            //Cool effect which uses the viewDir and Normal, and the ramp texture to set the Albedo
            //Comment the following code for the basic Albedo color setting.

            float diff = dot (o.Normal, IN.viewDir);
			float h = diff * 0.5 + 0.5;
			float2 rh = h;
			o.Albedo = tex2D(_RampTex, rh).rgb;
            }
      
      ENDCG
    }
    Fallback "Diffuse"
}
