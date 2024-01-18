Shader "Holistic/Plasma"
{
    Properties
    {
        _Tint ("Tint Color", Color) = (1,1,1,1)
        _Speed ("Speed", Range(1,100)) = 10
        _Scale1 ("Scale Horizontal", Range(0.1,10)) = 2
        _Scale2 ("Scale Vertical", Range(0.1,10)) = 2
        _Scale3 ("Scale Diagonal", Range(0.1,10)) = 2
        _Scale4 ("Scale Circular", Range(0.1,10)) = 2
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _MainTex;
        float4 _Tint;
        float _Speed;
        float _Scale1;
        float _Scale2;
        float _Scale3;
        float _Scale4;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            const float PI = 3.14159265;
            float t = _Time.x * _Speed;

            //vertical
            float col = sin (IN.worldPos.x * _Scale1 + t);

            //horizontal
            col += sin(IN.worldPos.z * _Scale2 + t);

            //diagonal
            col += sin(_Scale3 * (IN.worldPos.x * sin (t/2.0) + IN.worldPos.z * cos(t/3)) + t);

            //circular
            float c1 = pow(IN.worldPos.x + 0.5 * sin(t/5),2);
            float c2 = pow(IN.worldPos.z + 0.5 * cos(t/3),2);

            col+= sin (sqrt(_Scale4*(c1+c2) + 1 + t));

            o.Albedo.r = sin (col/4.0*PI);
            o.Albedo.g = sin (col/4.0*PI + PI/2);
            o.Albedo.b = sin (col/4.0*PI + PI);

            o.Albedo *= _Tint;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
