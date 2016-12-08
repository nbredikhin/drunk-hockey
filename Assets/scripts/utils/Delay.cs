using UnityEngine;
using UnityEditor;

public class Delay
{
    private const int MSEC_IN_SEC = 1000;

    private int  delayMS;
    private bool active;
    private int  currentDelayMS;
    private bool toDelete;

    public int DelayMS
    {
        get { return delayMS; }
        set
        {
            active = false;
            delayMS = value;
            Reset();
            active = true;
        }
    }

    public bool Active
    {
        get { return active; }
        set { active = value; }
    }

    public bool IsCompleted
    {
        get { return (currentDelayMS >= delayMS) && active; }
    }

    public bool WaitingDestroy
    {
        get { return toDelete; }
    }

    public Delay(int delayMS, bool startRightNow = false)
    {
        this.delayMS = delayMS;
        this.active  = startRightNow;
    }

    public void Reset()
    {
        currentDelayMS = 0;
    }

    public void UpdateDelay()
    {
        if (active)
        {
            currentDelayMS += (int)Mathf.Floor(Time.deltaTime * MSEC_IN_SEC);
        }
    }

    public void Destroy()
    {
        active = false;
        toDelete = true;
        currentDelayMS = delayMS = 0;
    }
}