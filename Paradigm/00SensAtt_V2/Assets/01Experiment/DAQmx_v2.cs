using System;
using System.Runtime.InteropServices;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class DAQmx_v2 : MonoBehaviour
{
    private const int DAQmxSuccess = 0;
    private const double sampleRate = 50000.0;
    public IntPtr taskHandle = IntPtr.Zero;

    public const int DAQmx_Val_GroupByChannel = 0;
    public const int DAQmx_Val_GroupByScanNumber = 1;
    private const int DAQmx_Val_Volts = 10348;
    public const int DAQmx_Val_Rising = 10280;
    public const int DAQmx_Val_Falling = 10171;
    public const int DAQmx_Val_FiniteSamps = 10178;
    public const int DAQmx_Val_ContSamps = 10123;
    public const int DAQmx_Val_HWTimedSinglePoint = 12522;

    private double[] trigger_wave_1 = new double[5000]; // signal 128
    private double[] trigger_wave_2 = new double[5000]; // signal 16
    private double[] stimulus_wave_1 = new double[5000]; // electric
    private double[] stimulus_wave_2 = new double[5000]; // auditory

    private double[] combinedData;
    private bool taskConfigured = false;

    public List<float> velocities = new List<float>();

    [DllImport("nicaiu.dll")]
    private static extern int DAQmxCreateTask(string taskName, out IntPtr taskHandle);

    [DllImport("nicaiu.dll")]
    private static extern int DAQmxCreateAOVoltageChan(IntPtr taskHandle, string physicalChannel, string nameToAssignToChannel, double minVal, double maxVal, int units, string customScaleName);

    [DllImport("nicaiu.dll")]
    private static extern int DAQmxCfgSampClkTiming(IntPtr taskHandle, string source, double rate, int activeEdge, int sampleMode, ulong sampsPerChan);

    [DllImport("nicaiu.dll")]
    private static extern int DAQmxWriteAnalogF64(IntPtr taskHandle, int numSampsPerChan, bool autoStart, double timeout, int dataLayout, double[] writeArray, out int sampsPerChanWritten, IntPtr reserved);

    [DllImport("nicaiu.dll")]
    private static extern int DAQmxStartTask(IntPtr taskHandle);

    [DllImport("nicaiu.dll")]
    private static extern int DAQmxStopTask(IntPtr taskHandle);

    [DllImport("nicaiu.dll")]
    private static extern int DAQmxClearTask(IntPtr taskHandle);

    // set plt to 0 otherwise triggers are fucked up 
    public PLT plt;


    public bool ConfigureDAQ()
    {
        int error = DAQmxCreateTask("", out taskHandle);
        if (error != DAQmxSuccess)
        {
            Debug.LogError("Error creating task: " + error);
            return false;
        }

        error = DAQmxCreateAOVoltageChan(taskHandle, "Dev1/ao0", "trigger_wave_1", -10.0, 10.0, DAQmx_Val_Volts, "");
        if (error != DAQmxSuccess) return LogError("Error creating channel ao0", error);

        error = DAQmxCreateAOVoltageChan(taskHandle, "Dev1/ao2", "trigger_wave_2", -10.0, 10.0, DAQmx_Val_Volts, "");
        if (error != DAQmxSuccess) return LogError("Error creating channel ao2", error);

        error = DAQmxCreateAOVoltageChan(taskHandle, "Dev1/ao1", "stimulus_wave_1", -10.0, 10.0, DAQmx_Val_Volts, "");
        if (error != DAQmxSuccess) return LogError("Error creating channel ao1", error);

        error = DAQmxCreateAOVoltageChan(taskHandle, "Dev1/ao3", "stimulus_wave_2", -10.0, 10.0, DAQmx_Val_Volts, "");
        if (error != DAQmxSuccess) return LogError("Error creating channel ao3", error);

        error = DAQmxCfgSampClkTiming(taskHandle, "", sampleRate, DAQmx_Val_Rising, DAQmx_Val_FiniteSamps, (ulong)trigger_wave_1.Length);
        if (error != DAQmxSuccess) return LogError("Error configuring sample clock timing", error);

        return true;
    }

    public bool LogError(string message, int errorCode)
    {
        Debug.LogError($"{message}. Error code: {errorCode}");
        return false;
    }

    public double[] Prepare_Data(int stim1, int stim2, float stim3, float stim4)
    {
        // this function creates already matrices of 5000 points
        for (int i = 0; i < trigger_wave_1.Length; i++)
        {
            trigger_wave_1[i] = (i >= 2 && i <= 252) ? 5.0 * stim1: 0.0;
        }

        for (int i = 0; i < trigger_wave_2.Length; i++)
        {
            trigger_wave_2[i] = (i >= 2 && i <= 252) ? 5.0 * stim2 : 0.0;
        }

        // And then the stimulus wave (to modify at each trial) will be multiplied by the correct value. 
        for (int i = 0; i < stimulus_wave_1.Length; i++)
        {
            stimulus_wave_1[i] = (i >= 2 && i <= 11) ? 1.0 * stim3 : 0.0;
            //stimulus_wave[i] = (i >= 2 && i <= 1000) ? 1.0 * stimulusMultiplier : 0.0;
        }

        // And then the stimulus wave (to modify at each trial) will be multiplied by the correct value. 
        for (int i = 0; i < stimulus_wave_2.Length; i++)
        {
            stimulus_wave_2[i] = (i >= 2 && i <= 11) ? -1.0 * stim4 : 0.0;
            //stimulus_wave[i] = (i >= 2 && i <= 1000) ? 1.0 * stimulusMultiplier : 0.0;
        }

        combinedData = new double[5000 * 4];
        for (int i = 0; i < 5000; i++)
        {
            combinedData[4 * i] = trigger_wave_1[i];
            combinedData[4 * i + 1] = trigger_wave_2[i]; 
            combinedData[4 * i + 2] = stimulus_wave_1[i];
            combinedData[4 * i + 3] = stimulus_wave_2[i]; 
        }
        return combinedData;
    }

    public bool WriteData(double[] data)
    {
        int samplesWritten;
        int error = DAQmxWriteAnalogF64(taskHandle, trigger_wave_1.Length, false, 10.0, DAQmx_Val_GroupByScanNumber, combinedData, out samplesWritten, IntPtr.Zero);

        if (error != DAQmxSuccess || samplesWritten != trigger_wave_1.Length)
        {
            return false;
        }
        else
        {
            //StartCoroutine(Start_and_Stop(taskHandle));
            return true;
        }
    }

    public void SendData(IntPtr taskHandle)
    {
        StartCoroutine(Start_and_Stop(taskHandle));
    }

    //private void InitializeWaveforms(int stimulusMultiplier)
    //{
    //    // This function simply inserts inside the trigger waves the appropriate values to trigger the EEG (5amps for 1ms)
    //    for (int i = 0; i < trigger_wave_1.Length; i++)
    //    {
    //        trigger_wave_1[i] = (i >= 2 && i <= 252) ? 5.0 : 0.0; 
    //    }
    //    for (int i = 0; i < trigger_wave_2.Length; i++)
    //    {
    //        trigger_wave_2[i] = (i >= 2 && i <= 252) ? 5.0 : 0.0;
    //    }
    //    // And then the stimulus wave (to modify at each trial) will be multiplied by the correct value. 
    //    for (int i = 0; i < stimulus_wave.Length; i++)
    //    {
    //        stimulus_wave[i] = (i >= 2 && i <= 11) ? 1.0 * stimulusMultiplier : 0.0;
    //        //stimulus_wave[i] = (i >= 2 && i <= 1000) ? 1.0 * stimulusMultiplier : 0.0;
    //    }
    //}

    //// Function to accept three stimuli and configure them
    //public double[] Combine_Data(double[] stim1, double[] stim2, double[] stim3)
    //{
    //    if (stim1.Length != 50000 || stim2.Length != 50000 || stim3.Length != 50000)
    //    {
    //        Debug.LogError("Each stimulus must be 50000 samples long.");
    //        return new double[0];
    //    }

    //    Array.Copy(stim1, trigger_wave_1, stim1.Length);
    //    Array.Copy(stim2, stimulus_wave, stim2.Length);
    //    Array.Copy(stim3, trigger_wave_2, stim3.Length);

    //    combinedData = new double[50000 * 3];
    //    for (int i = 0; i < 50000; i++)
    //    {
    //        combinedData[3 * i] = trigger_wave_1[i];
    //        combinedData[3 * i + 1] = stimulus_wave[i];
    //        combinedData[3 * i + 2] = trigger_wave_2[i];
    //    }
    //    return combinedData; 
    //}

    /// <summary>
    /// The script will start from here. Initially configures the DAQ (to get rid of later). 
    /// Then it sends input on click
    /// </summary>
    private void Start()
    {
        taskConfigured = ConfigureDAQ();
        plt = this.GetComponent<PLT>();
        plt.PLTsend(0);
    }

    private void Update()
    {
        //if (Input.anyKeyDown && taskConfigured && taskHandle != IntPtr.Zero)
        //{
        //    // Set plt to zero
        //    plt.PLTsend(0);

        //    //Prepare the data first
        //    double[] combinedData = Prepare_Data(0, 0, 2, 2);

        //    bool dataWritten = WriteData(combinedData);

        //    if (dataWritten == true)
        //    {
        //        SendData(taskHandle);
        //    }

        //    //int samplesWritten;
        //    //int error = DAQmxWriteAnalogF64(taskHandle, trigger_wave_1.Length, false, 10.0, DAQmx_Val_GroupByScanNumber, combinedData, out samplesWritten, IntPtr.Zero);

        //    //if (error != DAQmxSuccess || samplesWritten != trigger_wave_1.Length)
        //    //{
        //    //    Debug.LogError("Error writing data to buffer: " + error);
        //    //}
        //    //else
        //    //{
        //    //    StartCoroutine(Start_and_Stop(taskHandle));
        //    //}
        //}
    }

    private IEnumerator Start_and_Stop(IntPtr taskHandle)
    {
        int error = DAQmxStartTask(taskHandle);
        if (error == DAQmxSuccess)
        {
            Debug.Log("DAQ task started on input trigger.");
        }
        else
        {
            Debug.LogError("Error starting DAQ task: " + error);
        }

        yield return new WaitForSeconds(0.11f);

        error = DAQmxStopTask(taskHandle);
        if (error != DAQmxSuccess)
        {
            Debug.LogError("Error stopping DAQ task: " + error);
        }
    }

    private void OnApplicationQuit()
    {
        if (taskHandle != IntPtr.Zero)
        {
            DAQmxClearTask(taskHandle);
        }
    }
}
