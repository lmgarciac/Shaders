Shader "Holistic/AdvancedOutlining"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _Outline ("Outline", Range(0.002,0.1)) = 0.005
    }
    SubShader
    {
        
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

        Pass
        {
            Cull Front

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata 
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                fixed4 color: COLOR;
            };

            float _Outline;
            float4 _OutlineColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                //This returns the normal in the form of a world coordinate rather than the normal that belongs to the vertex
                //which would be the one in local space
                float3 norm = normalize(mul((float3x3)UNITY_MATRIX_IT_MV,v.normal));
                
                //Project the normal from the world to the view or clipping space
                float2 normalOffset = TransformViewToProjection(norm.xy);

                o.pos.xy += normalOffset * o.pos.z * _Outline;
                o.color = _OutlineColor;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return i.color;
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
