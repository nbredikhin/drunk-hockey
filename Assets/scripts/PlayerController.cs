using UnityEngine;

public class PlayerController : MonoBehaviour
{
    protected Vector3 spawnPosition;
    protected Vector3 spawnRotation;

    public float angularVelocity = 500f;
    public float maxVelocity = 0.4f;

    protected const float AI_PUCK_SPEED_PANIC_TRESHOLD = 2f;
    protected Delay AIReactionDelay;
    public bool isAIControlled = false;
    public float AIPanicChance = 0.5f;

    public GameObject shadowPrefab;
    protected GameObject shadow;
    protected Vector3 shadowOffset = new Vector3(-0.025f, -0.02f, 0f);

    new private Rigidbody2D rigidbody;
    public bool isPlayerOne = false;

    public float joystickSensitivity = 1f;
    protected int joystickFingerID = -1;
    protected Vector2 joystickOrigin = Vector2.zero;

    protected GameMain gameMain;
    protected Delay timer;

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
            AIReactionDelay = DelayManager.CreateDelay(
                                    AIDifficulty.AIPlayerReactionDelayMS,
                                    true);
            Debug.Assert(AIReactionDelay != null);
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
            if (AIReactionDelay.IsCompleted)
            {
                AIUpdate();
                AIReactionDelay.Reset();
            }
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
                if ((isPlayerOne && touch.position.x <= Screen.width / 2f) ||
                    (!isPlayerOne && touch.position.x > Screen.width / 2f))
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
        var puckVelocity = puck.GetComponent<Rigidbody2D>().velocity;

        Debug.Assert(puck);

        var posToMove = puck.transform.position;
        if (puckVelocity.magnitude >= AI_PUCK_SPEED_PANIC_TRESHOLD)
        {
            bool needPanic = Random.Range(0.0f, 1.0f) < AIPanicChance;
            if (needPanic)
            {
                Debug.Log("AI Player: OMG PANIC PANIC!!!");
                posToMove = Random.insideUnitCircle *
                                Camera.main.orthographicSize;
            }
        }
        GoToPointScreen(Camera.main.WorldToScreenPoint(posToMove));
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
        if (isAIControlled)
        {
            AIReactionDelay.Active = false;
        }
    }

    public void OnEnable()
    {
        if (shadow)
        {
            shadow.SetActive(true);
        }
        if (isAIControlled)
        {
            AIReactionDelay.Reset();
            AIReactionDelay.Active = true;
        }
    }
}
