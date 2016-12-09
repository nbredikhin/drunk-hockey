using UnityEngine;

public class Delay
{
    private const int MSEC_IN_SEC = 1000;

    private int  delayMS;          // Общее время таймера
    private bool active;           // Флаг активности таймера
    private int  currentDelayMS;   // Текущее время таймера
    private bool toDelete;         // Флаг, говорящий об удалении таймера

    public int DelayMS
    {
        get { return delayMS; }
        set
        {
            // Для того, чтобы поставить новое значение времени, мы должны
            // остановить и сбросить таймер, и лишь после выставления нового
            // значения запустить его по-новой
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
        // Мы игнориуем завершение таймера, если он не активен
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