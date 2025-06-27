using System.Collections;
using System.Data;
using UnityEngine;
using UnityEngine.Events;
using bmlTUX.Scripts.ExperimentParts;
using bmlTUX.Scripts.Managers;
//using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;

/// <summary>
/// Classes that inherit from Trial define custom behaviour for your experiment's trials.
/// Most experiments will need to edit this file to describe what happens in a trial.
///
/// This template shows how to set up a custom trial script using the toolkit's built-in functions.
///
/// You can delete any unused methods and unwanted comments. The only required parts are the constructor and the MainCoroutine.
/// </summary>
public class SensAtt_PredTrial : Trial {

    //Reference to my experiment runner
    SensAtt_PredRunner myRunner;

    //set up my variable path (reference from the CreateLogOnStart function).
    public string path;
    public string response_path;
    //set up my variable path1 (in which we will print our subject's response based on size)
    //public string path1 = Application.dataPath + "/Subj_Response.txt";

    // Required Constructor. Good place to set up references to objects in the unity scene
    public SensAtt_PredTrial(ExperimentRunner runner, DataRow data) : base(runner, data) {
        myRunner = (SensAtt_PredRunner)runner;  //cast the generic runner to your custom type.
    }

    public UnityEvent Caller_Haptic;
    public UnityEvent Caller_Vision;

    //Instance for touch bool (NOTE: private! I declare that my script is private and cannot directly change it. At least read it :))
    private CollisionEventCall CEC;
    //Instance for PLT script
    public PLT plt;
    //Instance for FingerFeedback script
    //public SG_FingerFeedback fingerfeedback;

    public DAQmx_v2 daq; 

    public int StartTrial;
    public int preGO;
    public int GO;

    public double[] combinedData;

    public string response;

    public bool skiptrial; 

    // Stuff for vibration
    //public SG_HandSection handLocation = SG_HandSection.Index;
    //public SG_HapticGlove linkedGlove;
    //public SG_HandFeedback feedbackScript;

    //public int impactLevel1 = 1000;
    //public float vibrationTime1 = 0.06f;

    //public float speed = 1f;

    private Vector3 InitPositionRight = new Vector3(-0.221f, 0.7496f, 0.005f);
    private Vector3 InitPositionLeft = new Vector3(0.1786f, 0.7496f, 0.005f);
    private Vector3 TargetPositionRight = new Vector3(-0.221f, 0.7496f, 0.005f);
    private Vector3 TargetPositionLeft = new Vector3(0.1786f, 0.7496f, 0.005f);
    private Vector3 TargetPosition = new Vector3(0, 0, 0);

    public Vector3 starting_position;
    public Vector3 ending_position;

    public float starting_time;
    public float ending_time;

    private float lastTime;       // Tracks last time
    private Vector3 lastPosition; // Tracks last position
    private List<float> velocityAverages = new List<float>(); // Stores velocities above threshold

    public float randomVelocity;

    public float tic; 

