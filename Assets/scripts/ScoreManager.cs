using UnityEngine;

public class ScoreManager : MonoBehaviour
{
    public Sprite[] numbersSprites;

    public SpriteRenderer firstNumber;
    public SpriteRenderer secondNumber;
    public SpriteRenderer colon;

    private Color color;
    private float colorLerpValue;

    void Start()
    {
        color = new Color(0f, 0f, 0f, 0f);
        colorLerpValue = 0f;
    }

    public void ShowScore(int playerOneScore, int playerTwoScore)
    {
        colorLerpValue = 0f;

        playerOneScore = Mathf.Clamp(playerOneScore, 0, 5);
        playerTwoScore = Mathf.Clamp(playerTwoScore, 0, 5);
        
        firstNumber.sprite = numbersSprites[playerOneScore];
        secondNumber.sprite = numbersSprites[playerTwoScore];
    }

    void Update()
    {
        colorLerpValue = colorLerpValue + Time.deltaTime * 1f;
        color = Color.Lerp(new Color(1f, 1f, 1f, 0f), Color.white, colorLerpValue);
        firstNumber.color = secondNumber.color = colon.color = color;
    }
}
