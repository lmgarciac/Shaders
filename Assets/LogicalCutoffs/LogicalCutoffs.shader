Shader "Holistic/Cutoff" {
    Properties {
      _RimColor ("Rim Color", Color) = (0,0.5,0.5,0.0)
      _StripeColor1 ("Stripe Color 1", Color) = (0,1,0,0)
      _StripeColor2 ("Stripe Color 2", Color) = (1,0,0,0)
      _StripeWidth ("StripeWidth", Range(0.5,100)) = 10
	  _myDiffuseTex ("Diffuse Texture", 2D) = "white" {}
    }
    SubShader {
      CGPROGRAM
      #pragma surface surf Lambert
      struct Input {
          float2 uv_myDiffuseTex;
          float3 viewDir;
          float3 worldPos;
      };

      float4 _RimColor;
      float4 _StripeColor1;
      float4 _StripeColor2;
      float _StripeWidth;
      sampler2D _myDiffuseTex;

      void surf (Input IN, inout SurfaceOutput o) {
          o.Albedo = tex2D(_myDiffuseTex, IN.uv_myDiffuseTex).rgb;
          half rim = 1 - saturate(dot(normalize(IN.viewDir), o.Normal));
          o.Emission = frac(IN.worldPos.y * _StripeWidth * 0.5) > 0.4 ? 
                          _StripeColor1*rim: _StripeColor2*rim;
      }
      ENDCG
    } 
    Fallback "Diffuse"
  }