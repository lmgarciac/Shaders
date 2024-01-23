using System;
using UnityEngine;
using static UnityEditor.ShaderData;

[ExecuteInEditMode]
public class CloudsCamShader : MonoBehaviour
{
    [SerializeField] private Shader _cloudShader;
    [SerializeField] private float _minHeight = 0f;
    [SerializeField] private float _maxHeight = 5f;
    [SerializeField] private float _fadeDist = 2f;
    [SerializeField] private float _scale = 5;
    [SerializeField] private float _steps = 50;
    [SerializeField] private Texture _valueNoiseImage;
    [SerializeField] private Transform _sun;

    private Camera _cam;
    private Material _shaderMaterial;

    public Material ShaderMaterial
    {
        get
        {
            if (_shaderMaterial == null && _cloudShader != null)
                _shaderMaterial = new Material(_cloudShader);
            else if (_shaderMaterial != null && _cloudShader == null)
                DestroyImmediate(_shaderMaterial);
            else if (_shaderMaterial != null && _cloudShader != null && _cloudShader != _shaderMaterial.shader)
            {
                DestroyImmediate(_shaderMaterial);
                _shaderMaterial = new Material(_cloudShader);
            }

            return _shaderMaterial;
        }
    }

    private void Start()
    {
        if (_shaderMaterial)
            DestroyImmediate(_shaderMaterial);
    }

    private Matrix4x4 GetFrustumCorners()
    {
        Matrix4x4 frustumCorners = Matrix4x4.identity;
        Vector3[] fCorners = new Vector3[4];

        _cam.CalculateFrustumCorners(new Rect(0,0,1,1), _cam.farClipPlane, Camera.MonoOrStereoscopicEye.Mono,fCorners);

        frustumCorners.SetRow(0, Vector3.Scale(fCorners[1], new Vector3(1,1,-1)));
        frustumCorners.SetRow(1, Vector3.Scale(fCorners[2], new Vector3(1, 1, -1)));
        frustumCorners.SetRow(2, Vector3.Scale(fCorners[3], new Vector3(1, 1, -1)));
        frustumCorners.SetRow(3, Vector3.Scale(fCorners[0], new Vector3(1, 1, -1)));

        return frustumCorners;
    }

    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (ShaderMaterial == null || _valueNoiseImage == null)
        {
            Graphics.Blit(source, destination); //Just render what the camera can already see
            return;
        }

        if (_cam == null)
            _cam = GetComponent<Camera>();

        ShaderMaterial.SetTexture("_ValueNoise", _valueNoiseImage);

        if (_sun != null)
            ShaderMaterial.SetVector("_SunDir", _sun.forward);
        else
            ShaderMaterial.SetVector("_SunDir", Vector3.up);

        ShaderMaterial.SetFloat("_MinHeight", _minHeight);
        ShaderMaterial.SetFloat("_MaxHeight", _maxHeight);
        ShaderMaterial.SetFloat("_FadeDist", _fadeDist);
        ShaderMaterial.SetFloat("_Scale", _scale);
        ShaderMaterial.SetFloat("_Steps", _steps);

        ShaderMaterial.SetMatrix("_FrustumCornersWS", GetFrustumCorners());
        ShaderMaterial.SetMatrix("_CameraInvViewMatrix", _cam.cameraToWorldMatrix);
        ShaderMaterial.SetVector("_CameraPosWS", _cam.transform.position);

        CustomGraphicsBlit(source, destination, ShaderMaterial, 0);
    }

    private static void CustomGraphicsBlit(RenderTexture source, RenderTexture destination, Material shaderMaterial, int passNumber)
    {
        RenderTexture.active = destination;

        shaderMaterial.SetTexture("_MainTex", source);

        GL.PushMatrix();
        GL.LoadOrtho();

        shaderMaterial.SetPass(passNumber);

        GL.Begin(GL.QUADS);

        GL.MultiTexCoord2(0, 0.0f, 0.0f);
        GL.Vertex3(0.0f, 0.0f, 3.0f); // BL

        GL.MultiTexCoord2(0, 1.0f, 0.0f);
        GL.Vertex3(1.0f, 0.0f, 2.0f); // BR

        GL.MultiTexCoord2(0, 1.0f, 1.0f);
        GL.Vertex3(1.0f, 1.0f, 1.0f); // TR

        GL.MultiTexCoord2(0, 0.0f, 1.0f);
        GL.Vertex3(0.0f, 1.0f, 0.0f); // TL

        GL.End();
        GL.PopMatrix();
    }

    protected virtual void OnDisable()
    {
        if (_shaderMaterial)
            DestroyImmediate(_shaderMaterial);
    }
}
