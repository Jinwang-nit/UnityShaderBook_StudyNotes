using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogWithDepthTexture : PostEffectsBase
{
    public Shader fogShader;
    private Material fogMaterial;
    public Material material
    {
        get
        {
            fogMaterial = CheckShaderAndCreateMaterial(fogShader, fogMaterial);
            return fogMaterial;
        }
    }

    private Camera myCamera;
    public Camera Camera
    {
        get
        {
            if (myCamera == null) myCamera = GetComponent<Camera>();
            return myCamera;
        }
    }
    private Transform myCameraTransform;
    public Transform CameraTransform
    {
        get
        {
            if (myCameraTransform == null) myCameraTransform = Camera.transform; 
            return myCameraTransform;
        }
    }

    [Range(0.0f, 3.0f)] public float fogDensity = 1.0f; // ÎíµÄÅ¨¶È
    public Color fogColor = Color.white;
    public float fogStart = 0.0f;
    public float fogEnd = 2.0f;

    private void OnEnable()
    {
        Camera.depthTextureMode = DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            Matrix4x4 frustumCorners = Matrix4x4.identity;

            float fov = Camera.fieldOfView;
            float near = Camera.nearClipPlane;
            float far = Camera.farClipPlane;
            float aspect = Camera.aspect;

            float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
            Vector3 toTop = CameraTransform.up * halfHeight * aspect;
            Vector3 toRight = CameraTransform.right * halfHeight * aspect;

            Vector3 topLeft = CameraTransform.forward * near + toTop - toRight;
            float scale = topLeft.magnitude / near;

            topLeft.Normalize();
            topLeft *= scale;

            Vector3 topRight = CameraTransform.right * near + toRight + toTop;
            topRight.Normalize();
            topRight *= scale;

            Vector3 bottomLeft = CameraTransform.right * near - toRight - toTop;
            bottomLeft.Normalize();
            bottomLeft *= scale;

            Vector3 bottomRight = CameraTransform.right * near + toRight - toTop;
            bottomRight.Normalize();
            bottomRight *= scale;

            frustumCorners.SetRow(0, bottomLeft);
            frustumCorners.SetRow(1, bottomRight);
            frustumCorners.SetRow(2, topRight);
            frustumCorners.SetRow(3, topLeft);

            material.SetMatrix("_FrustumCornersRay", frustumCorners);
            material.SetMatrix("_ViewProjectionInverseMatrix", (Camera.projectionMatrix * Camera.worldToCameraMatrix).inverse);

            material.SetFloat("_FogDensity", fogDensity);
            material.SetColor("_FogColor", fogColor);
            material.SetFloat("_FogStart", fogStart);
            material.SetFloat("_FogEnd", fogEnd);

            Graphics.Blit(source, destination, material);
        }
        else Graphics.Blit(source, destination);
    }
}
