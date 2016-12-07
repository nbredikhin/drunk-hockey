using UnityEngine;
using UnityEngine.SceneManagement;

public class MenuButtons : MonoBehaviour {

    public void StartButtonClick()
    {
        SceneManager.LoadScene("Game");
    }
}
