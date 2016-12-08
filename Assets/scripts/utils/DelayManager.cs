using System.Collections.Generic;
using UnityEngine;

public class DelayManager : MonoBehaviour
{
    private static DelayManager instance;     // Реализация менеджера таймеров -
                                              // это паттерн синглтон, поэтому
                                              // в классе статическим полем мы
                                              // делаем собственно объект этого
                                              // класса
    private List<Delay> delays;               // Список всех таймеров в текущей
                                              // сцене

    // Создает новый объект с менеджером таймеров
    private static GameObject ConstructPrefab()
    {
        var gameObject = new GameObject();
        gameObject.AddComponent<DelayManager>();

        return gameObject;
    }

    public static DelayManager Instance
    {
        // Логика такова -- если текущий Instance не задан, мы ищем такой объект
        // на сцене. Если не нашли -- создаем новый.
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

    // Добавляет новый таймер в менеджер таймеров
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
        foreach (var delay in delays)
        {
            delay.Destroy();
        }
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
