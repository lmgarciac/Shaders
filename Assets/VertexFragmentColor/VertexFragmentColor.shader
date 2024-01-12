Shader "Holistic/VertexFragmentColor"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                //o.color.r = v.vertex.x; //So the color moves with the mesh

                //Other variants playing with numbers
                //o.color.r = v.vertex.x + 5; 
                //o.color.r = (v.vertex.x + 5) / 10; 
                //o.color.r = (v.vertex.x + 5) / 5; 
                
                o.color.r = (v.vertex.x + 10) / 20; 
                o.color.g = (v.vertex.z + 10) / 20; 

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = i.color;

                //You can also set the colors in the fragment. Remember that this is screen space so numbers are pixel numbers.
                //you are coloring pixels in the screen

                //col.r = i.vertex.x / 1000;
                //col.g = i.vertex.y / 1000;

                return col;
            }
            ENDCG
        }
    }
}