    // Optional Pre-Trial code. Useful for setting unity scene for trials. Executes in one frame at the start of each trial
    protected override void PreMethod() {
        // Collision Event Call reference
        CEC = myRunner.Visual.GetComponent<CollisionEventCall>();
        //Set to false at the start of each trial, it detects collision from another script and it uses it to determine when to finish trial
        CEC.touch = false;

        skiptrial = false; 

        // Also from CEC get the event that gets called whether the finger touch the proper visual object
        UnityEvent Caller_Visual = CEC.call_visual;
        Caller_Visual.RemoveAllListeners();
        Caller_Visual.AddListener(caller_visual);

        // Parallel Port script (PLT) reference
        plt = myRunner.EmptyObject.GetComponent<PLT>();

        // Daq card script reference
        daq = myRunner.EmptyObject.GetComponent<DAQmx_v2>();

        // Print something in the Exp files
        // Set path for Log file
        path = Application.dataPath + "/Log.txt";
        if ((int)Data["Trial"] == 0) {
            //Append to Log file some subjects data, experiment start infos and column titles
            File.AppendAllText(path, (string)Data["ID"] + "\t" + (string)Data["initials"] + "\n");
            File.AppendAllText(path, "Experiment Start" + "\t" + Time.time*1000 + "\n");
            File.AppendAllText(path, "Block \t Trial \t TrialType \t Stimulation \t Event_Name \t Time \n");

            myRunner.EmptyObject.GetComponent<ID>().ID_string = (string)Data["ID"];
        }

        response_path = Application.dataPath + "/Responses.txt";
        // Set stuff up for unique response in the training phase
        if ((int)Data["Trial"] == 0)
        {
            //File.AppendAllText(response_training_path, (string)Data["ID"] + "\t" + (string)Data["initials"] + "\n");
            File.AppendAllText(response_path, "TrialN \t Stimulation \t HighLow_randomisation \t Control_randomisation \t Response \t Button \n");
        }

        //Make object and force/haptic field appear
        // myRunner.Visual.SetActive(true);
        // myRunner.Visual.GetComponent<MeshRenderer>().enabled = true;
        // myRunner.Haptic.SetActive(true);

        //Make object appear in the right position
        if ((int) Data["Trial_type"] == 1) {
            myRunner.Visual.transform.position = InitPositionRight;
            myRunner.Visual.SetActive(true);
            myRunner.RingL.SetActive(true);
            myRunner.RingR.SetActive(true);
        }
        else if ((int) Data["Trial_type"] == 2) {
            myRunner.Visual.transform.position = InitPositionRight;
            myRunner.Visual.SetActive(true);
            myRunner.RingL.SetActive(true);
            myRunner.RingR.SetActive(true);
            TargetPosition = TargetPositionLeft;
        } else if ((int) Data["Trial_type"] == 3) {
            myRunner.Visual.transform.position = InitPositionLeft;
            myRunner.Visual.SetActive(true);
            myRunner.RingL.SetActive(true);
            myRunner.RingR.SetActive(true);
        }
        else if ((int) Data["Trial_type"] == 4) {
            myRunner.Visual.transform.position = InitPositionLeft;
            myRunner.Visual.SetActive(true);
            myRunner.RingL.SetActive(true);
            myRunner.RingR.SetActive(true);
            TargetPosition = TargetPositionRight;
        }

        //Sets vibration on and off based on the trial
        if ((int)Data["Stimulation"] == 1) {
            CEC.hapticActive = true; // electrical stimulation
            StartTrial = 11;
            preGO = 21;
            GO = 31;
        }
        else if ((int)Data["Stimulation"] == 2) 
        {
            CEC.hapticActive = true; // auditory stimulation
            StartTrial = 12;
            preGO = 22;
            GO = 32;
        }
        else if ((int)Data["Stimulation"] == 3)
        {
            CEC.hapticActive = false; // no stimulation
            StartTrial = 10;
            preGO = 20;
            GO = 30;
        }

        if (myRunner.RingR.GetComponent<CollisionEventCall_indicator>().Indicator_touch == false && myRunner.RingL.GetComponent<CollisionEventCall_indicator>().Indicator_touch == false)
        {
            myRunner.Instruction_IndicatorReminder.SetActive(true);
            skiptrial = true;
            //myRunner.Instruction_IndicatorReminder.SetActive(true);
            //yield return null;
        }
        else
        {
            // Make sure that reminder is off 
            myRunner.Instruction_IndicatorReminder.SetActive(false);

            // PERHAPS ADD FLEXIBLE TRIAL MARKERS? e.g. one for each stim type? 
            //After everything's ready, print start trial inside the logfile and send input to eeg.
            File.AppendAllText(path, (int)Data["Block"] + "\t" + (int)Data["TrialInBlock"] + "\t" + (int)Data["Trial_type"] + "\t" + (int)Data["Stimulation"] + "\t" + "Start_trial_" + (int)Data["TrialInBlock"] + "\t" + Time.time * 1000 + "\n");
            plt.PLTsend(StartTrial);
            myRunner.Fix.SetActive(true);
        }
    }


