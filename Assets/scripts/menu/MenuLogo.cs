using UnityEngine;

public class MenuLogo : MonoBehaviour
{
	public float maxSlideDistance = 1f;
	public float slideSpeed = 1.5f;

	private RectTransform rectTransform;
	private Vector3 initialPosition;

    void Start()
    {
		rectTransform = GetComponent<RectTransform>();
		initialPosition = rectTransform.position;
    }

    void Update()
    {
		rectTransform.position = initialPosition + new Vector3(0, Mathf.Sin(Time.time * slideSpeed) * maxSlideDistance, 0);
    }
}
