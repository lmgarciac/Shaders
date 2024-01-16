Shader "Holistic/Outlining"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _Outline ("Outline", Range(0.002,0.1)) = 0.005
    }
    SubShader
    {
      Tags 
      {
        "Queue" = "Transparent"
      } 

      //Using the Transparent render Queue will solve your Zbuffer problems but can cause other problems in the future.
      //Check out the AdvancedOutlining for a more adequate solution

        ZWrite Off
        
        CGPROGRAM

        #pragma surface surf Lambert vertex:vert

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Outline;
        float4 _OutlineColor;

        void vert (inout appdata_full v)
        {
            v.vertex.xyz += v.normal * _Outline;
        }

        sampler2D _MainTex;

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Emission = _OutlineColor.rgb;
        }

        ENDCG
        
        ZWrite On
        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _MainTex;


        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