    // Optional Pre-Trial code. Useful for waiting for the participant to
    // do something before each trial (multiple frames). Also might be useful for fixation points etc.
    protected override IEnumerator PreCoroutine()
    {
        while (skiptrial == false)
        {
            bool keepfinger = true;
            while (keepfinger)
            {
                myRunner.Instruction_IndicatorReminder.SetActive(false);
                myRunner.Visual.GetComponent<Renderer>().enabled = true;
                if (myRunner.RingR.GetComponent<CollisionEventCall_indicator>().Indicator_touch == false && myRunner.RingL.GetComponent<CollisionEventCall_indicator>().Indicator_touch == false)
                {
                    myRunner.Instruction_IndicatorReminder.SetActive(true);
                    skiptrial = true;
                }
                yield return new WaitForSeconds(1);
                if (myRunner.RingR.GetComponent<CollisionEventCall_indicator>().Indicator_touch == false && myRunner.RingL.GetComponent<CollisionEventCall_indicator>().Indicator_touch == false)
                {
                    myRunner.Instruction_IndicatorReminder.SetActive(true);
                    skiptrial = true;
                }
                // print in log "preGO"
                File.AppendAllText(path, (int)Data["Block"] + "\t" + (int)Data["TrialInBlock"] + "\t" + (int)Data["Trial_type"] + "\t" + (int)Data["Stimulation"] + "\t" + "preGO" + "\t" + Time.time * 1000 + "\n");
                plt.PLTsend(preGO);

                if ((int)Data["Trial_type"] == 4 || (int)Data["Trial_type"] == 2)
                {
                    myRunner.PreGO_Stay.SetActive(true);
                }
                else if ((int)Data["Trial_type"] == 1 || (int)Data["Trial_type"] == 3)
                {
                    myRunner.PreGO_Move.SetActive(true);
                }
                if (myRunner.RingR.GetComponent<CollisionEventCall_indicator>().Indicator_touch == false && myRunner.RingL.GetComponent<CollisionEventCall_indicator>().Indicator_touch == false)
                {
                    myRunner.Instruction_IndicatorReminder.SetActive(true);
                    skiptrial = true;
                }
                yield return new WaitForSeconds(0.5f); // time for the pre cue to flash of the right color;
                myRunner.PreGO_Move.SetActive(false);
                myRunner.PreGO_Stay.SetActive(false);
                if (myRunner.RingR.GetComponent<CollisionEventCall_indicator>().Indicator_touch == false && myRunner.RingL.GetComponent<CollisionEventCall_indicator>().Indicator_touch == false)
                {
                    myRunner.Instruction_IndicatorReminder.SetActive(true);
                    skiptrial = true;
                }
                // print in log "GO"
                File.AppendAllText(path, (int)Data["Block"] + "\t" + (int)Data["TrialInBlock"] + "\t" + (int)Data["Trial_type"] + "\t" + (int)Data["Stimulation"] + "\t" + "GO" + "\t" + Time.time * 1000 + "\n");
                plt.PLTsend(GO);

                keepfinger = false; //required for coroutine

                lastTime = 0;       // resets last time
                velocityAverages.Clear();  //clear the list

                yield return null;
            }
            break;
        }
        if (skiptrial == true)
        {
            //trial is skipped
            yield return null;
        }
    }


