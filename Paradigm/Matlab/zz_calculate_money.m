%% zz_calculate_money

%% BEHAVIOURAL ANALYSIS OF GIAN POLINA DATA
% This script will analyse the response and Log file of each participant.
clear; clc; 

ID = '30'; 

%% Check number of trials within each condition
opts = delimitedTextImportOptions("NumVariables", 18);
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
opts.VariableNames = ["Block", "Block_num", "TrialInBlock", "Trial", "Trial_type", "Stimulation", "Stim_tactile_1", "Stim_auditory_1", "Stim_tactile_2", "Stim_auditory_2", "HighLow", "Control", "ITIs", "Speed", "Var15", "Var16", "Var17", "Var18"];
opts.SelectedVariableNames = ["Block", "Block_num", "TrialInBlock", "Trial", "Trial_type", "Stimulation", "Stim_tactile_1", "Stim_auditory_1", "Stim_tactile_2", "Stim_auditory_2", "HighLow", "Control", "ITIs", "Speed"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "string", "string", "string", "string"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts = setvaropts(opts, ["Var15", "Var16", "Var17", "Var18"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var15", "Var16", "Var17", "Var18"], "EmptyFieldRule", "auto");
TrialTable = readtable(strcat("C:\Gian\GG_SensAtt_V2_2025\02Data\ID", ID, "\00Behavioural\ID", ID, "TrialTable.csv"), opts);
clear opts

%% Import Responses
opts = delimitedTextImportOptions("NumVariables", 6);
opts.DataLines = [2, Inf];
opts.Delimiter = "\t";
opts.VariableNames = ["TrialN", "Stimulation", "HighLow_randomisation", "Control_randomisation", "Response", "Button"];
opts.VariableTypes = ["double", "double", "double", "double", "categorical", "categorical"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts = setvaropts(opts, ["Response", "Button"], "EmptyFieldRule", "auto");
Experimentresponse = readtable(strcat("C:\Gian\GG_SensAtt_V2_2025\02Data\ID", ID, "\00Behavioural\Experiment_response_ID", ID, ".txt"), opts);


for i = 2:size(Experimentresponse,1)
    if Experimentresponse.TrialN(i-1)+1 ~= Experimentresponse.TrialN(i)
        warning(strcat(int2str(i)))
    end
end

%% Clear temporary variables
clear opts

%% 
TrialTable.Responses = Experimentresponse.Response(:); 

%% First calculate accuracy on Tactile
Responses_tactile = TrialTable(find(TrialTable.Stimulation == 1 & (TrialTable.Responses == "High"  | TrialTable.Responses == "Low")),:);

stimuli = unique(Responses_tactile.Stim_tactile_2(:));

total_total = []; 
total_correct_responses = []; 
for i = 1:length(stimuli)

    if i < 5
        total = find(Responses_tactile.Stim_tactile_2 == stimuli(i));
        correct_responses = find(Responses_tactile.Stim_tactile_2 == stimuli(i) & Responses_tactile.Responses == "Low"); 
    elseif i > 5
        total = find(Responses_tactile.Stim_tactile_2 == stimuli(i));
        correct_responses = find(Responses_tactile.Stim_tactile_2 == stimuli(i) & Responses_tactile.Responses == "High"); 
    end

    if i ~= 5
        total_total = [16 20 32 36 36 32 20 16];
        total_correct_responses = [total_correct_responses numel(correct_responses)];
    end
end

percentage_correct_tactile = sum(total_correct_responses)/sum(total_total)*100; 






%% Second calculate accuracy on auditory
Responses_audio = TrialTable(find(TrialTable.Stimulation == 2 & (TrialTable.Responses == "High"  | TrialTable.Responses == "Low")),:);

stimuli = unique(Responses_audio.Stim_auditory_2(:));

total_total = []; 
total_correct_responses = []; 
for i = 1:length(stimuli)

    if i < 5
        total = find(Responses_audio.Stim_auditory_2 == stimuli(i));
        correct_responses = find(Responses_audio.Stim_auditory_2 == stimuli(i) & Responses_audio.Responses == "Low"); 
    elseif i > 5
        total = find(Responses_audio.Stim_auditory_2 == stimuli(i));
        correct_responses = find(Responses_audio.Stim_auditory_2 == stimuli(i) & Responses_audio.Responses == "High"); 
    end

    if i ~= 5
        total_total = [16 20 32 36 36 32 20 16];
        total_correct_responses = [total_correct_responses numel(correct_responses)];
    end
end

percentage_correct_audio = sum(total_correct_responses)/sum(total_total)*100; 

%% CALCULATE MONEY
money2give = calculate_payment(mean([percentage_correct_tactile percentage_correct_audio]));


%% PRINT OUTPUT

sprintf(['Percentage correct tactile = %.4f \n' ...
         'Percentage correct audio = %.4f \n' ...
         'Total money to give = %.2f'], ...
         percentage_correct_tactile, percentage_correct_audio, 36+money2give)





function payment = calculate_payment(accuracy)
    % Define the base payment ranges
    min_accuracy = 50; % 50% accuracy corresponds to 3€
    max_accuracy = 95; % 90% accuracy corresponds to 20€

    % If accuracy is less than 50%, pay 3€
    if accuracy < min_accuracy
        payment = 3;
    % If accuracy is greater than or equal to 90%, pay 20€
    elseif accuracy >= max_accuracy
        payment = 20;
    else
        % For accuracies between 50% and 90%, interpolate linearly
        payment = 3 + (accuracy - min_accuracy) * (20 - 3) / (max_accuracy - min_accuracy);
    end
end































