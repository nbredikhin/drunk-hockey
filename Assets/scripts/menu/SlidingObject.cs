using UnityEngine;
using System.Collections;

public class SlidingObject : MonoBehaviour {

    public Vector2 targetPosition;
    public float delay;
    public float mul;

    protected float currentTime;

	void Start () {

    }

	void Update () {
        if (delay <= 0)
        {
            var currentPosition = transform.position;
            currentPosition.x += (targetPosition.x - currentPosition.x) * mul;
            currentPosition.y += (targetPosition.y - currentPosition.y) * mul;
            transform.position = currentPosition;
        }
        else
        {
            delay -= Time.deltaTime;
        }
    }
}