    // Main Trial Execution Code.
    protected override IEnumerator RunMainCoroutine()
    {
        if (skiptrial == false)
        {
            //bool DAQconfigured = daq.ConfigureDAQ();
            //Debug.Log(DAQconfigured); 
            CEC.freeze = false;
            // START PREPARING SIGNAL FROM DAQ HERE
            //Prepare the data first
            if ((int)Data["Stimulation"] == 1)
            {
                combinedData = daq.Prepare_Data(1, 0, (float)Data["Stim_tactile_1"], (float)Data["Stim_auditory_1"]);
            }
            else if ((int)Data["Stimulation"] == 2)
            {
                combinedData = daq.Prepare_Data(0, 1, (float)Data["Stim_tactile_1"], (float)Data["Stim_auditory_1"]);
            }
            else if ((int)Data["Stimulation"] == 3)
            {
                combinedData = daq.Prepare_Data(1, 1, (float)Data["Stim_tactile_1"], (float)Data["Stim_auditory_1"]);
            }

            bool dataWritten = daq.WriteData(combinedData);


            starting_position = myRunner.FingerTip.transform.position;
            starting_time = Time.time * 1000;



            int counter = 0; 

            bool waitingForParticipantResponse = true;
            while (waitingForParticipantResponse)
            {

                // Calculate velocity
                if (lastTime == 0)
                {
                    // Set for the first time the starting position and time
                    lastPosition = myRunner.FingerTip.transform.position;
                    lastTime = Time.time;
                }
                else
                {
                    // Calculate instantaneous velocity
                    Vector3 currentPosition = myRunner.FingerTip.transform.position;
                    float currentTime = Time.time;
                    float deltaTime = currentTime - lastTime;

                    float instantaneousVelocity = Vector3.Distance(currentPosition, lastPosition) / deltaTime;
                    //Debug.Log("Instantaneous Velocity: " + instantaneousVelocity);

                    if (instantaneousVelocity > 0.1f)
                    {
                        velocityAverages.Add(instantaneousVelocity);
                    }

                    lastPosition = currentPosition;
                    lastTime = currentTime;
                }

                // Ball moves towards the finger
                // Trial end conditions handling
                if ((int)Data["Trial_type"] == 2 || (int)Data["Trial_type"] == 4)
                {
                    if (myRunner.RingR.GetComponent<CollisionEventCall_indicator>().Indicator_touch == true || myRunner.RingL.GetComponent<CollisionEventCall_indicator>().Indicator_touch == true)
                    {
                        if ((int)Data["Trial"] < 10)
                        {
                            myRunner.Visual.transform.position = Vector3.MoveTowards(myRunner.Visual.transform.position, TargetPosition, (float)Data["Speed"] * Time.deltaTime);
                            if(counter == 0)
                            {
                                File.AppendAllText(path, (int)Data["Block"] + "\t" + (int)Data["TrialInBlock"] + "\t" + (int)Data["Trial_type"] + "\t" + (int)Data["Stimulation"] + "\t" + "Velocity" + "\t" + (float)Data["Speed"] + "\n");
                            }
                            counter = counter + 1; 
                        }
                        else
                        {
                            if(counter == 0)
                            {
                                randomVelocity = daq.velocities[Random.Range(0, daq.velocities.Count)];

                                File.AppendAllText(path, (int)Data["Block"] + "\t" + (int)Data["TrialInBlock"] + "\t" + (int)Data["Trial_type"] + "\t" + (int)Data["Stimulation"] + "\t" + "Velocity" + "\t" + randomVelocity + "\n");
                            }
                            counter = counter + 1;
                            myRunner.Visual.transform.position = Vector3.MoveTowards(myRunner.Visual.transform.position, TargetPosition, randomVelocity * Time.deltaTime);
                        }
                    }
                    // also when in this condition, make sure that the finger doesn't move from the indicator
                    else //(myRunner.Indicator.GetComponent<CollisionEventCall_indicator>() == false)
                    {
                        //myRunner.Visual.SetActive(false);
                        ////myRunner.Haptic.SetActive(false); 
                        myRunner.Instruction_IndicatorReminder.SetActive(true);
                        //yield return new WaitForSeconds(3);
                        //myRunner.Instruction_IndicatorReminder.SetActive(false);
                        waitingForParticipantResponse = false;
                        skiptrial = true; 
                    }
                }

                //General trial end conditions handling (when participant touches somehow the ball)
                if (CEC.touch == true)
                {
                    ending_position = myRunner.FingerTip.transform.position;
                    ending_time = Time.time * 1000;
                    if ((int)Data["Trial_type"] == 1 || (int)Data["Trial_type"] == 3)
                    {
                        float sum = 0f;
                        foreach (float v in velocityAverages)
                        {
                            sum += v;
                        }
                        float averageVelocity = sum / velocityAverages.Count;

                        float distance = Vector3.Distance(starting_position, ending_position); // Distance traveled
                        float duration = (ending_time - starting_time) / 1000;               // Time taken
                        // float averageVelocity = duration > 0 ? distance / duration : 0;
                        Debug.Log("DISTANCE = " + distance);
                        Debug.Log("DURATION = " + duration);
                        Debug.Log("AVERGE VELOCITY = " + averageVelocity);
                        if (duration < 2)
                        {
                            if (float.IsNaN(averageVelocity))
                            {
                                Debug.Log("AVERAGE VELOCITY NOT SAVED BECAUSE NAN");
                            } 
                            else
                            {
                                daq.velocities.Add(averageVelocity);
                            }
                        }
                        File.AppendAllText(path, (int)Data["Block"] + "\t" + (int)Data["TrialInBlock"] + "\t" + (int)Data["Trial_type"] + "\t" + (int)Data["Stimulation"] + "\t" + "Velocity" + "\t" + averageVelocity + "\n");
                    }

                    daq.SendData(daq.taskHandle);
                    tic = Time.time * 1000;
                    Debug.Log("TIC" + tic);

                    float timestim = Time.time * 1000;
                    // Write stim time in the log and response file
                    File.AppendAllText(path, (int)Data["Block"] + "\t" + (int)Data["TrialInBlock"] + "\t" + (int)Data["Trial_type"] + "\t" + (int)Data["Stimulation"] + "\t" + "Stim_1" + "\t" + timestim + "\n");

                    // Wait for 1 second before going to the next segment (asnwer and ITI)
                    // Wait for 1 second before going to the next segment (asnwer and ITI)
                    //yield return new WaitForSeconds(0.5f);
                    CEC.freeze = true;
                    waitingForParticipantResponse = false;
                    yield return null; 
                }
                //condition for exiting trial by keypress
                if (Input.GetKeyDown(KeyCode.Space))
                {
                    waitingForParticipantResponse = false;
                }
                yield return null;
            }
        }
        else if (skiptrial == true)
        {
            yield return null;
        }
    }


