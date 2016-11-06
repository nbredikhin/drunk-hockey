using UnityEngine;
using System.Collections;

public class GateController : MonoBehaviour
{
    public bool isPlayerOne = false;

    private Vector3 spawnPosition;
    private float spawnAngle;
    new private Rigidbody2D rigidbody;

    void Start()
    {
        spawnPosition = transform.position;
        spawnAngle = transform.localEulerAngles.z;
        rigidbody = GetComponent<Rigidbody2D>();
    }

    void Update()
    {
        rigidbody.MovePosition(spawnPosition);
        rigidbody.velocity = Vector2.zero;
        rigidbody.MoveRotation(spawnAngle);
    }

    public void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.name == "puck")
        {
            Camera.main.SendMessage("OnGoal", isPlayerOne);
        }
    }
}
