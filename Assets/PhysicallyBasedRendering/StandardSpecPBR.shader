Shader "Holistic/StandardSpecPBR"
{
    Properties {
        _Color ("Colour", Color) = (1,1,1,1)
        _MetallicTex("Metallic (R)", 2D) = "white" {}
        _SpecColor("Specular",Color) = (1,1,1,1)
        [MaterialToggle] _ReverseMap ( "Reverse Specular Map", Float ) = 0    
        }
    
    SubShader {
      
      Tags{
      "Queue" = "Geometry"
      }

      CGPROGRAM
        #pragma surface surf StandardSpecular
        
        sampler2D _MetallicTex;
        fixed4 _Color;
        float _ReverseMap;

        //_SpecColor is already pre defined

        struct Input {
            float2 uv_MetallicTex;
        };
        
        void surf (Input IN, inout SurfaceOutputStandardSpecular o) {
            o.Albedo = _Color.rgb;
            o.Smoothness = _ReverseMap ? 1 - tex2D(_MetallicTex,IN.uv_MetallicTex).r : tex2D(_MetallicTex,IN.uv_MetallicTex).r;
            o.Specular = _SpecColor.rgb;
            }
      
      ENDCG
    }
    Fallback "Diffuse"
}
