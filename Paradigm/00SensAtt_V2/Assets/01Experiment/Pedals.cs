using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pedals : MonoBehaviour
{
    public Color Opaque;
    public Color Opaque_darker;
    public Color Opaque_darker_darker;

    public GameObject PedalL;
    public GameObject PedalR; 

    // Start is called before the first frame update
    void Start()
    {
        PedalL.SetActive(true); 
        PedalR.SetActive(true);
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.UpArrow))
        {
            PedalR.GetComponent<Renderer>().material.color = Opaque_darker_darker;
        }
        if (Input.GetKeyUp(KeyCode.UpArrow))
        {
            PedalR.GetComponent<Renderer>().material.color = Opaque_darker;
        }
        if (Input.GetKeyDown(KeyCode.DownArrow))
        {
            PedalL.GetComponent<Renderer>().material.color = Opaque_darker_darker;
        }
        if (Input.GetKeyUp(KeyCode.DownArrow))
        {
            PedalL.GetComponent<Renderer>().material.color = Opaque_darker;
        }

    }
}
