using UnityEngine;

public class GameMain : MonoBehaviour
{
    public static bool isMultiplayerGame = false;

    protected GameObject puck;
    protected GameObject playerOne;
    protected GameObject playerTwo;
    protected ResultsScreen resultsScreen;
    protected ScoreManager scoreManager;

    protected int playerOneScore = 0;
    protected int playerTwoScore = 0;

    public int respawnTimeMS = 3000;
    protected Delay respawnDelay;

    public int scoreToWin = 5;

    void Start()
    {
        playerOne = GameObject.Find("playerOne");
        playerTwo = GameObject.Find("playerTwo");

        puck = GameObject.Find("puck");

        playerTwo.GetComponent<PlayerController>().isAIControlled =
                                                            !isMultiplayerGame;

        scoreManager = GameObject.Find("score").GetComponent<ScoreManager>();
        scoreManager.gameObject.SetActive(false);

        resultsScreen = GameObject.Find("Canvas").GetComponent<ResultsScreen>();
        resultsScreen.gameObject.SetActive(false);

        respawnDelay = DelayManager.CreateDelay(respawnTimeMS);
        Debug.Assert(respawnDelay != null);
    }

    void Update()
    {
        if (respawnDelay.IsCompleted)
        {
            Respawn();
            respawnDelay.Active = false;
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
        resultsScreen.gameObject.SetActive(false);
    }

    public void PlayAgain()
    {
        playerOneScore = 0;
        playerTwoScore = 0;
        Respawn();
    }

    public void OnPlayerWon(bool isPlayerOne)
    {
        // Отладочное сообщение о том, какой игрок выиграл
        Debug.Log(string.Format("{0} player won!", isPlayerOne ? "Red" : "Blue"));

        scoreManager.gameObject.SetActive(true);
        scoreManager.ShowScore(playerOneScore, playerTwoScore);
        scoreManager.MoveScoreToTop();

        resultsScreen.gameObject.SetActive(true);
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
        respawnDelay.Active = true;
    }

    public GameObject GetPuck()
    {
        Debug.Assert(puck);

        return puck;
    }
}
