clc;clear;
addpath(genpath('C:/Users/nnu02/Documents/MATLAB/spm12'));
addpath('C:/Users/nnu02/Documents/MATLAB/fieldtrip-20220827');
addpath('E:/02Data/03Utils/Functions/');
ft_defaults

subjects = ["01" "03", "04" "05" "06" "07" "08" "09" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30"];

folder = 'F:/Gian_Polina_2025/02Data';
restart_preprocessing = 0; %set to 1 for re-running all the preprocessing even when files are already saved
skip_spm = 1;

thresh_file = 'EOGthresh_vEOG_hEOG';
eogchan = ["vEOG", "hEOG"];
components_file = 'num_components_vEOG_hEOG';
prefix = ["vEOG_t", "hEOG_t"];

keep_n10 = []; 
keep_cum75 = []; 

for ID = subjects
    ID = char(ID);
        
    %Stuff for SPM
    subj_folder = strcat(folder, '/ID', ID, '/01EEG_20250606/');
    
    %copy paste the loc file
    loc_dir = strcat(folder, '/ID', ID, '/00Behavioural/neuronavigation');
    bdf_file = strcat(folder, '/ID', ID, '/01EEG/*', ID, '*.bdf');
    bdf_file = dir(bdf_file); 
    bdf_file = strcat(bdf_file.folder, '\', bdf_file.name); 
    
    out_folder = strcat(folder, '/ID', ID, '/01EEG_20250606/spm/');
    if ~exist(out_folder, 'dir')
        mkdir(out_folder)
    end
    out_file = strcat(folder, '/ID', ID, '/01EEG_20250606/spm/ID');
    
    %Stuff for FT
    caplocation = 'F:/02Data/03Utils/biosemi64.lay';
    neighbourslocation = 'F:/02Data/03Utils/biosemi64_neighb.mat';
    %Also have to write a function that automatically deletes extra info from
    %this file and copypaste it into the subj dir (under EEG and not
    %behavioural) 
    %sensorslocation = strcat('E:/02Data/01Experiment/ID', ID, '/00Behavioural/ID', ID, '_gian.sfp');
    
    %elec = ft_read_sens(sensorslocation, 'senstype', 'eeg');

    img_folder = strcat(folder, '/ID', ID, '/01EEG_20250606/images/');
    if ~exist(img_folder)
        mkdir(img_folder)
    end
    
    cd(subj_folder) %jump in the right folder
    
    %% SIMPLY LOAD THE HALFWAY PREPROCESSED DATASET
    load(strcat(subj_folder, 'vEOG_filtered_ID', ID, '.mat'))
    
    %% INSERT EVENTS (touch in general)
    cfg                         = [];
    cfg.dataset                 = bdf_file;
    cfg.trialfun                = 'ft_trialfun_general'; % this is the default
    cfg.trialdef.eventtype      = 'STATUS';
    cfg.trialdef.eventvalue     = [36 64:222]; % the values of the stimulus trigger for the three conditions
    cfg.trialdef.prestim        = 3; % in seconds
    cfg.trialdef.poststim       = 1; % in seconds
    cfg = ft_definetrial(cfg);
    events_list_EEG = cfg.event;
    trl = cfg.trl;

    unique([events_list_EEG.value])

    % ADJUST TRL
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
    TrialTable = readtable(strcat("F:\Gian_Polina_2025\02Data\ID", ID, "\00Behavioural\ID", ID, "TrialTable.csv"), opts);
    clear opts

    to_insert = find(trl(:,4) == 36); 
    for i = 1:length(to_insert)
        trl = [trl(1:to_insert(i)+i-1,:); trl(to_insert(i)+i-1:end,:)];
    end

    if length(trl) ~= 1280
        error('something is wrong!!!!!')
    end

    porcodio = []; 
    for i = 1:2:length(trl)-1
        if trl(i,4) == trl(i+1,4)
            %okay
        else
            porcodio = [porcodio i];
        end
    end

    %double check correctness of the trl and table
    for i = 1:size(TrialTable,1)
        if trl(i*2) == 64
            if TrialTable(i) ~= 1
                error('porcodio')
            end
        elseif trl(i*2) == 128
            if TrialTable(i) ~= 2
                error('Porcamadonna')
            end
        end
    end
    
    if ~isempty(porcodio)
        trl_correct = zeros(size(TrialTable,1)*2,1);
        trl_correct(1:2:end) = TrialTable.Stimulation;
        trl_correct(2:2:end) = TrialTable.Stimulation;
    
        trl_correct(trl_correct == 1) = 64; 
        trl_correct(trl_correct == 2) = 128; 
        trl_correct(trl_correct == 3) = 192; 

        for mm = 1: length(trl)
            if trl(mm,4) ~= 64 || trl(mm,4) ~= 128 || trl(mm,4) ~=192
                trl(mm,4) = trl_correct(mm);
            end
          

        end
    
        trl(setdiff(1:1280, find(trl(:,4) == 36)),4) = trl_correct(setdiff(1:1280, find(trl(:,4) == 36)));
    end
    % JUST GET THE FIRST STIMULUS OUT OF THE TWO
    trl = trl(2:2:end,:); 

    % CHECK THAT IS STILL MATCHES
    trl_to_check = trl;
    trl_to_check(trl_to_check(:,4) == 64,5) = 1;
    trl_to_check(trl_to_check(:,4) == 128,5) = 2;
    trl_to_check(trl_to_check(:,4) == 192,5) = 3;
    for i = 1:length(trl_to_check)
        if trl_to_check(i,5) == TrialTable.Stimulation(i)
            %correct
        elseif trl_to_check(i,5) == 0
            %still correct
        else
            error('something is off')
        end
    end
    
    % DOWNSAMPLE TRL
    trl(:,1:3) = round(trl(:,1:3)/4);

    % DEFINE TRIALS BASED ON ADJUSTED TRL
    cfg = [];
    cfg.trl = trl;
    data_to_clean = ft_redefinetrial(cfg, raw);

    %% Define skipped trials and no-response trials
    opts = delimitedTextImportOptions("NumVariables", 6);
    opts.DataLines = [4, Inf];
    opts.Delimiter = "\t";
    opts.VariableNames = ["Block", "Trial", "TrialType", "Stimulation", "Event_Name", "Time"];
    opts.VariableTypes = ["double", "double", "double", "double", "categorical", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts = setvaropts(opts, "Event_Name", "EmptyFieldRule", "auto");
    ExperimentLog = readtable(strcat("F:\Gian_Polina_2025\02Data\ID", ID, "\00Behavioural\Experiment_Log_ID", ID, ".txt"), opts);
    clear opts


    if ID == '02'
        ExperimentLog{find(isundefined(ExperimentLog.Event_Name)),5} = "Trial Skipped";
    end

    missed_responses = []; 
    missed_responses = find(strcmp(string(ExperimentLog.Event_Name), "no_response"));
    missed_responses = [missed_responses; find(strcmp(string(ExperimentLog.Event_Name), "Trial Skipped"))];
    
    missed_trials = (ExperimentLog.Block(missed_responses))*160+(ExperimentLog.Trial(missed_responses)+1);
    save(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606', "\missed_trials.mat"), "missed_trials")

    %% Define too long trials 
    GOs = find(ExperimentLog.Event_Name == "GO");
    GOs_Stim1 = []; 
    for i = 1:length(GOs)
        if ExperimentLog{GOs(i)+2,5} == "Stim_1"
            GOs_Stim1 = [GOs_Stim1; GOs(i), GOs(i)+2];
        end
    end

    Response_Times = ExperimentLog{GOs_Stim1(:,2),6} - ExperimentLog{GOs_Stim1(:,1),6};

    rejected_trials_RT = []; 
    rejected_trials_RT = ExperimentLog.Block(GOs_Stim1(find(Response_Times > 2500 | Response_Times < 100),1))*160 + ExperimentLog.Trial(GOs_Stim1(find(Response_Times > 2500 | Response_Times < 100),1)) + 1;

    save(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606', "\rejected_trials_RT.mat"), "rejected_trials_RT")

    %% ARTEFACTS REMOVAL
    %delete('rejected_trials.mat')
    if isfile(strcat(subj_folder, 'rejected_trials.mat'))
        load(strcat(subj_folder, 'rejected_channels.mat'))
        load(strcat(subj_folder, 'rejected_trials.mat'))
        load(strcat(subj_folder, 'missed_trials.mat'))
        load(strcat(subj_folder, 'rejected_trials_RT'))

        cfg = [];
        cfg.trials = 1:numel(data_to_clean.trialinfo);
        cfg.trials(unique([rejected_trials missed_trials' rejected_trials_RT'])) = [];
        cfg.channel = 1:64;
        indices_channels_to_remove = arrayfun(@(k) find(strncmp(rejected_channels(k),data_to_clean.label,3)), 1:length(rejected_channels));
        cfg.channel(indices_channels_to_remove) = []; 
        data = ft_selectdata(cfg, data_to_clean); 
    else
        % old_reject = load(strcat(subj_folder, 'rejected_trials_shorted.mat'));
        % old_reject = old_reject.rejected_trials_shorted; 
        rejected_channels = [];
        rejected_trials = [];

        % % % % % % % % % % % %just have a look at the data
        % % % % % % % % % % % cfg = [];
        % % % % % % % % % % % cfg.preproc.demean = 'yes';
        % % % % % % % % % % % cfg.preproc.baselinewindow = [-0.05 -0.005];
        % % % % % % % % % % % cfg.preproc.lpfilter = 'yes'; 
        % % % % % % % % % % % cfg.preproc.lpfreq = 45; 
        % % % % % % % % % % % cfg.ylim = [-20 20];
        % % % % % % % % % % % if isfile('visual.mat')
        % % % % % % % % % % %     load('visual.mat')
        % % % % % % % % % % %     cfg.artfctdef.visual.artifact = visual;
        % % % % % % % % % % % end
        % % % % % % % % % % % artf = ft_databrowser(cfg, data_to_clean);
        % % % % % % % % % % % visual = artf.artfctdef.visual.artifact;
        % % % % % % % % % % % save("visual.mat", "visual");
        % % % % % % % % % % % 
        % % % % % % % % % % % cfg = []; 
        % % % % % % % % % % % cfg.artfctdef.reject = 'complete';
        % % % % % % % % % % % cfg.artfctdef.visual.artifact = visual;
        % % % % % % % % % % % data_clean = ft_rejectartifact(cfg, data_to_clean); 

        %after you had a look at the data, repeat the procedure that you did
        %before. 
        cfg          = [];
        cfg.method   = 'summary';
        cfg.layout   = caplocation;  % for plotting individual trials
        cfg.preproc.lpfilter = 'yes';
        cfg.preproc.lpfreq = 45;
        cfg.preproc.demean = 'yes'; 
        cfg.preproc.baselinewindow = [-0.05 -0.005];
        data_clean   = ft_rejectvisual(cfg, data_to_clean);

        %same procedure as before, simply update the previously created vectors
        rejchan = setdiff(data_to_clean.label, data_clean.label);
        rejtrl = setdiff(data_to_clean.sampleinfo(:,1), data_clean.sampleinfo(:,1));
        if isempty(rejchan) == 0
            for j = 1:size(rejchan,1)
                rejected_channels = [rejected_channels string(rejchan{j,1})];
            end
        end
        if isempty(rejtrl) == 0
            for j=1:size(rejtrl,1)
                rejected_trials = [rejected_trials find(data_to_clean.sampleinfo(:,1) == rejtrl(j,1))];
            end
        end

        %perform proper trial rejection here
        load(strcat(subj_folder, 'missed_trials.mat'))
        load(strcat(subj_folder, 'rejected_trials_RT'))

        cfg = [];
        cfg.trials = 1:numel(data_to_clean.trialinfo);
        cfg.trials(unique([rejected_trials missed_trials' rejected_trials_RT'])) = [];
        cfg.channels = 1:64;
        indices_channels_to_remove = arrayfun(@(k) find(strncmp(rejected_channels(k),data_to_clean.label,3)), 1:length(rejected_channels));
        cfg.channels(indices_channels_to_remove) = [];
        data = ft_selectdata(cfg, data_to_clean); 

        save('rejected_channels.mat', 'rejected_channels');
        save('rejected_trials.mat', 'rejected_trials');
    %         save ('data_clean.mat', 'data_clean');
        clear data_clean filtered hand_cleaned raw_epoched raw 
    end

    %% PROPER INTERPOLATION
    %create yero channels where missing
    labels = data_to_clean.label; 
    load(neighbourslocation);
    [data badchan] = push_channels(data, labels);
    if length(badchan) > 0
        cfg               = [];
        cfg.method = 'spline'; 
        cfg.badchannel    = data.label(badchan);
        cfg.neighbours = neighbours;
        data = ft_channelrepair(cfg, data);
    else
        disp("NO BAD CHANNEL SELECTED DURING BAD TRIAL SELECTION")
    end

    %% REREF
    cfg = [];
    cfg.reref = 'yes';
    cfg.refchannel = 'all';
    cfg.refmethod = 'avg';
    data = ft_preprocessing(cfg, data);
    
    %% LPF
    cfg = [];
    cfg.lpfilter = 'yes';
    cfg.lpfreq = 45;
    data = ft_preprocessing(cfg, data);

    %% DENOISE PER CONDITION
    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606', "\ExperimentLog.mat"))
    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606', "\TrialTable.mat"))

    cfg = []; 
    cfg.latency = [-3 1];
    data = ft_selectdata(cfg, data);

    xx = permute(cat(3, data.trial{:}), [2 1 3]);

    Stimulation = [1 2 3];
    Move_Stay = [1 3; 2 4];
    Conditions = ["Touch_Move", "Touch_Stay", "Audio_Move", "Audio_Stay", "Control_Move", "Control_Stay"];
    counter = 0; 
    for s = 1:length(Stimulation)
        for m = 1:size(Move_Stay,2)
            counter = counter + 1; 
            cfg = []; 
            cfg.trials = find(TrialTable.Stimulation == Stimulation(s) & (TrialTable.Trial_type == Move_Stay(m,1) | TrialTable.Trial_type == Move_Stay(m,2)));
            temporary = ft_selectdata(cfg, data);
            x{counter} = permute(cat(3,temporary.trial{:}), [2 1 3]);
        end
    end

    % apply DSS to clean them
    c0=zeros(64); c1=zeros(64);
    for iCondition=1:length(Conditions)
        c0=c0+nt_cov(x{iCondition});
        c1=c1+nt_cov(mean(x{iCondition},3));
    end
    [todss,pwr0,pwr1]=nt_dss0(c0,c1);

    fromdss=pinv(todss);

    cumulative_power_perc = cumsum(pwr1)/sum(pwr1)*100;

    NKEEP = 7; 

    y=nt_mmat(xx,todss(:,1:NKEEP)*fromdss(1:NKEEP,:));

    for t = 1:length(data.trial)
        data.trial{t} = y(:,:,t)';
    end
    
    %% SAVE PREPROCESSED AND CLEANED TRIALS IN MAT FILE
    save(strcat('preprocessed_-2_2_20250606_denoise_2Stim.mat'), 'data', '-v7.3');
end

% figure; 
% bar(keep_cum75)
% title('Num components retained for each participant with cumulative power = 73%')
% xticks(1:length(subjects))
% xticklabels(subjects)
% ylim([0 15])
% 
% figure;
% bar(keep_n10)
% title('Cumulative power retained for keeping N = 7 components')
% xticks(1:length(subjects))
% xticklabels(subjects)
% ylim([0 100])

%% EXTRA FUNCTIONS
%This function will check missing channels, it will push new channels in
%the data filled with zeros (it will be needed for the interpolation
%procedure). 
function [restored badchanindx] = push_channels(data, label)
    [notmissing, dummy] = match_str(label, data.label);
    newtrial = cell(size(data.trial));
    for k = 1:numel(data.trial)
      newtrial{k} = zeros(numel(label), size(data.trial{k},2));
      newtrial{k}(notmissing,:) = data.trial{k};
    end
    goodchans   = false(numel(label),1);
    goodchans(notmissing) = true;
    badchanindx = find(goodchans==0);

    data.trial = newtrial; clear newtrial;
    data.label = label;
    restored = data;
end

function [trl trials_missing] = repair_trl(trl, ID)
    differences = diff(trl(:,1));
    missing = find(differences > 4287 & differences < 10000);
    counter = 0;
    trials_missing = []; 
    for i = 1:length(missing)
        trl = [trl(1:missing(i)+counter,:); nan(1,4); trl(missing(i)+1+counter:end,:)];
        trials_missing = [trials_missing missing(i)+1+counter]; 
        counter = counter + 1; 
    end

    missing = find(isnan(trl(:,1)));
    for i = 1:length(missing)
        trl(missing(i),1) = round(mean([trl(missing(i)-1,1) trl(missing(i)+1,1)]));
        trl(missing(i),2) = round(mean([trl(missing(i)-1,2) trl(missing(i)+1,2)]));
        trl(missing(i),3) = trl(missing(i)-1,3); 
        trl(missing(i),4) = trl(missing(i)-1,4); 
    end

    % the function also contains some adjustments that apply only to
    % specific subjects (e.g., multiple triggers were given bc of override
    % of write functions to daq card). 
    if strcmp(ID, '23')
        trials_to_delete = [1 6 7]; 
    elseif strcmp(ID, '24')
        trials_to_delete = [1001:1200];
    else
        trials_to_delete = []; 
    end
    trl(trials_to_delete,:) = [];
end
