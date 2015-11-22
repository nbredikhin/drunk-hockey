using UnityEngine;
using System.Collections;

public class GameMain : MonoBehaviour {
    protected GameObject puck;
    protected GameObject player1;
    protected GameObject player2;
    protected ScoreManager scoreManager;

    protected int score1 = 0;
    protected int score2 = 0;

    public float respawnTime = 3f;
    protected float respawnDelay = 0f;

    void Start() { 
        player1 = GameObject.Find("player1");
        player2 = GameObject.Find("player2");
        puck = GameObject.Find("puck");
        scoreManager = GameObject.Find("score").GetComponent<ScoreManager>();
        scoreManager.gameObject.SetActive(false);
    }

	void Update () {
	    if (respawnDelay > 0)
        {
            respawnDelay -= Time.deltaTime;
            if (respawnDelay <= 0)
            {
                Respawn();
            }
        }
	}
    
    public void Respawn()
    {
        // Игроки
        player1.SetActive(true);
        player2.SetActive(true);
        player1.SendMessage("Respawn");
        player2.SendMessage("Respawn");
        // Шайба
        puck.SetActive(true);
        puck.transform.position = Vector2.zero;
        puck.transform.rotation = Quaternion.Euler(Vector3.zero);
        // Скрыть счёт
        scoreManager.gameObject.SetActive(false);
    }

    public void OnPlayerWon(bool isPlayerOne)
    {

    }

    public void OnGoal(bool isPlayerOne)
    {
        if (isPlayerOne)
        {
            score2++;
        }
        else
        {
            score1++;
        }

        // Скрыть игроков и шайбу
        puck.SetActive(false);
        player1.SetActive(false);
        player2.SetActive(false);

        // Проверить победу
        if (score1 >= 5)
        {
            OnPlayerWon(true);
            return; 
        }
        else if (score2 >= 5)
        {
            OnPlayerWon(false);
            return;
        }
        
        // Если никто не победил - вывод счёта
        scoreManager.gameObject.SetActive(true);
        scoreManager.ShowScore(score1, score2);

        respawnDelay = respawnTime;
    }
}
