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

    %% LOAD THE PREPROCESSED FILE
    load(strcat(subj_folder, 'preprocessed_-2_2_20250606.mat'))

    %% APPLY DENOISING AND CHOOSE THE NUMBER OF COMPONENTS TO KEEP BASED ON a_preprocessing_SA_V2_20250606_nkeep_denoising FUNCTION
    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606', "\ExperimentLog.mat"))
    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606', "\TrialTable.mat"))

    cfg = []; 
    cfg.latency = [-2 2];
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

    NKEEP = 7; 
    
    y=nt_mmat(xx,todss(:,1:NKEEP)*fromdss(1:NKEEP,:));

    for t = 1:length(data.trial)
        data.trial{t} = y(:,:,t)';
    end
    
    %% SAVE PREPROCESSED AND CLEANED TRIALS IN MAT FILE
    save(strcat('preprocessed_-2_2_20250606_denoise.mat'), 'data', '-v7.3');

end