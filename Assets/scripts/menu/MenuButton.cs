using UnityEngine;

public class MenuButton : MonoBehaviour
{
    public float maxAngle = 2f;
    public float rotationSpeed = 1f;
    private float initialAngle;
    private float rotationOffset;

    void Start()
    {
        initialAngle = transform.rotation.eulerAngles.z;
        rotationOffset = Random.value * Mathf.PI * 2;
    }

    void Update()
    {
        transform.rotation = Quaternion.Euler(0, 0, initialAngle + Mathf.Sin(Time.time * rotationSpeed + rotationOffset) * maxAngle);
    }
}
