using System.Collections;
// ReSharper disable once RedundantUsingDirective
using UnityEngine;
using bmlTUX.Scripts.ExperimentParts;
using System;
using System.Collections.Generic;
using System.IO;

/// <summary>
/// Classes that inherit from Experiment define custom behaviour for the start and end of your experiment.
/// This might useful for experiment setup, instructions, and debrief.
///
/// This template shows how to set up a custom experiment script using the toolkit's built-in functions.
///
/// You can delete any unused methods and unwanted comments. The only required part is the constructor.
///
/// You cannot edit the main execution part of experiments since their main execution is to run the trials and blocks.
/// </summary>
public class SensAtt_Pred_trainingExperiment : Experiment {
    // // You usually want to store a reference to your experiment runner
    // YourCustomExperimentRunner myRunner;
    SensAtt_Pred_trainingRunner myRunner;

    // Required Constructor. Good place to set up references to objects in the unity scene
    public SensAtt_Pred_trainingExperiment(ExperimentRunner runner, RunnableDesign runnableDesign) : base(runner, runnableDesign) {
        // myRunner = (YourCustomExperimentRunner)runner;  //cast the generic runner to your custom type.
        // GameObject myGameObject = myRunner.MyGameObject;  // get reference to gameObject stored in your custom runner
        myRunner = (SensAtt_Pred_trainingRunner)runner;  //cast the generic runner to your custom type.
    }


    // Optional Pre-Experiment code. Useful for pre-experiment calibration and setup.
    protected override void PreMethod() {
    }


    // Optional Pre-Experiment code. Useful for pre-experiment instructions.
    protected override IEnumerator PreCoroutine() {
        yield return null; //required for coroutine
    }


    // Optional Post-Experiment code. Useful for experiment debrief instructions.
    protected override IEnumerator PostCoroutine() {
        yield return null; //required for coroutine
    }


    // Optional Post-Experiment code.
    protected override void PostMethod() {
        File.Move(Application.dataPath + "/Response_training.txt", "C:/Gian/GG_SensAtt_V2_2025/02Data/ID" + myRunner.EmptyObject.GetComponent<ID>().ID_string + "/00Behavioural/" + "Training_response" + "_ID" + myRunner.EmptyObject.GetComponent<ID>().ID_string + ".txt");
        File.Move(Application.dataPath + "/Log_training.txt", "C:/Gian/GG_SensAtt_V2_2025/02Data/ID" + myRunner.EmptyObject.GetComponent<ID>().ID_string + "/00Behavioural/" + "Training_Log" + "_ID" + myRunner.EmptyObject.GetComponent<ID>().ID_string + ".txt");
        File.Move(Application.dataPath + "/HandPositions.txt", "C:/Gian/GG_SensAtt_V2_2025/02Data/ID" + myRunner.EmptyObject.GetComponent<ID>().ID_string + "/00Behavioural/" + "Training_Hand_Positions" + "_ID" + myRunner.EmptyObject.GetComponent<ID>().ID_string + ".txt");
    }
}

