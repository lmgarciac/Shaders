Shader "Holistic/LeavesCulling"
{
    Properties {
        _MainText ("Texture", 2D) = "black" {}
    }

    SubShader {

      Tags  {
      "Queue" = "Transparent"
            }
      
      Blend SrcAlpha OneMinusSrcAlpha //This is the traditional blend
      Cull Off // Now you can see all sides since there's no Culling

      Pass  {
        SetTexture [_MainText] {combine texture}
            }
      
      }

}