    // Optional Post-Trial code. Useful for waiting for the participant to do something after each trial (multiple frames)
    protected override IEnumerator PostCoroutine() {

        Debug.Log("Post Coroutine");
        
        if (skiptrial == false)
        {

            // First prepare the data to send to the stimulator (no stimulation as well, but trigger!)
            if ((int)Data["Stimulation"] == 1)
            {
                combinedData = daq.Prepare_Data(1, 0, (float)Data["Stim_tactile_2"], (float)Data["Stim_auditory_2"]);
            }
            else if ((int)Data["Stimulation"] == 2)
            {
                combinedData = daq.Prepare_Data(0, 1, (float)Data["Stim_tactile_2"], (float)Data["Stim_auditory_2"]);
            }
            else if ((int)Data["Stimulation"] == 3)
            {
                combinedData = daq.Prepare_Data(1, 1, (float)Data["Stim_tactile_2"], (float)Data["Stim_auditory_2"]);
            }
            bool dataWritten = daq.WriteData(combinedData);

            bool wait1sec = true; 
            while (wait1sec)
            {
                float toc = Time.time * 1000;
                Debug.Log("TOC" + toc); 
                if (toc - tic > 1000)
                {
                    wait1sec = false;
                }
                yield return null;
            }

            //yield return new WaitForSeconds(0.5f);
            //Send stimulus nad wait 0.5s
            daq.SendData(daq.taskHandle);

            // Get stimulation time and print it in log and response file
            float timestim = Time.time * 1000;
            // Write stim time in the log and response file
            File.AppendAllText(path, (int)Data["Block"] + "\t" + (int)Data["TrialInBlock"] + "\t" + (int)Data["Trial_type"] + "\t" + (int)Data["Stimulation"] + "\t" + "Stim_2" + "\t" + timestim + "\n");

            // Response 
            if ((int)Data["Stimulation"] == 3)
            {
                if ((int)Data["Control"] == 1)
                {
                    myRunner.Fix.SetActive(false);
                    myRunner.Fix_big.SetActive(true);
                    yield return new WaitForSeconds(0.2f);
                    myRunner.Fix.SetActive(true);
                    myRunner.Fix_big.SetActive(false);
                }
                else if ((int)Data["Control"] == 2)
                {
                    myRunner.Fix.SetActive(false);
                    myRunner.Fix_small.SetActive(true);
                    yield return new WaitForSeconds(0.2f);
                    myRunner.Fix.SetActive(true);
                    myRunner.Fix_small.SetActive(false);
                }
                yield return new WaitForSeconds(0.3f);
                //Make ball disappear
                myRunner.Visual.SetActive(false);
            }
            else
            {
                yield return new WaitForSeconds(0.5f);
                //Make ball disappear
                myRunner.Visual.SetActive(false);
            }



            // Set stimuli for response
            if ((int)Data["HighLow"] == 1)
            {
                myRunner.Arrows_HighRight_LowLeft.SetActive(true);
            }
            else if ((int)Data["HighLow"] == 2)
            {
                myRunner.Arrows_HighLeft_LowRight.SetActive(true);
            }

            bool responseNotGiven = true;
            starting_time = Time.time * 1000;
            while (responseNotGiven)
            {
                ending_time = Time.time * 1000;

                if (ending_time - starting_time > 1500)
                {
                    File.AppendAllText(path, (int)Data["Block"] + "\t" + (int)Data["TrialInBlock"] + "\t" + (int)Data["Trial_type"] + "\t" + (int)Data["Stimulation"] + "\t" + "no_response" + "\t" + ending_time + "\n");
                    File.AppendAllText(response_path, (int)Data["TrialInBlock"] + "\t" + (int)Data["Stimulation"] + "\t" + (int)Data["HighLow"] + "\t" + (int)Data["Control"] + "\t" + "no_response" + "\t" + "OverTime" + "\n");
                    responseNotGiven = false;

                    myRunner.ReminderResponse.SetActive(true);

                    myRunner.Arrows_HighRight_LowLeft.SetActive(false);
                    myRunner.Arrows_HighRight_thick_LowLeft.SetActive(false);
                    myRunner.Arrows_HighRight_LowLeft_thick.SetActive(false);
                    myRunner.Arrows_HighLeft_LowRight.SetActive(false);
                    myRunner.Arrows_HighLeft_thick_LowRight.SetActive(false);
                    myRunner.Arrows_HighLeft_LowRight_thick.SetActive(false);

                    yield return new WaitForSeconds(1f);

                    myRunner.ReminderResponse.SetActive(false);

                }

                //Detect when the down arrow key is pressed down
                if (Input.GetKeyDown(KeyCode.DownArrow)) //left
                {
                    Debug.Log("Down Arrow key was pressed.");
                    if ((int)Data["HighLow"] == 1)
                    {
                        myRunner.Arrows_HighRight_LowLeft_thick.SetActive(true);
                        response = "Low";
                    }
                    else if ((int)Data["HighLow"] == 2)
                    {
                        myRunner.Arrows_HighLeft_thick_LowRight.SetActive(true);
                        response = "High";
                    }

                    timestim = Time.time * 1000;

                    yield return new WaitForSeconds(0.2f);

                    myRunner.Arrows_HighRight_LowLeft.SetActive(false);
                    myRunner.Arrows_HighRight_thick_LowLeft.SetActive(false);
                    myRunner.Arrows_HighRight_LowLeft_thick.SetActive(false);
                    myRunner.Arrows_HighLeft_LowRight.SetActive(false);
                    myRunner.Arrows_HighLeft_thick_LowRight.SetActive(false);
                    myRunner.Arrows_HighLeft_LowRight_thick.SetActive(false);

                    //Append response
                    // Write stim time in the log and response file
                    File.AppendAllText(path, (int)Data["Block"] + "\t" + (int)Data["TrialInBlock"] + "\t" + (int)Data["Trial_type"] + "\t" + (int)Data["Stimulation"] + "\t" + response + "\t" + timestim + "\n");
                    File.AppendAllText(response_path, (int)Data["TrialInBlock"] + "\t" + (int)Data["Stimulation"] + "\t" + (int)Data["HighLow"] + "\t" + (int)Data["Control"] + "\t" + response + "\t" + "left" + "\n");
                    responseNotGiven = false;

                }
                else if (Input.GetKeyDown(KeyCode.UpArrow)) //right
                {
                    Debug.Log("Up Arrow key was pressed");
                    if ((int)Data["HighLow"] == 1)
                    {
                        myRunner.Arrows_HighRight_thick_LowLeft.SetActive(true);
                        response = "High";
                    }
                    else if ((int)Data["HighLow"] == 2)
                    {
                        myRunner.Arrows_HighLeft_LowRight_thick.SetActive(true);
                        response = "Low";
                    }

                    timestim = Time.time * 1000;

                    yield return new WaitForSeconds(0.2f);

                    myRunner.Arrows_HighRight_LowLeft.SetActive(false);
                    myRunner.Arrows_HighRight_thick_LowLeft.SetActive(false);
                    myRunner.Arrows_HighRight_LowLeft_thick.SetActive(false);
                    myRunner.Arrows_HighLeft_LowRight.SetActive(false);
                    myRunner.Arrows_HighLeft_thick_LowRight.SetActive(false);
                    myRunner.Arrows_HighLeft_LowRight_thick.SetActive(false);

                    //Append response
                    // Write stim time in the log and response file
                    File.AppendAllText(path, (int)Data["Block"] + "\t" + (int)Data["TrialInBlock"] + "\t" + (int)Data["Trial_type"] + "\t" + (int)Data["Stimulation"] + "\t" + response + "\t" + timestim + "\n");
                    File.AppendAllText(response_path, (int)Data["TrialInBlock"] + "\t" + (int)Data["Stimulation"] + "\t" + (int)Data["HighLow"] + "\t" + (int)Data["Control"] + "\t" + response + "\t" + "right" + "\n");

                    responseNotGiven = false;
                }
                yield return null;
            }

            // wait for ITI
            myRunner.Fix.SetActive(true);
            myRunner.RingL.SetActive(true);
            myRunner.RingR.SetActive(true);
            yield return new WaitForSeconds((float)Data["ITIs"]);
            yield return null;
        }
        else if (skiptrial == true)
        {
            myRunner.Visual.SetActive(false);

            plt.PLTsend(100);

            yield return new WaitForSeconds(2);
            myRunner.Instruction_IndicatorReminder.SetActive(false);

            if ((int)Data["Trial_type"] == 1 || (int)Data["Trial_type"] == 4)
            {
                myRunner.Instruction_blockR.SetActive(true);
            }
            else if ((int)Data["Trial_type"] == 3 || (int)Data["Trial_type"] == 2)
            {
                myRunner.Instruction_blockL.SetActive(true);
            }

            bool waitingforfinger = true;
            while (waitingforfinger)
            {
                if (myRunner.RingR.GetComponent<CollisionEventCall_indicator>().Indicator_touch == true || myRunner.RingL.GetComponent<CollisionEventCall_indicator>().Indicator_touch == true)
                {
                    yield return new WaitForSeconds(2);

                    // if after 1s is still on the indicator, then continue with block
                    if (myRunner.RingR.GetComponent<CollisionEventCall_indicator>().Indicator_touch == true || myRunner.RingL.GetComponent<CollisionEventCall_indicator>().Indicator_touch == true)
                    {
                        myRunner.Instruction_blockL.SetActive(false);
                        myRunner.Instruction_blockR.SetActive(false);
                        myRunner.Instruction_IndicatorReminder.SetActive(false);
                        waitingforfinger = false;
                    }
                }
                yield return null;
            }
            File.AppendAllText(path, (int)Data["Block"] + "\t" + (int)Data["TrialInBlock"] + "\t" + (int)Data["Trial_type"] + "\t" + (int)Data["Stimulation"] + "\t" + "Trial Skipped" + "\t" + Time.time * 1000 + "\n");
            File.AppendAllText(response_path, (int)Data["TrialInBlock"] + "\t" + (int)Data["Stimulation"] + "\t" + (int)Data["HighLow"] + "\t" + (int)Data["Control"] + "\t" + "Trial Skipped" + "\t" + Time.time * 1000 + "\n");

            yield return new WaitForSeconds((float)Data["ITIs"]);
            yield return null;
        }
    }


