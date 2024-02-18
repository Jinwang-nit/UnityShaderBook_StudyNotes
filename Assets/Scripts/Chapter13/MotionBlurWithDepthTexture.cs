using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurWithDepthTexture : PostEffectsBase
{
    public Shader motionBlurShader;
    private Material motionBlurMaterial;
    public Material material
    {
        get
        {
            motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMaterial);
            return motionBlurMaterial;
        }
    }

    [Range(0.0f, 1.0f)] public float blurSize = 0.5f;

    private Camera myCamera;
    public Camera MyCamera
    {
        get
        {
            if (myCamera == null) return GetComponent<Camera>();
            return myCamera;
        }
    }
    private Matrix4x4 previousViewProjectionMatrix; // 上一帧的视角 * 投影矩阵
    private void OnEnable()
    {
        MyCamera.depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            material.SetFloat("_BlurSize", blurSize);
            material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);

            Matrix4x4 currentViewProjectionMatrix = MyCamera.projectionMatrix * MyCamera.worldToCameraMatrix; // 当前视角 * 投影矩阵
            Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse; // 逆矩阵

            material.SetMatrix("_CurrentViewProjectionInverseMatrix", currentViewProjectionInverseMatrix);
            previousViewProjectionMatrix = currentViewProjectionMatrix;

            Graphics.Blit(source, destination, material);
        }
        else Graphics.Blit(source, destination);
    }
}
