using System;
using System.Runtime.InteropServices;
using UnityEngine;

public class DAQ_functions : MonoBehaviour
{
    private const int DAQmxSuccess = 0;
    public const int DAQmx_Val_GroupByScanNumber = 1;
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
    private static extern int DAQmxCfgOutputBuffer(IntPtr taskHandle, uint numSampsPerChan);

    [DllImport("nicaiu.dll")]
    private static extern int DAQmxWriteAnalogF64(IntPtr taskHandle, int numSampsPerChan, bool autoStart,
        double timeout, int dataLayout, double[] writeArray, out int sampsPerChanWritten, IntPtr reserved);

    [DllImport("nicaiu.dll")]
    private static extern int DAQmxStartTask(IntPtr taskHandle);

    [DllImport("nicaiu.dll")]
    private static extern int DAQmxStopTask(IntPtr taskHandle);

    [DllImport("nicaiu.dll")]
    private static extern int DAQmxClearTask(IntPtr taskHandle);

    private const double sampleRate = 5000.0;

    public IntPtr ConfigureDAQ()
    {
        IntPtr taskHandle = IntPtr.Zero;

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
            DAQmxClearTask(taskHandle);
            return IntPtr.Zero;
        }

        error = DAQmxCreateAOVoltageChan(taskHandle, "Dev1/ao1", "stimulus_wave", 0, 10.0, DAQmx_Val_Volts);
        if (error != DAQmxSuccess)
        {
            Debug.LogError("Error creating channel ao1: " + error);
            DAQmxClearTask(taskHandle);
            return IntPtr.Zero;
        }

        error = DAQmxCfgSampClkTiming(taskHandle, "", sampleRate, 10280, DAQmx_Val_FiniteSamps, 5000);
        if (error != DAQmxSuccess)
        {
            Debug.LogError("Error configuring sample clock timing: " + error);
            DAQmxClearTask(taskHandle);
            return IntPtr.Zero;
        }

        // Configure output buffer explicitly to match sample size
        error = DAQmxCfgOutputBuffer(taskHandle, 5000);
        if (error != DAQmxSuccess)
        {
            Debug.LogError("Error configuring output buffer: " + error);
            DAQmxClearTask(taskHandle);
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

        // Write the combined signal data to the buffer with autoStart set to true and longer timeout
        int samplesWritten;
        int error = DAQmxWriteAnalogF64(taskHandle, triggerWave.Length, true, 1000.0, DAQmx_Val_GroupByScanNumber, combinedData, out samplesWritten, IntPtr.Zero);
        if (error != DAQmxSuccess || samplesWritten != triggerWave.Length)
        {
            Debug.LogError("Error writing data to buffer: " + error + ". Samples written: " + samplesWritten);
        }
    }

    public void SendAndStop(IntPtr taskHandle)
    {
        int error = DAQmxStartTask(taskHandle);
        if (error != DAQmxSuccess)
        {
            Debug.LogError("Error starting DAQ task: " + error);
            return;
        }

        // Stop and clear the task
        DAQmxStopTask(taskHandle);
        DAQmxClearTask(taskHandle);
    }
}
