using UnityEngine;

public class GameMain : MonoBehaviour
{
    protected GameObject puck;
    protected GameObject playerOne;
    protected GameObject playerTwo;
    protected ScoreManager scoreManager;

    protected int playerOneScore = 0;
    protected int playerTwoScore = 0;

    public float respawnTime = 3f;
    protected float respawnDelay = 0f;

    public int scoreToWin = 5;

    void Start()
    {
        playerOne = GameObject.Find("playerOne");
        playerTwo = GameObject.Find("playerTwo");

        puck = GameObject.Find("puck");
        
        scoreManager = GameObject.Find("score").GetComponent<ScoreManager>();
        scoreManager.gameObject.SetActive(false);
    }

    void Update()
    {
        if (respawnDelay > 0)
        {
            respawnDelay -= Time.deltaTime;
            if (respawnDelay <= 0)
            {
                Respawn();
            }
        }
    }

    void SetPlayersActive(bool isActive)
    {
        Debug.Assert(playerOne && playerTwo);
        
        playerOne.SetActive(isActive);
        playerTwo.SetActive(isActive);
    }

    public void Respawn()
    {
        // Респавн игроков
        SetPlayersActive(true);
        playerOne.SendMessage("Respawn");
        playerTwo.SendMessage("Respawn");
        // Респавн шайбы
        puck.SetActive(true);
        puck.transform.position = Vector2.zero;
        puck.transform.rotation = Quaternion.Euler(Vector3.zero);
        // Скрыть счёт
        scoreManager.gameObject.SetActive(false);
    }

    public void OnPlayerWon(bool isPlayerOne)
    {
        // Отладочное сообщение о том, какой игрок выиграл
        Debug.Log(string.Format("{0} player won!", isPlayerOne ? "Red" : "Blue"));
    }

    public void OnGoal(bool isPlayerOne)
    {
        // isPlayerOne -- это игрок, в чьи ворота забили шайбу
        if (isPlayerOne)
        {
            playerTwoScore++;
        }
        else
        {
            playerOneScore++;
        }

        // Скрыть игроков и шайбу
        SetPlayersActive(false);
        puck.SetActive(false);

        // Проверить победу
        bool isPlayerOneWon = playerOneScore >= scoreToWin;
        bool isPlayerTwoWon = playerTwoScore >= scoreToWin;
        if (isPlayerOneWon || isPlayerTwoWon)
        {
            OnPlayerWon(isPlayerOneWon);
            return;
        }

        // Если никто не победил - вывод счёта
        scoreManager.gameObject.SetActive(true);
        scoreManager.ShowScore(playerOneScore, playerTwoScore);

        respawnDelay = respawnTime;
    }
}
