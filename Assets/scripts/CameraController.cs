using UnityEngine;

public class CameraController : MonoBehaviour
{
    public float horizontalScale = 0.04f;
    public float verticalScale = 0.01f;
    private float initialRotation;

    void Start()
    {
        initialRotation = transform.eulerAngles.z;

        var area = GameObject.Find("area");
        var areaSprite = area.GetComponent<SpriteRenderer>();
        // Выставление масштаба поля
        float sizeFitHorizontal = areaSprite.bounds.size.x *
                                  (1.0f + horizontalScale) / Camera.main.aspect;
        float sizeFitVertical = (areaSprite.bounds.size.y *
                                (1.0f + verticalScale));
        Camera.main.orthographicSize = Mathf.Max(sizeFitHorizontal,
                                                 sizeFitVertical) * 0.5f;
    }

    void Update()
    {
        transform.rotation = Quaternion.Euler(0f, 0f, initialRotation + Mathf.Sin(Time.time));
    }
}
