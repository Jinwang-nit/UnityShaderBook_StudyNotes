using System.IO;
using UnityEditor;
using UnityEngine;

public class CreateNoiseTex : ScriptableWizard
{
    public float scale;
    void OnWizardUpdate()
    {
        helpString = "Select transform to render from and cubemap to render into";
        isValid = scale != 0;
    }

    void OnWizardCreate()
    {
        GeneratePerlinNoiseMap(scale);
    }

    [MenuItem("GameObject/Render Noise Texture")]
    static void RenderCubemap()
    {
        ScriptableWizard.DisplayWizard<CreateNoiseTex>(
            "Noise Texture", "Render!");
    }
    public static void GeneratePerlinNoiseMap(float scale)
    {

        string path = EditorUtility.SaveFilePanelInProject("生成柏林噪点图", "perlin_noise_texture_" + scale + "x", "png", "保存", Application.dataPath + "/Resources/Textures");
        if (!string.IsNullOrEmpty(path))
        {
            if (EditorUtility.DisplayCancelableProgressBar("生成柏林噪点图", "初始化", 0f))
            {
                EditorUtility.ClearProgressBar();
                return;
            }
            int size = 256;
            int sizeSqr = size * size;
            Texture2D texture2D = new Texture2D(size, size);
            float oX = Random.value;
            float oY = Random.value;
            for (int i = 0; i < size; i++)
            {
                for (int j = 0; j < size; j++)
                {
                    float greyScale = Mathf.PerlinNoise(oX + ((float)i) / ((float)size) * scale, oY + ((float)j) / ((float)size) * scale);
                    texture2D.SetPixel(i, j, new Color(greyScale, greyScale, greyScale));
                    if (j % 100 == 0)
                    {
                        if (EditorUtility.DisplayCancelableProgressBar("生成柏林噪点图", greyScale.ToString(), (float)(size * i + j + 1) / sizeSqr))
                        {
                            EditorUtility.ClearProgressBar();
                            return;
                        }
                    }
                }
            }
            texture2D.Apply();
            File.WriteAllBytes(path, texture2D.EncodeToPNG());
            EditorUtility.ClearProgressBar();
            AssetDatabase.ImportAsset(path.Substring(path.IndexOf("Assets")));
        }
    }
}
