clc;clear;
addpath(genpath('C:/Users/nnu02/Documents/MATLAB/spm12'));
addpath('C:/Users/nnu02/Documents/MATLAB/fieldtrip-20220827');
addpath('E:/02Data/03Utils/Functions/');
ft_defaults

subjects = ["01" "03", "04" "05" "06" "07" "08" "09" "11" "12" "13" "14" "15" "16" "17" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30"];

folder = 'F:/Gian_Polina_2025/02Data';
restart_preprocessing = 0; %set to 1 for re-running all the preprocessing even when files are already saved
skip_spm = 1;

thresh_file = 'EOGthresh_vEOG_hEOG';
eogchan = ["vEOG", "hEOG"];
components_file = 'num_components_vEOG_hEOG';
prefix = ["vEOG_t", "hEOG_t"];

keep_n10 = []; 
keep_cum75 = []; 
x_total = []; 
cumulative_power_perc_tot = []; 
ymean = []; 

for ID = subjects
    ID = char(ID);
        
    %Stuff for SPM
    subj_folder = strcat(folder, '/ID', ID, '/01EEG_20250606/');
        
    %Stuff for FT
    caplocation = 'F:/02Data/03Utils/biosemi64.lay';
    neighbourslocation = 'F:/02Data/03Utils/biosemi64_neighb.mat';
    %Also have to write a function that automatically deletes extra info from
    %this file and copypaste it into the subj dir (under EEG and not
    %behavioural) 
    %sensorslocation = strcat('E:/02Data/01Experiment/ID', ID, '/00Behavioural/ID', ID, '_gian.sfp');
    
    %elec = ft_read_sens(sensorslocation, 'senstype', 'eeg');

    subj_index = find(strcmp(ID, subjects)); 

    %% LOAD DATASET
    load(strcat(subj_folder, 'preprocessed_-2_2_20250606.mat'))

    load(strcat(subj_folder, 'TrialTable.mat'))
    load(strcat(subj_folder, 'ExperimentLog.mat'))

    %% DENOISE PER CONDITION
    cfg = [];
    cfg.latency = [-2 2];
    data = ft_selectdata(cfg, data);

    % cfg = [];
    % cfg.demean = 'yes';
    % cfg.baselinewindow = [-0.05 -0.005];
    % data = ft_preprocessing(cfg, data);

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
            x_total{subj_index}{counter} = x{counter}; 
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

    cumulative_power_perc_tot = [cumulative_power_perc_tot; cumulative_power_perc(1:30)];

    CUMKEEP = cumulative_power_perc(7); 
    keep_n10 = [keep_n10 CUMKEEP]; 

    NKEEP = find(cumulative_power_perc >= 73, 1); 
    keep_cum75 = [keep_cum75 NKEEP];

    % NKEEP = 10; 

    baseline_time = [999:1022];
    for NKEEP = 1:30
        for iCondition = 1:length(Conditions)
            y{iCondition}=nt_mmat(x{iCondition},todss(:,1:NKEEP)*fromdss(1:NKEEP,:));
            ymean_NKEEP{NKEEP}{subj_index}{iCondition} = mean(y{iCondition},3);
            %ymean_NKEEP{NKEEP}{subj_index}{iCondition} = ymean_NKEEP{NKEEP}{subj_index}{iCondition} - mean(ymean_NKEEP{NKEEP}{subj_index}{iCondition}(baseline_time,:),1);
        end
    end

    cum_pow = 50:1:95; 

    %cumulative power
    for CUMKEEP = cum_pow
        for iCondition = 1:length(Conditions)
            NKEEP = find(cumulative_power_perc >= CUMKEEP, 1); 
            cum_idx = find(CUMKEEP == cum_pow);
            y{iCondition}=nt_mmat(x{iCondition},todss(:,1:NKEEP)*fromdss(1:NKEEP,:));
            ymean_CUMKEEP{cum_idx}{subj_index}{iCondition} = mean(y{iCondition},3);
            %ymean_CUMKEEP{cum_idx}{subj_index}{iCondition} = ymean_CUMKEEP{cum_idx}{subj_index}{iCondition} - mean(ymean_CUMKEEP{cum_idx}{subj_index}{iCondition}(baseline_time,:),1);
        end
    end
end

iseporcodio = [];

sprintf('For keeping 7 components, %.2f cumulative power is retained (STD: %.2f)', mean(keep_n10), std(keep_n10))
sprintf('For keeping 73 perc cumulative power, %.2f components are retained (STD: %.2f)', mean(keep_cum75), std(keep_cum75))

%% CALCULATE DIFFERENCE AUDIO/TOUCH - CONTROL
figure;
time = [1:1025 1282:2048];
%time = 1:2048; 
channels = [1:64];
proportions = []; 
for nkeep = 1:length(ymean_NKEEP)
    for subj = 1:length(ymean_NKEEP{nkeep})
        Touch_Move(:,:,subj) = ymean_NKEEP{nkeep}{subj}{1};
        Touch_Stay(:,:,subj) = ymean_NKEEP{nkeep}{subj}{2};
        Audio_Move(:,:,subj) = ymean_NKEEP{nkeep}{subj}{3};
        Audio_Stay(:,:,subj) = ymean_NKEEP{nkeep}{subj}{4};
        Control_Move(:,:,subj) = ymean_NKEEP{nkeep}{subj}{5};
        Control_Stay(:,:,subj) = ymean_NKEEP{nkeep}{subj}{6};
    end
    mean_Touch_Move = mean(Touch_Move(time,channels,:),[3]);
    mean_Touch_Stay = mean(Touch_Stay(time,channels,:),[3]);
    mean_Audio_Move = mean(Audio_Move(time,channels,:),[3]);
    mean_Audio_Stay = mean(Audio_Stay(time,channels,:),[3]);
    mean_Control_Move = mean(Control_Move(time,channels,:),[3]);
    mean_Control_Stay = mean(Control_Stay(time,channels,:),[3]);

    proportion = (log((mean_Touch_Move + mean_Audio_Move)/2 ./ mean_Control_Move) + log((mean_Touch_Stay+mean_Audio_Stay)/2 ./ mean_Control_Stay))/2; 

    proportions = [proportions mean(proportion, [1 2])];
end
for subj = 1:length(ymean_CUMKEEP{1})
    Touch_Move(:,:,subj) = mean(x_total{subj}{1},3);
    Touch_Stay(:,:,subj) = mean(x_total{subj}{2},3);
    Audio_Move(:,:,subj) = mean(x_total{subj}{3},3);
    Audio_Stay(:,:,subj) = mean(x_total{subj}{4},3);
    Control_Move(:,:,subj) = mean(x_total{subj}{5},3);
    Control_Stay(:,:,subj) = mean(x_total{subj}{6},3);
end
mean_Touch_Move = mean(Touch_Move(:,:,:),[3]);
mean_Touch_Stay = mean(Touch_Stay(:,:,:),[3]);
mean_Audio_Move = mean(Audio_Move(:,:,:),[3]);
mean_Audio_Stay = mean(Audio_Stay(:,:,:),[3]);
mean_Control_Move = mean(Control_Move(:,:,:),[3]);
mean_Control_Stay = mean(Control_Stay(:,:,:),[3]);
proportion = (log((mean_Touch_Move + mean_Audio_Move)/2 ./ mean_Control_Move) + log((mean_Touch_Stay+mean_Audio_Stay)/2 ./ mean_Control_Stay))/2; 
bar(proportions);     hold on; 
bar(length(proportions)+1, mean(proportion, [1 2]), 'r')
xticks(1:length(ymean_NKEEP)+1)
xticklabels([string(1:length(ymean_NKEEP)), "Original Data"])
title('mean Log Ratio between each experimental condition and relative control condition, across channels, for time: -2.0:0.0 - 0.5:2.0. NUMBER OF COMPONENTS - TOUCH and AUDIO')


figure;
time = [1:1025 1282:2048];
%time = 1:2048; 
channels = [1:64];
proportions = []; 
for nkeep = 1:length(ymean_CUMKEEP)
    for subj = 1:length(ymean_CUMKEEP{nkeep})
        Touch_Move(:,:,subj) = ymean_CUMKEEP{nkeep}{subj}{1};
        Touch_Stay(:,:,subj) = ymean_CUMKEEP{nkeep}{subj}{2};
        Audio_Move(:,:,subj) = ymean_CUMKEEP{nkeep}{subj}{3};
        Audio_Stay(:,:,subj) = ymean_CUMKEEP{nkeep}{subj}{4};
        Control_Move(:,:,subj) = ymean_CUMKEEP{nkeep}{subj}{5};
        Control_Stay(:,:,subj) = ymean_CUMKEEP{nkeep}{subj}{6};
    end
    mean_Touch_Move = mean(Touch_Move(time,channels,:),[3]);
    mean_Touch_Stay = mean(Touch_Stay(time,channels,:),[3]);
    mean_Audio_Move = mean(Audio_Move(time,channels,:),[3]);
    mean_Audio_Stay = mean(Audio_Stay(time,channels,:),[3]);
    mean_Control_Move = mean(Control_Move(time,channels,:),[3]);
    mean_Control_Stay = mean(Control_Stay(time,channels,:),[3]);

    proportion = (log((mean_Touch_Move + mean_Audio_Move)/2 ./ mean_Control_Move) + log((mean_Touch_Stay+mean_Audio_Stay)/2 ./ mean_Control_Stay))/2; 

    proportions = [proportions mean(proportion, [1 2])];
end
for subj = 1:length(ymean_CUMKEEP{1})
    Touch_Move(:,:,subj) = mean(x_total{subj}{1},3);
    Touch_Stay(:,:,subj) = mean(x_total{subj}{2},3);
    Audio_Move(:,:,subj) = mean(x_total{subj}{3},3);
    Audio_Stay(:,:,subj) = mean(x_total{subj}{4},3);
    Control_Move(:,:,subj) = mean(x_total{subj}{5},3);
    Control_Stay(:,:,subj) = mean(x_total{subj}{6},3);
end
mean_Touch_Move = mean(Touch_Move(:,:,:),[3]);
mean_Touch_Stay = mean(Touch_Stay(:,:,:),[3]);
mean_Audio_Move = mean(Audio_Move(:,:,:),[3]);
mean_Audio_Stay = mean(Audio_Stay(:,:,:),[3]);
mean_Control_Move = mean(Control_Move(:,:,:),[3]);
mean_Control_Stay = mean(Control_Stay(:,:,:),[3]);
proportion = (log((mean_Touch_Move + mean_Audio_Move)/2 ./ mean_Control_Move) + log((mean_Touch_Stay+mean_Audio_Stay)/2 ./ mean_Control_Stay))/2; 
bar(proportions);     hold on; 
bar(length(proportions)+1, mean(proportion, [1 2]), 'r')
xticks(1:length(ymean_CUMKEEP)+1)
xticklabels([string(cum_pow), "Original Data"])
title('mean Log Ratio between each experimental condition and relative control condition, across channels, for time: -2.0:0.0 - 0.5:2.0. CUMULATIVE POWER - TOUCH and AUDIO')
