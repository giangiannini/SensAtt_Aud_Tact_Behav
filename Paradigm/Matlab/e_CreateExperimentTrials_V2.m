%% CREATE EXP RUNNER FILE 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc;
ID = "30";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trialperblock = 160; %64 auditory, 64 tactile, 32 no stim. 
numBlocks = 1; %per run
numRuns = 4;
trial_pool = [3 4; 1 2];
ITIs_limits = [1050 1550]; %add the 200ms that it takes for the high low to disappear after response so that average is 1500ms
percentage_stim_per_modality = 0.4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t = tic; 
num_trials_per_intensity = [16    20    32    36    48    36    32    20    16]; %sum to 256 (640/4). 

rng shuffle
%% Setup general paths
%Path in which the table will be printed
% outputpath = strcat("C:/Users/CCNB-EEG1/Desktop/Gian/GG_Somato_Vision/02Data/ID", ID, "/00Behavioural/ID", ID, "TrialTable.csv");
folder = strcat("C:/Gian/GG_SensAtt_V2_2025/02Data/ID", ID, "/00Behavioural");
if isfolder(folder) == 0
    mkdir(folder);
end
folder1 = strcat("C:/Gian/GG_SensAtt_V2_2025/02Data/ID", ID, "/01EEG");
if isfolder(folder1) == 0
    mkdir(folder1);
end

