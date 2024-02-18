using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ProceduralTextureGeneration : MonoBehaviour
{
    //声明一个材质，这个材质将使用该脚本中生成的程序纹理
    public Material material = null;
    //声明该程序纹理使用的各种参数
    #region Material properties
    //纹理的大小，数值通常是2的整数幂
    [SerializeField]
    private int m_textureWidth = 512;
    public int textureWidth { get { return m_textureWidth; } set { m_textureWidth = value; _UpdateMaterial(); } }
    //纹理的背景颜色
    [SerializeField]
    private Color m_backgroundColor = Color.white;
    public Color backgroundColor { get { return m_backgroundColor; } set { m_backgroundColor = value; _UpdateMaterial(); } }
    //圆点的颜色
    [SerializeField]
    private Color m_circleColor = Color.yellow;
    public Color circleColor { get { return m_circleColor; } set { m_circleColor = value; _UpdateMaterial(); } }
    //模糊因子，这个参数是用来模糊圆形边界的
    [SerializeField]
    private float m_blurFactor = 2.0f;
    public float blurFactor { get { return m_blurFactor; } set { m_blurFactor = value; _UpdateMaterial(); } }
    #endregion
    //保存生成的程序纹理
    private Texture2D m_generatedTexture = null;

    // 在Start函数中进行相应的检查，以得到需要使用该程序纹理的材质
    void Start()
    {
        if (material == null)
        {
            Renderer renderer = gameObject.GetComponent<Renderer>();
            if (renderer == null)
            {
                Debug.LogWarning("Cannot find a renderer.");
                return;
            }
            material = renderer.sharedMaterial;
        }
        _UpdateMaterial();
    }

    private void _UpdateMaterial()
    {
        if (material != null)
        {//确保material不为空
         //调用_GenerateProceduralTexture函数来生成一张程序纹理
            m_generatedTexture = _GenerateProceduralTexture();
            //利用Material.SetTexture函数把生成的纹理赋给材质
            //材质material中需要有一个名为_MainTex的纹理属性
            material.SetTexture("_MainTex", m_generatedTexture);
        }
    }

    //按通道混合颜色
    private Color _MixColor(Color color0, Color color1, float mixFactor)
    {
        Color mixColor = Color.white;
        mixColor.r = Mathf.Lerp(color0.r, color1.r, mixFactor);
        mixColor.g = Mathf.Lerp(color0.g, color1.g, mixFactor);
        mixColor.b = Mathf.Lerp(color0.b, color1.b, mixFactor);
        mixColor.a = Mathf.Lerp(color0.a, color1.a, mixFactor);
        return mixColor;
    }

    private Texture2D _GenerateProceduralTexture()
    {
        //【1】初始化一张二维纹理
        Texture2D proceduralTexture = new Texture2D(textureWidth, textureWidth);
        //【2】提前计算一些生成纹理时需要的变量		
        float circleInterval = textureWidth / 4.0f;//定义圆和圆之间的间距		
        float radius = textureWidth / 10.0f;//定义圆的半径		
        float edgeBlur = 1.0f / blurFactor;//定义模糊系数
                                           //【3】使用一个两层的嵌套循环遍历纹理中的每个像素，并在纹理上依次绘制9个圆形
        for (int w = 0; w < textureWidth; w++)
        {
            for (int h = 0; h < textureWidth; h++)
            {
                Color pixel = backgroundColor;//使用背景颜色进行初始化
                                              // 依次画9个圆
                for (int i = 0; i < 3; i++)
                {
                    for (int j = 0; j < 3; j++)
                    {
                        //计算当前所绘制的圆的圆心位置
                        Vector2 circleCenter = new Vector2(circleInterval * (i + 1), circleInterval * (j + 1));
                        //计算当前像素与圆心的距离
                        float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;
                        //模糊圆的边界
                        Color color = _MixColor(circleColor, new Color(pixel.r, pixel.g, pixel.b, 0.0f), Mathf.SmoothStep(0f, 1.0f, dist * edgeBlur));
                        //与之前得到的颜色进行混合
                        pixel = _MixColor(pixel, color, color.a);
                    }
                }
                proceduralTexture.SetPixel(w, h, pixel);
            }
        }
        //【4】调用Texture2D.Apply函数来强制把像素值写入纹理中
        proceduralTexture.Apply();
        return proceduralTexture;
    }
}
