using System;
using UnityEngine;

public class DAQController : MonoBehaviour
{
    private DAQ_functions daq;
    private IntPtr taskHandle = IntPtr.Zero;
    private double[] trigger_wave = new double[5000];
    private double[] stimulus_wave = new double[5000];

    private void Start()
    {
        daq = FindObjectOfType<DAQ_functions>();
    }

    private void Update()
    {
        // Trigger DAQ output on any key press or mouse click
        if (Input.anyKeyDown)
        {
            // Define sample waves
            for (int i = 0; i < trigger_wave.Length; i++)
            {
                trigger_wave[i] = (i >= 5 && i <= 255) ? 5.0 : 0.0;
            }

            for (int i = 0; i < stimulus_wave.Length; i++)
            {
                stimulus_wave[i] = (i >= 2 && i <= 11) ? 3.0 : 0.0;
            }

            // Configure DAQ and store new taskHandle each time
            taskHandle = daq.ConfigureDAQ();
            Debug.Log("TaskHandle after ConfigureDAQ: " + taskHandle);

            if (taskHandle != IntPtr.Zero)
            {
                // Prepare the signal in the DAQ
                daq.PrepareSignal(taskHandle, trigger_wave, stimulus_wave);

                // Send the signal and stop/clear the task
                daq.SendAndStop(taskHandle);
            }
        }
    }
}
