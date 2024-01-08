Shader "Holistic/ZbufferTest2"
{
    Properties {
        _myTex ("Texture", 2D) = "white" {}
    }
    SubShader {

    Tags {"Queue" = "Geometry"}
    ZWrite Off

      CGPROGRAM
        #pragma surface surf Lambert
        
        sampler2D _myTex;

        struct Input {
            float2 uv_myTex;
        };
        
        void surf (Input IN, inout SurfaceOutput o) {
            o.Albedo = (tex2D(_myTex, IN.uv_myTex)).rgb;
        }
      
      ENDCG
    }
    Fallback "Diffuse"
}
