using UnityEngine;

public class ScoreManager : MonoBehaviour
{
    public Sprite[] numbersSprites;

    public SpriteRenderer firstNumber;
    public SpriteRenderer secondNumber;
    public SpriteRenderer colon;

    private Color color;
    private float colorLerpValue;

    private Vector3 initialPosition;
    private Vector3 targetPosition;
    private float movementProgress = 0f;
    public float movementSpeed = 0.2f;
    public float moveToTopOffset = 0.25f;

    void Start()
    {
        color = new Color(0f, 0f, 0f, 0f);
        colorLerpValue = 0f;
        initialPosition = transform.position;
    }

    public void ShowScore(int playerOneScore, int playerTwoScore)
    {
        colorLerpValue = 0f;

        playerOneScore = Mathf.Clamp(playerOneScore, 0, 5);
        playerTwoScore = Mathf.Clamp(playerTwoScore, 0, 5);

        firstNumber.sprite = numbersSprites[playerOneScore];
        secondNumber.sprite = numbersSprites[playerTwoScore];

        transform.position = initialPosition;
    }

    // Плавно перемещает очки в верхнюю часть экрана
    public void MoveScoreToTop()
    {
        movementProgress = 0f;
        targetPosition = initialPosition + new Vector3(0f, moveToTopOffset, 0f);
    }

    void Update()
    {
        colorLerpValue = colorLerpValue + Time.deltaTime * 1f;
        color = Color.Lerp(new Color(1f, 1f, 1f, 0f), Color.white, colorLerpValue);
        firstNumber.color = secondNumber.color = colon.color = color;

        movementProgress = Mathf.Min(1f, movementProgress + Time.deltaTime * movementSpeed);
        transform.position = initialPosition + (targetPosition - initialPosition) * movementProgress;
    }
}