%% Check that training files are there
dir_struct = dir(fullfile(folder,'/Training_*'));
if numel(dir_struct) == 0

    outputpath = strcat(folder, "/ID", ID, "training_TrialTable.csv");

    load(fullfile(folder, "new_intensities_auditory_V.mat"))
    load(fullfile(folder, "new_intensities_tactile.mat"))

    new_intensities_auditory = new_intensities_auditory_V; 

    Block = [0; repmat([1], 16, 1); repmat([2], 16, 1)];
    Block_num = Block + 1; 
    TrialInBlock = [0; (1:16)'-1; (1:16)'-1];
    Trial = (1:length(Block))'-1;
    TrialType = [2; repmat([2], 16, 1); repmat([1; 3], 8, 1)];
    Stimulation = [3, ...
                   1 1 1 1 1 1 2 2 2 2 2 2 3 3 3 3, ...
                   1 1 1 1 1 1 2 2 2 2 2 2 3 3 3 3]';
    Stim_tactile_1 = [0; repmat(new_intensities_tactile(5),6,1); repmat([0],6,1); repmat([0],4,1);...
                         repmat(new_intensities_tactile(5),6,1); repmat([0],6,1); repmat([0],4,1)];
    Stim_auditory_1 = [0; repmat([0],6,1); repmat(new_intensities_auditory(5),6,1); repmat([0],4,1);...
                          repmat([0],6,1); repmat(new_intensities_auditory(5),6,1); repmat([0],4,1)];
    Stim_tactile_2 =  [0; repmat(new_intensities_tactile([1 5 9])',2,1); repmat([0],6,1); repmat([0],4,1);...
                         repmat(new_intensities_tactile([1 5 9])',2,1); repmat([0],6,1); repmat([0],4,1)];
    Stim_auditory_2 = [0; repmat([0],6,1); repmat(new_intensities_auditory([1 5 9])',2,1); repmat([0],4,1);...
                          repmat([0],6,1); repmat(new_intensities_auditory([1 5 9])',2,1); repmat([0],4,1)];
    HighLow = [1; repmat([1; 2], 16, 1)];
    HighLow = HighLow(randperm(length(HighLow)));

    Control = [1; repmat([1; 2], 16, 1)];
    Control = Control(randperm(length(Control)));

    ITIs = ITIs_limits(1) + (ITIs_limits(2) - ITIs_limits(1)).*rand(33,1);

    Speed = repmat([0.8], 33, 1); 

    Completed = repmat("false",1,33);
    Attempts = zeros(1,33);
    Skipped = repmat("false",1,33);
    TrialTime = zeros(1,33);

    defTable = table(Block, Block_num, TrialInBlock, Trial, ...
                     TrialType, Stimulation, ...
                     Stim_tactile_1, Stim_auditory_1, ...
                     Stim_tactile_2, Stim_auditory_2, ...
                     HighLow, Control, ...
                     (ITIs/1000), Speed, Completed', Attempts', Skipped', TrialTime');
    
    defTable.Properties.VariableNames = {'Block', 'Block_num', 'TrialInBlock', 'Trial', ...
                                         'Trial_type' 'Stimulation', ...
                                         'Stim_tactile_1', 'Stim_auditory_1', ...
                                         'Stim_tactile_2', 'Stim_auditory_2', ...
                                         'HighLow', 'Control', ...
                                         'ITIs' 'Speed' 'Completed' 'Attempts' 'Skipped' 'TrialTime'};
    
    SummaryTable = groupsummary(defTable, {'Block_num', 'Trial_type'}, @(k)sum(k~=0), {'Stim_tactile_1', 'Stim_auditory_1'});

    writetable(defTable, outputpath, 'Delimiter', ',');

    disp("Training phase still to be run ... here's the file path for Unity")
    disp(outputpath)
    
elseif numel(dir_struct) < 3
    error("something went wrong with the training phase");
elseif numel(dir_struct) == 3

    outputpath = strcat(folder, "/ID", ID, "TrialTable.csv");

    load(fullfile(folder, "new_intensities_auditory_V.mat"))
    load(fullfile(folder, "new_intensities_tactile.mat"))

    new_intensities_auditory = new_intensities_auditory_V; 

    %Create some columns that will be concatenated in a table
    BlockOrder = repmat([1],1,numBlocks); %there are only 3 block types (25/75 /// 50/50 /// 75/25)
    BlockROrder = BlockOrder(randperm(length(BlockOrder)));
    
    RunOrder = 0:1:(numRuns-1);
    RunROrder = RunOrder(randperm(length(RunOrder)));
    
    defTable = table();
    Block_type = [];
    TrialInBlock = [];
    
    %This will loop for the number of trials
    Trial = 0:1:(trialperblock*numBlocks*numRuns - 1);
    Block = reshape(repmat([0:1:numBlocks*numRuns-1],trialperblock,1),[],1);
    Block_num = reshape(repmat([1:numBlocks*numRuns],trialperblock,1),[],1);
    Completed = repmat("false",1,trialperblock*numBlocks*numRuns);
    Attempts = zeros(1,trialperblock*numBlocks*numRuns);
    Skipped = repmat("false",1,trialperblock*numBlocks*numRuns);
    TrialTime = zeros(1,trialperblock*numBlocks*numRuns);
    TrialInBlock = 0:1:(trialperblock-1);
    TrialInBlock = repmat(TrialInBlock, 1, numBlocks*numRuns);
    ITIs = ITIs_limits(1) + (ITIs_limits(2) - ITIs_limits(1)).*rand(trialperblock*numBlocks*numRuns,1);
    HighLow = repmat([1; 2], trialperblock*numRuns/2, 1);
    HighLow = HighLow(randperm(length(HighLow)));

    Control = repmat([1; 2], trialperblock*numRuns/2, 1); 
    Control = Control(randperm(length(Control)));
    
    %% Stuff for speed
    Speed = zeros(1,trialperblock*numBlocks*numRuns); 
    [avg_speed, std_speed] = TakeSpeedfromLog(strcat(folder, '/Training_Log_ID', ID, '.txt')); 
    Speed_vectors = [];
    for i = 1:numBlocks*numRuns
%         r =  + (b-a).*rand(length(BlockROrder),1)

        r = (avg_speed-std_speed) + (avg_speed+std_speed-(avg_speed-std_speed)).*rand(trialperblock,1);
        Speed_vectors = [Speed_vectors; r];
    end
            
    %% RANDOM CONDITION EXTRACTION
    %trial_type = repmat([1:4]',trialperblock*numRuns/4,1); %active2right, passive2right, active2left, passive2right. 
    sumup_to_150 = false; 
    while sumup_to_150 == false
        trial_type = []; 
        trial_type(1,1:4) = randi(4,1,4);
        for m = 1:4
            for k = 1:trialperblock-1
                %extract pseudorandomised number
                if trial_type(k,m) == 1 || trial_type(k,m) == 4
                    if sum(trial_type(:,m) == 4) == 40
                        random_next_trial = 3;
                    elseif sum(trial_type(:,m) == 3) == 40
                        random_next_trial = 4;
                    else
                        random_next_trial = trial_pool(1,round(rand(1)+1));
                    end
                elseif trial_type(k,m) == 2 || trial_type(k,m) == 3
                    if sum(trial_type(:,m) == 1) == 40
                        random_next_trial = 2;
                    elseif sum(trial_type(:,m) == 2) == 40
                        random_next_trial = 1;
                    else
                        random_next_trial = trial_pool(2,round(rand(1)+1));
                    end

                end
                trial_type(k+1,m) = random_next_trial;
            end
        end
        
        if all(sum(trial_type == 1) == 40) && all(sum(trial_type == 2) == 40) && all(sum(trial_type == 3) == 40) && all(sum(trial_type == 4) == 40)
            sumup_to_150 = true; 
        end
    end
    trial_type = [trial_type(:,1); trial_type(:,2); trial_type(:,3); trial_type(:,4)]; 

    %% NOW RANDOMISE (while controlling) THE STIMULATIONS
    trial_table_tot = table();
    for o = 1:4
        %% FIRST STIMULI IS EASY
        stimulation = [repmat(1,trialperblock*0.4,1);...
                       repmat(2,trialperblock*0.4,1); ...
                       repmat(3,trialperblock*0.2,1)]; %somatosensory, auditory, no-stim
        stim_tactile_1 = [repmat(new_intensities_tactile(5), trialperblock*0.4, 1); ...
                          repmat([0], trialperblock*(1-0.4),1)];
        stim_auditory_1 = [repmat([0], trialperblock*0.4,1); ...
                           repmat(new_intensities_auditory(5), trialperblock*0.4, 1); ...
                           repmat([0], round(trialperblock*(1-0.4*2)),1)];

        %% SECOND STIMULI IS FLEXIBLE (tot number is not divisible by 4)
        stim_tactile_2 = []; 
        for i = 1:length(new_intensities_tactile)
            stim_tactile_2 = [stim_tactile_2; repmat(new_intensities_tactile(i), num_trials_per_intensity(i)/4, 1)]; 
        end
        stim_tactile_2 = [stim_tactile_2; ...
                          repmat([0], trialperblock*(1-0.4),1)];

        stim_auditory_2 = []; 
        for i = 1:length(new_intensities_auditory)
            stim_auditory_2 = [stim_auditory_2; repmat(new_intensities_auditory(i), num_trials_per_intensity(i)/4, 1)]; 
        end
        stim_auditory_2 = [repmat([0], trialperblock*0.4,1);
                           stim_auditory_2; ...
                           repmat([0], round(trialperblock*(1-0.4*2)),1)];
        trial_table = table(stimulation, stim_tactile_1, stim_auditory_1, stim_tactile_2, stim_auditory_2);  
        
        correctly_randomised = false; 
        while correctly_randomised == false
            trial_table = trial_table(randperm(size(trial_table,1)), :);
            prova = [table(trial_type((o-1)*160+1:o*160)) trial_table];
            porcodio = groupsummary(prova, {'Var1'}, @(k)sum(k~=0), {'stim_tactile_1', 'stim_auditory_1'});
            if all(porcodio.fun1_stim_tactile_1 == 16) && all(porcodio.fun1_stim_auditory_1 == 16)
                trial_table_tot = [trial_table_tot; trial_table]; 
                correctly_randomised = true; 
            end
        end
    end

    defTable = table(Block, Block_num, TrialInBlock', Trial', ...
                     trial_type, trial_table_tot{:,1}, ...
                     trial_table_tot{:,2}, trial_table_tot{:,3}, ...
                     trial_table_tot{:,4}, trial_table_tot{:,5}, ...
                     HighLow, Control, ...
                     (ITIs/1000), Speed_vectors, Completed', Attempts', Skipped', TrialTime');
    
    %block type is to cancel
    display(toc(t))
    defTable.Properties.VariableNames = {'Block', 'Block_num', 'TrialInBlock', 'Trial', ...
                                         'Trial_type' 'Stimulation', ...
                                         'Stim_tactile_1', 'Stim_auditory_1', ...
                                         'Stim_tactile_2', 'Stim_auditory_2', ...
                                         'HighLow', 'Control', ...
                                         'ITIs' 'Speed' 'Completed' 'Attempts' 'Skipped' 'TrialTime'};
    
    SummaryTable = groupsummary(defTable, {'Block_num', 'Trial_type'}, @(k)sum(k>1), {'Stim_tactile_1', 'Stim_auditory_1'});

    writetable(defTable, outputpath, 'Delimiter', ',');
    disp(outputpath)
elseif numel(dir_struct) == 3 && isfile(outputpath)
    disp(outputpath)
else
    error('there are too many training files')
end


function [avg_speed, std_speed] = TakeSpeedfromLog(filepath)
    opts = delimitedTextImportOptions("NumVariables", 6);
    
    opts.DataLines = [4, Inf];
    opts.Delimiter = "\t";
    opts.VariableNames = ["Block", "Trial", "TrialType", "Stimulation", "Event_Name", "Time"];
    opts.VariableTypes = ["double", "double", "double", "double", "categorical", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, "Event_Name", "EmptyFieldRule", "auto");
    table_training = readtable(filepath, opts);
    
    velocities = table_training{table_training.Event_Name == "Velocity" & table_training.Block == 2, 6};

    avg_speed = mean(rmoutliers(velocities), 'omitnan');
    std_speed = std(rmoutliers(velocities), 'omitnan'); 

end


