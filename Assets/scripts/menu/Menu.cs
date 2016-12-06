using UnityEngine;
using UnityEngine.SceneManagement;

public class Menu : MonoBehaviour
{

    void SingleplayerButtonClick()
    {
        SceneManager.LoadScene("Game");
    }

    void MultiplayerButtonClick()
    {
        SceneManager.LoadScene("Game");
    }

    void SettingsButtonClick()
    {

    }
}
