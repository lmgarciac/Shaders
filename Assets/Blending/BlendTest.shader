Shader "Holistic/BlendTest"
{
    Properties {
        _MainText ("Texture", 2D) = "black" {}
    }

    SubShader {

      Tags  {
      "Queue" = "Transparent"
            }
      
      //Change Blend methods to see how different combinations work
      //Remember, basically Black is 0 and White is 1 so some type of blends can create transparency 
      //where a particular color is (see the Decal texture and use One One as example)

      Blend One One
      //Blend SrcAlpha OneMinusSrcAlpha //This is the traditional blend
      //Blend DstColor Zero

      Pass  {
        SetTexture [_MainText] {combine texture}
            }
      
      }

}
