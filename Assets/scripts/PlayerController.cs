using UnityEngine;
using System.Collections;

public class PlayerController : MonoBehaviour
{
    protected Vector3 spawnPosition;
    protected Vector3 spawnRotation;

    public float angularVelocity = 500f;
    public float maxVelocity = 0.4f;

    public GameObject shadowPrefab;
    protected GameObject shadow;
    protected Vector3 shadowOffset = new Vector3(-0.025f, -0.02f, 0f);

    new private Rigidbody2D rigidbody;
    public bool isPlayerOne = false;

    protected int joystickFingerID = -1;
    protected Vector2 joystickOrigin = Vector2.zero;
    public float joystickSensitivity = 1f;


    void Start()
    {
        spawnPosition = transform.position;
        spawnRotation = transform.rotation.eulerAngles;

        rigidbody = GetComponent<Rigidbody2D>();

        if (shadowPrefab)
        {
            shadow = Instantiate(shadowPrefab);
        }
    }

    public void Respawn()
    {
        transform.position = spawnPosition;
        transform.rotation = Quaternion.Euler(spawnRotation);
    }

    void Update()
    {
        rigidbody.angularVelocity = angularVelocity;

        if (Input.touchSupported)
        {
            foreach (var touch in Input.touches)
            {
                if (isPlayerOne && touch.position.x <= Screen.width / 2f || !isPlayerOne && touch.position.x >= Screen.width / 2f)
                {
                    UpdateJoystickTouch(touch);
                }
            }
        }
        else
        {
            if (Input.GetMouseButton(0))
            {
                GoToPointScreen(Input.mousePosition);
            }
        }

        shadow.transform.position = rigidbody.worldCenterOfMass;
    }

    public void UpdateJoystickTouch(Touch touch)
    {
        if (joystickFingerID == -1)
        {
            joystickFingerID = touch.fingerId;
            joystickOrigin = touch.position;
        }
        else if (touch.fingerId == joystickFingerID)
        {
            if (touch.phase == TouchPhase.Ended || touch.phase == TouchPhase.Canceled)
            {
                joystickFingerID = -1;
                return;
            }
            else
            {
                SetPlayerVelocity((touch.position - joystickOrigin) * joystickSensitivity);
            }
        }
    }

    public void SetPlayerVelocity(Vector2 velocity)
    {
        rigidbody.velocity = velocity;
        if (rigidbody.velocity.magnitude > maxVelocity)
        {
            rigidbody.velocity = rigidbody.velocity.normalized * maxVelocity;
        }
    }

    public void GoToPointScreen(Vector2 point)
    {
        SetPlayerVelocity((Camera.main.ScreenToWorldPoint(point) - transform.position) * 5f);
    }

    public void OnDisable()
    {
        shadow.SetActive(false);
    }

    public void OnEnable()
    {
        if (shadow)
        {
            shadow.SetActive(true);
        }
    }
}
