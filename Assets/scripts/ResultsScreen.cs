using UnityEngine;

public class ResultsScreen : MonoBehaviour
{
    private float animationProgress = 0f;
    // Длительность анимации в секундах
    public float animationTime = 6f;
    // Время, через которое появляется кнопка "Play again"
    public float playAgainFadeDelay = 0.5f;

    public CanvasGroup playAgainButtonGroup;

    void Start()
    {
        animationProgress = 0f;
    }

    void Update()
    {
        animationProgress = Mathf.Min(1f, animationProgress + Time.deltaTime / animationTime);
        playAgainButtonGroup.alpha = (animationProgress - playAgainFadeDelay) / (1f - playAgainFadeDelay);
    }
}
