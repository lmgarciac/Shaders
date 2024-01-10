Shader "Holistic/HologramShader"
{
    Properties
    {
        _rimColor ("Rim Color", Color) = (0,0.5,0.5,0)
        _rimPower ("Rim Power", Range(0.5,8)) = 1
    }



    SubShader
    {
        Tags 
        {
        "Queue" = "Transparent"
        }
        
        Pass 
        {
            ZWrite On
            ColorMask 0
        }
        
        CGPROGRAM
            #pragma surface surf Lambert alpha:fade
            
            struct Input 
            {
                float3 viewDir;
            };
            
            float4 _rimColor;
            float _rimPower; 

            void surf (Input IN, inout SurfaceOutput o)
            {
                half rim = 1 - saturate(dot(normalize(IN.viewDir), o.Normal));
                o.Emission = _rimColor.rgb * pow(rim,_rimPower);
                o.Alpha = pow (rim, _rimPower);
            }
        ENDCG
    }

    FallBack "Diffuse"
}
