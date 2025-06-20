clc;clear;
addpath(genpath('C:/Users/nnu02/Documents/MATLAB/spm12'));
addpath('C:/Users/nnu02/Documents/MATLAB/fieldtrip-20220827');
addpath('E:/02Data/03Utils/Functions/');
ft_defaults

subjects = ["01" "03", "04" "05" "06" "07" "08" "09" "11" "12" "13" "14" "15" "16" "17" "18" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30"];
subjects = ["19"];

folder = 'F:/Gian_Polina_2025/02Data';
restart_preprocessing = 1; %set to 1 for re-running all the preprocessing even when files are already saved
skip_spm = 0;

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
    
    %% PART 2 Import data from .bdf datastructure into ft .mat format
%     if isfile(strcat(eogchan, '_filtered_ID', ID, '.mat'))
%         load(strcat(eogchan, '_filtered_ID', ID, '.mat'));
%         labels = raw.label(1:64);
%     else
    
    if (double(~exist(strcat(subj_folder, 'vEOG_filtered_ID', ID, '.mat'))) + restart_preprocessing) > 0
        if ~exist(strcat(subj_folder, 'spm/hdMID', ID, '.mat')) | skip_spm == 0
            addpath(genpath('C:/Users/nnu02/Documents/MATLAB/spm12'));
            cd('spm')
    %         sfp2mat(loc_dir, 'ID');
            %load montage
            load('E:/Gian/GG_SensAtt_Prediction/02Data/ID100/avref_combEOG.mat');
    %         D = biosemi2spm(bdf_file, out_file);
    
            %% FIRST MAKE SURE THAT THERE ARE NO BAD CHANS BEFORE MONTAGE (rerefering)
            cfg = [];
            cfg.dataset = bdf_file;
            origin_file = ft_preprocessing(cfg);
            labels = origin_file.label;

            %realign elec
            elec = ft_read_sens(char(strcat(loc_dir, '/Gian_Polina_ID', ID, '.sfp')), 'senstype', 'eeg');
            % middle = 0; 
            % extremes = (abs(elec.chanpos(1,1)) + abs(elec.chanpos(2,1)))/2;
            % cfg               = [];
            % cfg.target.pos(1,:) = [0 elec.chanpos(3,2) 0];     % location of the nose
            % cfg.target.pos(2,:) = [-extremes 0 0];     % location of the left ear
            % cfg.target.pos(3,:) = [extremes 0 0];     % location of the right ear
            % % cfg.target.pos(2,:) = [elec.chanpos(1,1) 0 0];     % location of the left ear
            % % cfg.target.pos(3,:) = [elec.chanpos(2,1) 0 0];     % location of the right ear
            % 
            % cfg.target.label    = {'fidnz', 'fidt9', 'fidt10'};
            % cfg.method        = 'template';
            % cfg.elec          = elec;
            % cfg.warp = 'rigidbody';
            % cfg.fiducial      = {'fidnz', 'fidt9', 'fidt10'};  % labels of fiducials in fid and in elec
            % elec_aligned      = ft_electroderealign(cfg);

       
            if isfile(strcat(subj_folder, 'bad_chan_manual.mat'))
                load(strcat(subj_folder, 'bad_chan_manual.mat'));
            else
                trl = [];
                cfg                         = [];
                cfg.dataset                 = bdf_file;
                cfg.trialfun                = 'ft_trialfun_general'; % this is the default
                cfg.trialdef.eventtype      = 'STATUS';
                cfg.trialdef.eventvalue     = [128 64 192 36]; % the values of the stimulus trigger for the three conditions
                cfg.trialdef.prestim        = 2.5; % in seconds
                cfg.trialdef.poststim       = 2.5; % in seconds
                cfg = ft_definetrial(cfg);
                events_list_EEG = cfg.event;

                trl = cfg.trl; 
                indices = find(trl(:,4) == 64  | trl(:,4) == 128  | trl(:,4) == 192);
                indices = indices(2:2:length(indices)); 
                trl(indices,:) = []; 

                cfg = [];
                cfg.trl = trl;
                origin_epoched = ft_redefinetrial(cfg, origin_file);

                cfg = [];
                cfg.preproc.demean = 'yes';
                cfg.preproc.lpfilter = 'yes'; 
                cfg.preproc.lpfreq = 45; 
                cfg.ylim = [-20 20];
                ft_databrowser(cfg, origin_epoched);
    
                cfg          = [];
                cfg.method   = 'summary';
                cfg.layout   = caplocation;  % for plotting individual trials
                hand_cleaned   = ft_rejectvisual(cfg, origin_epoched);
            
                bad_chan_manual = setdiff(labels, hand_cleaned.label);
            %     noisy_channels_manual = labels(noisy_channels_manual);
                save(strcat(subj_folder, 'bad_chan_manual.mat'), "bad_chan_manual");
            end

            origin_file.elec = elec; 
    
            load(neighbourslocation)
            if length(bad_chan_manual) > 0
                cfg               = [];
                cfg.method = 'spline';
                cfg.badchannel    = bad_chan_manual;
                cfg.neighbours = neighbours;
            %     cfg.neighbourdist = 4;
            %     cfg.elec = elec;
                origin_file_corr = ft_channelrepair(cfg, origin_file);
            else
                origin_file_corr = origin_file;
            end

            %D = spm_eeg_ft2spm(origin_file_corr, strcat('ID', ID));

            %% RUN MOST OF THE PREPROCESSING IN FIELDTRIP BC IS BETTER
            cfg = []; 
            cfg.resamplefs = 512;
            %cfg.detrend = 'no'; 
            origin_file_corr = ft_resampledata(cfg, origin_file_corr); 
            origin_file_corr.hdr.Fs = cfg.resamplefs; 

            total_length = size(origin_file_corr.trial{1,1},2)/origin_file_corr.fsample; 

            cfg = [];
            cfg.hpfilter = 'yes'; 
            cfg.hpfilttype = 'firws';
            % cfg.hpinstabilityfix = 'reduce';
            cfg.padding = total_length+100*2;
            cfg.hpfreq = 0.1; 
            origin_file_corr = ft_preprocessing(cfg, origin_file_corr); %HPF is done in fieldtrip 

            %% THEN CONVERT OUR CORRECTED FILE INTO SPM FORMAT
            S = [];
            S.dataset = bdf_file;
            S.outfile = char(strcat(out_file, ID)); 
            D = spm_eeg_convert(S);

            %downsample
            S = [];
            S.D = D;
            S.fsample_new = 512;
            S.prefix = 'dM';
            D = spm_eeg_downsample(S);

            D(1:64,:) = origin_file_corr.trial{1,1}(1:64,:); %push the HPF data from fieldtrip into SPM structure and continue preprocessing from there. 

            %montage
            S = [];
            S.D = D;
            S.mode = 'write';
            S.montage = montage;
            S.prefix = 'h';
            D = spm_eeg_montage(S);

            if isfile(strcat(folder, '/ID', ID, '/00Behavioural/neuronavigation/Gian_Polina_ID', ID, '.sfp'))
                %convert spf to mat
                sfp2mat(loc_dir, 'ID')

                elec = ft_read_sens(char(strcat(loc_dir, '/Gian_Polina_ID', ID, '.sfp')), 'senstype', 'eeg');
                % middle = 0; 
                % extremes = (abs(elec.chanpos(1,1)) + abs(elec.chanpos(2,1)))/2;
                % cfg               = [];
                % cfg.target.pos(1,:) = [0 elec.chanpos(3,2) 0];     % location of the nose
                % cfg.target.pos(2,:) = [-extremes 0 0];     % location of the left ear
                % cfg.target.pos(3,:) = [extremes 0 0];     % location of the right ear
                % % cfg.target.pos(2,:) = [elec.chanpos(1,1) 0 0];     % location of the left ear
                % % cfg.target.pos(3,:) = [elec.chanpos(2,1) 0 0];     % location of the right ear
                % 
                % cfg.target.label    = {'fidnz', 'fidt9', 'fidt10'};
                % cfg.method        = 'template';
                % cfg.elec          = elec;
                % cfg.warp = 'rigidbody';
                % cfg.fiducial      = {'fidnz', 'fidt9', 'fidt10'};  % labels of fiducials in fid and in elec
                % elec_aligned      = ft_electroderealign(cfg);
                % 
                % fidus = elec_aligned.chanpos(1:3,:);
                % elpos = elec_aligned.chanpos(4:end,:); 
                % save(fullfile(loc_dir, 'mat', ['ID' ID 'fid_realigned.mat']), "fidus")
                % save(fullfile(loc_dir, 'mat', ['ID' ID 'pos_realigned.mat']), "elpos")

                
                %insert eeg default locations
                S = [];
                S.D = D;
                S.sensfile = fullfile(loc_dir, 'mat', ['ID' ID 'pos.mat']);
                S.source = 'mat';
                S.headshapefile = fullfile(loc_dir, 'mat', ['ID' ID 'fid.mat']);
                S.fidlabel = 'lpa rpa nas';
                S.task = 'loadeegsens';
                S.save = 1;
                D = spm_eeg_prep(S);
                fprintf('using subject-specific elec')
            else
                %insert eeg default locations
                S = [];
                S.D = D;
                S.task = 'defaulteegsens';
                %S.source = 'locfile';
                %S.sensfile = strcat(folder, '/ID', ID, '/00Behavioural/neuronavigation/Gian_ID', ID, '.sfp');
                S.save = 1;
                D = spm_eeg_prep(S);
                fprintf('using default elec')
            end

        [xy, label] = spm_eeg_project3D(D.sensors('eeg'), 'EEG');
        % figure; plot(xy(1,:), xy(2,:))

        S = []; 
        S.task = 'setcoor2d';
        S.D = D; 
        S.xy = xy;
        S.label = label;
        S.save = 1;
        S.modality = 'EEG';
        D = spm_eeg_prep(S); 

        Cel = []; 
        x = []; 
        y = []; 
        [Cel, x, y]  = spm_eeg_locate_channels(D, 32, [1:64]);
        
        timeind = D.indsample(1e-3*(0)):D.indsample(1e-3*(500));
        chanind = D.selectchannels('EEG');
        dataind = {chanind, timeind};
        trialind = D.indtrial('Undefined', 'GOOD');
        
        %set indices for sampling from dataset
        
        trial = 1;
        Y = []; 
        Y = subsref(D, struct('type', '()', 'subs', {[dataind, {trialind(trial)}]}));
        
        n = 32; 
        
        for j = 1:size(Y,2)
            YY = NaN(n,n);
            YY(sub2ind([n n], x, y)) = griddata(Cel(:,1),Cel(:,2),...
                double(Y(:, j)), x, y,'linear');
        end
        
        matrix = []; 
        matrix = isnan(YY);
        figure; pcolor(matrix)
        exportgraphics(gcf, strcat(img_folder,  'mask.png'))
        close all
    
        figure; plot(Cel(:,1), Cel(:,2), 'o')
        exportgraphics(gcf, strcat(img_folder,  '2Delecs.png'))
        close all

        elecs = sensors(D, 'eeg');
        fids = fiducials(D);
        figure; plot3(fids.fid.pnt(1:3,1), fids.fid.pnt(1:3,2), fids.fid.pnt(1:3,3), 'ro'); 
        hold on; plot3(elecs.chanpos(:,1), elecs.chanpos(:,2), elecs.chanpos(:,3), 'b*');
        view([180 0])
        exportgraphics(gcf, strcat(img_folder,  '180_3Delecs.png'))
        view([90 0])
        exportgraphics(gcf, strcat(img_folder,  '90_3Delecs.png'))
        close all


        else
            addpath(genpath('C:/Users/nnu02/Documents/MATLAB/spm12'));
            cd('spm')
            D = spm_eeg_load(strcat('hdMID', ID, '.mat'));
        end            

        %% EOG Stuff
        thresh = []; 
        num_components = []; 
        for eyes = 1:2
           if eyes == 1
               D = spm_eeg_load(strcat('hdMID', ID, '.mat'));
           else
               D = spm_eeg_load(strcat('vEOG_thdMID', ID, '.mat'));
               D = sensors(D, 'eeg', rmfield(sensors(D, 'eeg'), 'tra'));
           end
           if isfile(strcat(folder, '/ID', ID, '/01EEG_20250606/',thresh_file,'.mat'))
               load(strcat(folder, '/ID', ID, '/01EEG_20250606/',thresh_file,'.mat'))
           end

           if thresh(eyes) == 0
               display("We decided to skip this eye movement correction")
               S = []; 
               S.D = D; 
               S.outfile = strcat(char(prefix(eyes)), fname(D));
               D = spm_eeg_copy(S); 
           else
               if isfile(strcat(folder, '/ID', ID, '/01EEG_20250606/',thresh_file,'.mat'))
                    load(strcat(folder, '/ID', ID, '/01EEG_20250606/',thresh_file,'.mat'))
                    load(strcat(folder, '/ID', ID, '/01EEG_20250606/EOG_direction_h_movement.mat'))
        
                    S = [];
                    S.D = D;
                    S.eogchan = {char(eogchan(eyes))};
                    S.stdthresh= thresh(eyes);
                    S.overwrite = 1;
                    S.direction_h_movement = direction_h;
                    D_ebf = spm_eeg_detect_eyeblinks_GIAN(S);
                else
                    thresh(eyes) = 5;
                    direction_h = 2; 
    
                    S = [];
                    S.D = D;
                    S.eogchan = {char(eogchan(eyes))};
                    S.stdthresh= thresh(eyes);
                    S.overwrite = 1;
                    S.direction_h_movement = direction_h;
                    D_ebf = spm_eeg_detect_eyeblinks_GIAN(S);
        
                    if eyes == 2
                        save(strcat(folder, '/ID', ID, '/01EEG_20250606/',thresh_file,'.mat'), 'thresh');
                        save(strcat(folder, '/ID', ID, '/01EEG_20250606/EOG_direction_h_movement.mat'), 'direction_h');
                    end
                end
                %export img
                exportgraphics(gcf, strcat(img_folder,  '_', eogchan(eyes), 'epochs.png'))
                close all
                if eyes == 1
                    before_corr = squeeze(D_ebf([1:5 33:38 65 66],:,:)); 
                end
        
                %% Remove eye blinks
                if isfile(strcat(folder, '/ID', ID, '/01EEG_20250606/',components_file,'.mat'))
                    load(strcat(folder, '/ID', ID, '/01EEG_20250606/',components_file,'.mat'))
                    compute_eye_blink_components(D_ebf, num_components(eyes)); 
                else
                    num_components(eyes) = 2; 
                    compute_eye_blink_components(D_ebf, num_components(eyes)); 
                    if eyes == 2
                        save(strcat(folder, '/ID', ID, '/01EEG_20250606/', components_file,'.mat'), 'num_components')
                    end
                end
    
                exportgraphics(gcf, strcat(img_folder, '_', eogchan(eyes), 'components_topo.png'))
                close
                exportgraphics(gcf, strcat(img_folder, '_', eogchan(eyes), 'components_ERP.png'))
                close

                try
                    D = rmfield(D, 'inv');
                catch
                end
        
                try
                    % remove any spatial confounds file if present the meeg object
                    S           = [];
                    S.D         = D;
                    S.method    = 'CLEAR';
                    D = spm_eeg_spatial_confounds(S);
                catch
                end
                % add the spatial confound to the meeg object
                S           = [];
                S.D         = D;
                S.method    = 'SPMEEG';
                S.conffile  = 'ebf_conf.mat';
                D = spm_eeg_spatial_confounds(S);
                
                % correct for the spatial confounds (Berg and Scherg)
                S               = [];
                S.D             = D;
                S.correction    = 'Berg';
                S.prefix        = char(prefix(eyes));
                MRI_pos = dir(strcat('F:/Gian_Polina_2025/02Data/ID', ID, '/05Anat/*nii')); 
                S.sMRI = strcat(MRI_pos(1).folder, filesep, MRI_pos(1).name); 
                D = spm_eeg_correct_sensor_data(S);
                
                close all
           end
           if eyes == 1
                after_vEOG_corr = squeeze(D([1:5 33:38 65 66],:,:));
           elseif eyes == 2
                after_hEOG_corr = squeeze(D([1:5 33:38 65 66],:,:));
           end
        end

        %% plot before and after imgs
        load('vEOG_spikes.mat')
        vEOG_spikes = spikes; 
        try
            load('hEOG_spikes.mat')
            hEOG_spikes = spikes; 
        catch
            hEOG_spikes = vEOG_spikes; 
        end

        %select a random point in the hEOG spikes
        if exist("spike_pos.mat")
            load("spike_pos.mat")
        else
            h_EOG_pos = 10;
            save("spike_pos.mat", "h_EOG_pos")
        end
        %select a matching vEOG spike that is close to that
        [value v_EOG_pos] = min(abs(vEOG_spikes - hEOG_spikes(h_EOG_pos)));

        center = round((vEOG_spikes(v_EOG_pos) + hEOG_spikes(h_EOG_pos))/2);
        window_spikes = [center-5000 : center+5000];

        %plot before correction
        multichanplot(before_corr(:,window_spikes)', 10000, 'ylim', [-60 60])
        exportgraphics(gcf, strcat(img_folder, '_before_EOGCorr.png'))
        close
        %plot after vEOG corr
        multichanplot(after_vEOG_corr(:,window_spikes)', 10000, 'ylim', [-60 60])
        exportgraphics(gcf, strcat(img_folder, '_after_vEOGCorr.png'))
        close
        %plot after hEOG corr
        multichanplot(after_hEOG_corr(:,window_spikes)', 10000, 'ylim', [-60 60])
        exportgraphics(gcf, strcat(img_folder, '_after_hEOGCorr.png'))
        close
        
        %% Convert spm D object into fieldtrip data format
        %Remove Matlab path otherwise it gets in contrast with fieldtrip proper
        %functions
        rmpath(genpath('C:/Users/nnu02/Documents/MATLAB/spm12'));
        
        cfg = [];
        cfg.dataset = strcat('hEOG_tvEOG_thdMID', ID, '.mat');
        raw = ft_preprocessing(cfg);
        labels = raw.label(1:64);
        
        cfg = [];
        cfg.channel = labels;
        raw = ft_selectdata(cfg, raw);
        
        cd .. %go back in the main folder and save data
        save(strcat('vEOG_filtered_ID', ID, '.mat'), "raw");
    else
        load(strcat(subj_folder, 'vEOG_filtered_ID', ID, '.mat'))
    end
    
    %% INSERT EVENTS (touch in general)
    cfg                         = [];
    cfg.dataset                 = bdf_file;
    cfg.trialfun                = 'ft_trialfun_general'; % this is the default
    cfg.trialdef.eventtype      = 'STATUS';
    cfg.trialdef.eventvalue     = [36 64:222]; % the values of the stimulus trigger for the three conditions
    cfg.trialdef.prestim        = 2; % in seconds
    cfg.trialdef.poststim       = 2; % in seconds
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
    trl = trl(1:2:end,:); 

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
    
    %% SAVE PREPROCESSED AND CLEANED TRIALS IN MAT FILE
    save(strcat('preprocessed_-2_2_20250606.mat'), 'data', '-v7.3');
end


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
