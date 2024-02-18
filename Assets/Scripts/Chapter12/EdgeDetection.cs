using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetection : PostEffectsBase
{
    public Shader edgeDetectionShader;
    private Material edgeDectMaterial;
    public Material material
    {
        get
        {
            edgeDectMaterial = CheckShaderAndCreateMaterial(edgeDetectionShader, edgeDectMaterial);
            return edgeDectMaterial;
        }
    }

    [Range(0, 1)] public float edgesOnly = 0.0f;
    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            material.SetFloat("_EdgeOnly", edgesOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);
            Graphics.Blit(source, destination, material);
        }
        else Graphics.Blit(source, destination);
    }
}
