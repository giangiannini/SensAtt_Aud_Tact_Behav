using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Runtime.InteropServices;


public class DAQ_functions1 : MonoBehaviour
{
    private const int DAQmxSuccess = 0;
    public const int DAQmx_Val_GroupByChannel = 10280;
    public const int DAQmx_Val_Volts = 10348;
    public const int DAQmx_Val_FiniteSamps = 10178;

    [DllImport("nicaiu.dll")]
    private static extern int DAQmxCreateTask(string taskName, out IntPtr taskHandle);

    [DllImport("nicaiu.dll")]
    private static extern int DAQmxCreateAOVoltageChan(IntPtr taskHandle, string physicalChannel, string nameToAssignToChannel,
        double minVal, double maxVal, int units);

    [DllImport("nicaiu.dll")]
    private static extern int DAQmxCfgSampClkTiming(IntPtr taskHandle, string source, double rate,
        int activeEdge, int sampleMode, ulong sampsPerChan);

    [DllImport("nicaiu.dll")]
    private static extern int DAQmxWriteAnalogF64(IntPtr taskHandle, int numSampsPerChan, bool autoStart,
        double timeout, int dataLayout, double[] writeArray, out int sampsPerChanWritten, IntPtr reserved);

    [DllImport("nicaiu.dll")]
    private static extern int DAQmxStartTask(IntPtr taskHandle);

    [DllImport("nicaiu.dll")]
    private static extern int DAQmxStopTask(IntPtr taskHandle);

    [DllImport("nicaiu.dll")]
    private static extern int DAQmxClearTask(IntPtr taskHandle);

    private IntPtr taskHandle = IntPtr.Zero;
    private const double sampleRate = 5000.0;

    // ConfigureDAQ now accepts data arrays for each channel and returns the task handle
    public IntPtr ConfigureDAQ()
    {
        int error = DAQmxCreateTask("", out taskHandle);
        if (error != DAQmxSuccess)
        {
            Debug.LogError("Error creating task: " + error);
            return IntPtr.Zero;
        }

        error = DAQmxCreateAOVoltageChan(taskHandle, "Dev1/ao0", "trigger_wave", 0, 10.0, DAQmx_Val_Volts);
        if (error != DAQmxSuccess)
        {
            Debug.LogError("Error creating channel ao0: " + error);
            return IntPtr.Zero;
        }

        error = DAQmxCreateAOVoltageChan(taskHandle, "Dev1/ao1", "stimulus_wave", 0, 10.0, DAQmx_Val_Volts);
        if (error != DAQmxSuccess)
        {
            Debug.LogError("Error creating channel ao1: " + error);
            return IntPtr.Zero;
        }

        error = DAQmxCfgSampClkTiming(taskHandle, "", sampleRate, DAQmx_Val_GroupByChannel, DAQmx_Val_FiniteSamps, (ulong)5000);
        if (error != DAQmxSuccess)
        {
            Debug.LogError("Error configuring sample clock timing: " + error);
            return IntPtr.Zero;
        }

        return taskHandle;
    }

    public void PrepareSignal(IntPtr taskHandle, double[] triggerWave, double[] stimulusWave)
    {
        // Interleave data for both channels into combinedData
        double[] combinedData = new double[triggerWave.Length * 2];
        for (int i = 0; i < triggerWave.Length; i++)
        {
            combinedData[2 * i] = triggerWave[i];
            combinedData[2 * i + 1] = stimulusWave[i];
        }

        // Write the combined signal data to the buffer, without auto-starting
        int samplesWritten;
        int error = DAQmxWriteAnalogF64(taskHandle, triggerWave.Length, false, 10.0, DAQmx_Val_GroupByChannel, combinedData, out samplesWritten, IntPtr.Zero);
        if (error != DAQmxSuccess || samplesWritten != triggerWave.Length)
        {
            Debug.LogError("Error writing data to buffer: " + error + ". Samples written: " + samplesWritten);
            //return IntPtr.Zero;
        }
    }


    // StartTask now only starts the task using the provided taskHandle
    public bool StartTask(IntPtr taskHandle)
    {
        int error = DAQmxStartTask(taskHandle);
        if (error == DAQmxSuccess)
        {
            Debug.Log("DAQ task started successfully.");
            return true;
        }
        else
        {
            Debug.LogError("Error starting DAQ task: " + error);
            return false;
        }
    }

    // Stop and clear task for cleanup
    public void StopAndClearTask(IntPtr taskHandle)
    {
        if (taskHandle != IntPtr.Zero)
        {
            DAQmxStopTask(taskHandle);
            DAQmxClearTask(taskHandle);
            taskHandle = IntPtr.Zero;
            Debug.Log("DAQ task stopped and cleared.");
        }
    }
}
