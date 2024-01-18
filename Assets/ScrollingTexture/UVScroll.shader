Shader "Holistic/UVScroll"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _FoamTex ("Foam Texture", 2D) = "white" {}
        _ScrollX ("Scroll X",Range(-5,5)) = 0
        _ScrollY ("Scroll Y",Range (-5,5)) = 0
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _MainTex;
        sampler2D _FoamTex;
        float _ScrollX;
        float _ScrollY;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            _ScrollX *= _Time;
            _ScrollY *= _Time;

            //Regular Scrolling Water
            //float2 newuv = IN.uv_MainTex + float2(_ScrollX, _ScrollY);
            //o.Albedo = tex2D(_MainTex,newuv);

            //Scrolling water with foam on top
            float3 water = (tex2D(_MainTex,IN.uv_MainTex + float2(_ScrollX,_ScrollY))).rgb;
            float3 foam = (tex2D(_FoamTex,IN.uv_MainTex + float2(_ScrollX/2.0,_ScrollY/2.0))).rgb;
            o.Albedo = (water + foam)/2.0; //Average it to not get such a bright texture

        }
        ENDCG
    }
    FallBack "Diffuse"
}
