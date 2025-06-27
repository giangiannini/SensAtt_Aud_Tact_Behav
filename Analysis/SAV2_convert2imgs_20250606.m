function [] = SAV2_convert2imgs_20250606(ID)    
    ID = char(ID); 

    subj_folder = strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606/');
    
    load([subj_folder, '/preprocessed_-2_2_20250606_denoise.mat']);

    %adjust for time bc SPM is picky
    cfg = []; 
    cfg.latency = [-2 2];
    data = ft_selectdata(cfg, data);

    %% CONVERT TO IMAGES
    D_notpreprocessed = spm_eeg_load([subj_folder, '/spm/hEOG_tvEOG_thdMID', ID, '.mat']);

    S = []; 
    S.D = D_notpreprocessed; 
    S.bc = 0; 
    S.trl = [data.sampleinfo repmat(-[find(data.time{1,1}==0)-1], length(data.sampleinfo),1)]; 
    S.conditionlabels = 'undefined';
    S.prefix = 'subjective_';
    D_epoched = spm_eeg_epochs(S);
    warning('spm epoch has worked')
        
    %insert eeg default locations
    S = [];
    S.D = D_epoched;
    S.sensfile = strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\00Behavioural\neuronavigation\mat\ID', ID, 'pos.mat');
    S.source = 'mat';
    S.headshapefile = strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\00Behavioural\neuronavigation\mat\ID', ID, 'fid.mat');
    S.fidlabel = 'lpa rpa nas';
    S.task = 'loadeegsens';
    S.save = 1;
    D_epoched = spm_eeg_prep(S);
    fprintf('using subject-specific elec')

    [xy, label] = spm_eeg_project3D(D_epoched.sensors('eeg'), 'EEG');

    S = [];
    S.task = 'setcoor2d';
    S.D = D_epoched;
    S.xy = xy;
    S.label = label;
    S.save = 1;
    S.modality = 'EEG';
    D_epoched = spm_eeg_prep(S); 

    cfg = [];
    cfg.demean = 'yes';
    cfg.baselinewindow = [-0.05 -0.005];
    data_baselined = ft_preprocessing(cfg, data);

    %Convert Post_stimulus
    [conds{1:length(data_baselined.trial)}] = deal('data_denoise_subjective');
    D_epoched = conditions(D_epoched, ':', conds);
    D_epoched(1:64,:,:) = cat(3,data_baselined.trial{:});
    D_epoched.save(); 
    %and convert everything 
    S = [];
    S.D = D_epoched;
    S.timewin = [-50 500];
    S.mode = 'scalp x time';
    S.channels = {'EEG'};
    prova = spm_eeg_convert2images_jh(S);
    % sprintf('Image conversion post-stim completed ... smoothing!')
    % P = [subj_folder, '/evEOG_thdMID' ID '/post_stimulus_subjective_position_realigned.nii'];
    % Q = [subj_folder, '/evEOG_thdMID' ID '/12_12_0_post_stimulus_subjective_position_realigned.nii'];
    % s = [12 12 0];
    % spm_smooth(P,Q,s)
    % sprintf('Smoothing post-stim completed')
end
