using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ProceduralTextureGeneration : MonoBehaviour
{
    //����һ�����ʣ�������ʽ�ʹ�øýű������ɵĳ�������
    public Material material = null;
    //�����ó�������ʹ�õĸ��ֲ���
    #region Material properties
    //����Ĵ�С����ֵͨ����2��������
    [SerializeField]
    private int m_textureWidth = 512;
    public int textureWidth { get { return m_textureWidth; } set { m_textureWidth = value; _UpdateMaterial(); } }
    //����ı�����ɫ
    [SerializeField]
    private Color m_backgroundColor = Color.white;
    public Color backgroundColor { get { return m_backgroundColor; } set { m_backgroundColor = value; _UpdateMaterial(); } }
    //Բ�����ɫ
    [SerializeField]
    private Color m_circleColor = Color.yellow;
    public Color circleColor { get { return m_circleColor; } set { m_circleColor = value; _UpdateMaterial(); } }
    //ģ�����ӣ��������������ģ��Բ�α߽��
    [SerializeField]
    private float m_blurFactor = 2.0f;
    public float blurFactor { get { return m_blurFactor; } set { m_blurFactor = value; _UpdateMaterial(); } }
    #endregion
    //�������ɵĳ�������
    private Texture2D m_generatedTexture = null;

    // ��Start�����н�����Ӧ�ļ�飬�Եõ���Ҫʹ�øó�������Ĳ���
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
        {//ȷ��material��Ϊ��
         //����_GenerateProceduralTexture����������һ�ų�������
            m_generatedTexture = _GenerateProceduralTexture();
            //����Material.SetTexture���������ɵ�����������
            //����material����Ҫ��һ����Ϊ_MainTex����������
            material.SetTexture("_MainTex", m_generatedTexture);
        }
    }

    //��ͨ�������ɫ
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
        //��1����ʼ��һ�Ŷ�ά����
        Texture2D proceduralTexture = new Texture2D(textureWidth, textureWidth);
        //��2����ǰ����һЩ��������ʱ��Ҫ�ı���		
        float circleInterval = textureWidth / 4.0f;//����Բ��Բ֮��ļ��		
        float radius = textureWidth / 10.0f;//����Բ�İ뾶		
        float edgeBlur = 1.0f / blurFactor;//����ģ��ϵ��
                                           //��3��ʹ��һ�������Ƕ��ѭ�����������е�ÿ�����أ��������������λ���9��Բ��
        for (int w = 0; w < textureWidth; w++)
        {
            for (int h = 0; h < textureWidth; h++)
            {
                Color pixel = backgroundColor;//ʹ�ñ�����ɫ���г�ʼ��
                                              // ���λ�9��Բ
                for (int i = 0; i < 3; i++)
                {
                    for (int j = 0; j < 3; j++)
                    {
                        //���㵱ǰ�����Ƶ�Բ��Բ��λ��
                        Vector2 circleCenter = new Vector2(circleInterval * (i + 1), circleInterval * (j + 1));
                        //���㵱ǰ������Բ�ĵľ���
                        float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;
                        //ģ��Բ�ı߽�
                        Color color = _MixColor(circleColor, new Color(pixel.r, pixel.g, pixel.b, 0.0f), Mathf.SmoothStep(0f, 1.0f, dist * edgeBlur));
                        //��֮ǰ�õ�����ɫ���л��
                        pixel = _MixColor(pixel, color, color.a);
                    }
                }
                proceduralTexture.SetPixel(w, h, pixel);
            }
        }
        //��4������Texture2D.Apply������ǿ�ư�����ֵд��������
        proceduralTexture.Apply();
        return proceduralTexture;
    }
}
