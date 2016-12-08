using UnityEngine;
using UnityEngine.SceneManagement;

public class Menu : MonoBehaviour
{
    public void SingleplayerButtonClick()
    {
        GameMain.isMultiplayerGame = false;
        SceneManager.LoadScene("Game");
    }

    public void MultiplayerButtonClick()
    {
        GameMain.isMultiplayerGame = true;
        SceneManager.LoadScene("Game");
    }
}
