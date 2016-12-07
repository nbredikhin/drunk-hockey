using UnityEngine;
using UnityEngine.SceneManagement;

public class Menu : MonoBehaviour
{

    public void SingleplayerButtonClick()
    {
        SceneManager.LoadScene("Game");
    }

    public void MultiplayerButtonClick()
    {
        SceneManager.LoadScene("Game");
    }
}
