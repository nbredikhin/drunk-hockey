using UnityEngine;

public class PlayerController : MonoBehaviour
{
    protected Vector3 spawnPosition;
    protected Vector3 spawnRotation;

    public float angularVelocity = 500f;
    public float maxVelocity     = 0.4f;

    protected const float AI_PUCK_SPEED_PANIC_TRESHOLD = 3.0f;
    public bool isAIControlled   = false;
    public float AIPanicChance   = 0.5f;
    public int AIReactionDelayMS = 100;

    public GameObject shadowPrefab;
    protected GameObject shadow;
    protected Vector3 shadowOffset = new Vector3(-0.025f, -0.02f, 0f);

    new private Rigidbody2D rigidbody;
    public bool isPlayerOne = false;

    public float joystickSensitivity = 1f;
    protected int joystickFingerID = -1;
    protected Vector2 joystickOrigin = Vector2.zero;

    protected GameMain gameMain;

    void Start()
    {
        spawnPosition = transform.position;
        spawnRotation = transform.rotation.eulerAngles;

        rigidbody = GetComponent<Rigidbody2D>();

        if (shadowPrefab)
        {
            shadow = Instantiate(shadowPrefab);
        }

        if (isAIControlled)
        {
            maxVelocity = AIDifficulty.AIPlayerVelocity;
            AIPanicChance = AIDifficulty.AIPlayerPanicChance;
            AIReactionDelayMS = AIDifficulty.AIPlayerReactionDelayMS;
        }

        gameMain = Camera.main.GetComponent<GameMain>();
        Debug.Assert(gameMain);
    }

    public void Respawn()
    {
        transform.position = spawnPosition;
        transform.rotation = Quaternion.Euler(spawnRotation);
    }

    void Update()
    {
        rigidbody.angularVelocity = angularVelocity;

        if (isAIControlled)
        {
            AIUpdate();
        }
        else
        {
            PlayerUpdate();
        }

        shadow.transform.position = rigidbody.worldCenterOfMass;
    }

#region Мультиплеер
    public void PlayerUpdate()
    {
        if (Input.touchSupported)
        {
            foreach (var touch in Input.touches)
            {
                if (( isPlayerOne && touch.position.x <= Screen.width / 2f) ||
                    (!isPlayerOne && touch.position.x  > Screen.width / 2f))
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
#endregion

    public void AIUpdate()
    {
        var puck = gameMain.GetPuck();
        GoToPointScreen(Camera.main.WorldToScreenPoint(puck.transform.position));
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
        if (shadow)
        {
            shadow.SetActive(false);
        }
    }

    public void OnEnable()
    {
        if (shadow)
        {
            shadow.SetActive(true);
        }
    }
}
