using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class GaussianBlur : PostEffectsBase
{
    public Shader gaussianBlurShader;
    private Material gaussianBlurMaterial;
    public Material material
    {
        get
        {
            gaussianBlurMaterial = CheckShaderAndCreateMaterial(gaussianBlurShader, gaussianBlurMaterial);
            return gaussianBlurMaterial;
        }
    }

    [Range(0, 4)] public int iterations = 3; // 模糊迭代次数
    [Range(0.2f, 3)] public float blurSpread = 0.6f; // 模糊范围
    [Range(1, 9)] public int downSample = 2; // 缩放系数

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            int rtW = source.width / downSample;
            int rtH = source.height / downSample;

            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear; // 双线采样
            Graphics.Blit(source, buffer0);

            for (int i = 0; i < iterations; i++)
            {
                material.SetFloat("_BlurSize", 1.0f + i * blurSpread);
                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer0, buffer1, material, 0);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit (buffer0, buffer1, material, 1);
                buffer0 = buffer1;
            }
            Graphics.Blit(buffer0, destination);
        }
        else Graphics.Blit(source, destination);
    }
}