    // Optional Post-Trial code. useful for writing data to dependent variables and for resetting everything.
    // Executes in a single frame at the end of each trial
    protected override void PostMethod() {
    }



    //Functions called when UnityEvent associated to Haptic Feedback signalling is sent.
//    void caller_haptic()
//    {
//        //plt.PLTsend(Index_haptic_PLT);
//        if ((string) Data["Block_type"] == "TouchVision"){
////            this.linkedGlove = this.feedbackScript.TrackedHand.gloveHardware;
//////            SGCore.Finger finger1 = (SGCore.Finger)handLocation; //can do this since the finger indices match
//////            SGCore.Haptics.SG_TimedBuzzCmd buzzCmd = new SGCore.Haptics.SG_TimedBuzzCmd(finger1, impactLevel1, vibrationTime1);
////            //linkedGlove.SendCmd(buzzCmd);
//            Debug.Log("index haptic" + Time.time*1000);
//            File.AppendAllText(path, "Index_haptic" + "\t" + Time.time*1000 + "\n");
//        } if ((string) Data["Block_type"] == "TouchnoVision"){
////            this.linkedGlove = this.feedbackScript.TrackedHand.gloveHardware;
////            SGCore.Finger finger1 = (SGCore.Finger)handLocation; //can do this since the finger indices match
////            SGCore.Haptics.SG_TimedBuzzCmd buzzCmd = new SGCore.Haptics.SG_TimedBuzzCmd(finger1, impactLevel1, vibrationTime1);
////            linkedGlove.SendCmd(buzzCmd);
//            Debug.Log("index haptic" + Time.time*1000);
//            File.AppendAllText(path, "Index_haptic" + "\t" + Time.time*1000 + "\n");
//        }
//    }

    void caller_visual()
    {
        Debug.Log("index visual" + Time.time * 1000);
        //plt.PLTsend(Index_visual_PLT);
    }
}