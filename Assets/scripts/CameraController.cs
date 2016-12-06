using UnityEngine;
using System.Collections;

public class CameraController : MonoBehaviour
{
    private float originalRotation;

    void Start()
    {
        originalRotation = transform.eulerAngles.z;

        var area = GameObject.Find("area");
        var areaSprite = area.GetComponent<SpriteRenderer>();
        float sizeFitHorizontal = areaSprite.bounds.size.x * 1.04f * Screen.height / Screen.width * 0.5f;
        float sizeFitVertical = (areaSprite.bounds.size.y * 1.01f) / 2f;
        Camera.main.orthographicSize = Mathf.Max(sizeFitHorizontal, sizeFitVertical);
    }


    void Update()
    {
        transform.rotation = Quaternion.Euler(0f, 0f, originalRotation + Mathf.Sin(Time.time));
    }
}
