using UnityEngine;
using System.Collections;

public class ScoreManager : MonoBehaviour
{
    public Sprite[] numbersSprites;
    public SpriteRenderer number1;
    public SpriteRenderer number2;
    public SpriteRenderer colon;
    private Color color;
    private float colorLerpValue;

    void Start()
    {
        color = new Color(0f, 0f, 0f, 0f);
        colorLerpValue = 0f;
    }

    public void ShowScore(int score1, int score2)
    {
        colorLerpValue = 0f;

        score1 = Mathf.Clamp(score1, 0, 5);
        score2 = Mathf.Clamp(score2, 0, 5);
        number1.sprite = numbersSprites[score1];
        number2.sprite = numbersSprites[score2];
    }

    void Update()
    {
        colorLerpValue = colorLerpValue + Time.deltaTime * 1f;
        color = Color.Lerp(new Color(1f, 1f, 1f, 0f), Color.white, colorLerpValue);
        number1.color = number2.color = colon.color = color;
    }
}
