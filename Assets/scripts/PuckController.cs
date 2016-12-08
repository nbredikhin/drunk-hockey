using UnityEngine;

public class PuckController : MonoBehaviour
{
    // Сила столкновения, при котором начинает трястись камера
    public float cameraShakeCollision = 4f;

    private CameraController cameraController;

    void Start()
    {
        cameraController = GameObject.Find("Main Camera").GetComponent<CameraController>();
    }

    void OnCollisionEnter2D(Collision2D collision)
    {
        if (collision.relativeVelocity.magnitude > cameraShakeCollision)
        {
            cameraController.Shake(0.03f);
        }
    }
}
