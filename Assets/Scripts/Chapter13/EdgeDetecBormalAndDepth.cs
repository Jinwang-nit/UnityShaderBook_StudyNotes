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

    [Range(0.0f, 1.0f)] public float edgeOnly = 0.0f; // �����ǿ��
    public Color edgeColor = Color.black; // �������ɫ
    public Color backgroundColor = Color.white; // ������ɫ

    public float sampleDistance = 1.0f; // ��������
    public float sensitivityDepth = 1.0f; // ��������Ȳ���
    public float sensitivityNormals = 1.0f; // ���������Ȳ���

    private void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    [ImageEffectOpaque] // ��͸������֮ǰ��Ⱦ
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
