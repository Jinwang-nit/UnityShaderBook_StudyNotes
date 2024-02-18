using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetecBormalAndDepth : PostEffectsBase
{
    public Shader edgeDetectShader;
    private Material edgeDetectMaterial;
    public Material material
    {
        get
        {
            edgeDetectMaterial = CheckShaderAndCreateMaterial(edgeDetectShader, edgeDetectMaterial);
            return edgeDetectMaterial;
        }
    }

    [Range(0.0f, 1.0f)] public float edgeOnly = 0.0f; // 描边线强度
    public Color edgeColor = Color.black; // 描边线颜色
    public Color backgroundColor = Color.white; // 背景颜色

    public float sampleDistance = 1.0f; // 采样距离
    public float sensitivityDepth = 1.0f; // 深度灵敏度参数
    public float sensitivityNormals = 1.0f; // 法线灵敏度参数

    private void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    [ImageEffectOpaque] // 在透明物体之前渲染
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            material.SetFloat("_EdgeOnly", edgeOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);
            material.SetFloat("_SampleDistance", sampleDistance);
            material.SetVector("_Sensitivity", new Vector4(sensitivityNormals, sensitivityDepth, 0.0f, 0.0f));
            Graphics.Blit(source, destination, material);
        }
        else
        {
             Graphics.Blit(source, destination);
        }
    }
}
