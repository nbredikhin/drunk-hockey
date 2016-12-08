using System.Collections.Generic;
using UnityEngine;

public class DelayManager : MonoBehaviour
{
    protected static DelayManager instance;

    public List<Delay> delays;

    private static GameObject ConstructPrefab()
    {
        var gameObject = new GameObject();
        gameObject.AddComponent<DelayManager>();

        return gameObject;
    }

    public static DelayManager Instance
    {
        get
        {
            if (instance == null)
            {
                instance = FindObjectOfType<DelayManager>();
                if (instance == null)
                {
                    var singleton = ConstructPrefab();
                    instance = singleton.GetComponent<DelayManager>();

                    singleton.name = "(singleton)" + typeof(DelayManager);
                }
            }
            return instance;
        }
    }

    public static Delay CreateDelay(int delayMS, bool startRightNow = false)
    {
        return Instance.CreateDelayInternal(delayMS, startRightNow);
    }

    void Awake()
    {
        delays = new List<Delay>();
    }

    void Update()
    {
        foreach (var currentDelay in delays)
        {
            currentDelay.UpdateDelay();
        }
        delays.RemoveAll(x => x.WaitingDestroy);
    }

    void OnDestroy()
    {
        delays.Clear();
    }

    private Delay CreateDelayInternal(int delayMS, bool startRightNow = false)
    {
        var newDelay = new Delay(delayMS, startRightNow);
        Debug.Assert(delays != null);
        delays.Add(newDelay);
        return newDelay;
    }
}
