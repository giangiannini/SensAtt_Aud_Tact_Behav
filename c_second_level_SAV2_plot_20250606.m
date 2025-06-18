clear;clc;
addpath(genpath('C:/Users/nnu02/Documents/MATLAB/spm12'));
addpath('C:/Users/nnu02/Documents/MATLAB/fieldtrip-20220827');
ft_defaults

subjects = ["01" "03" "04" "05" "06" "07" "08" "09" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30"];

folder = 'F:/Gian_Polina_2025/02Data/';

prefix = []; 
suffixes = ["_denoise_subjective"]; 

%first make sure that subject average is there
if ~isfile('F:\Gian_Polina_2025\02Data\00GroupAnalyses\grand_mean.mat')
    S = []; 
    for i = 1:length(subjects)
        ID = char(subjects(i)); 
        subj_folder = strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606\');
    
        D = spm_eeg_load(strcat(subj_folder, '\spm\subjective_hEOG_tvEOG_thdMID', ID, '.mat')); 
    
        conds = []; 
        [conds{1:size(D,3)}] = deal('data_denoise_subjective');
        
        load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606\TrialTable.mat'));
        
        %Insert conditions
        [conds{TrialTable.Stimulation == 1 & (TrialTable.Trial_type == 1 | TrialTable.Trial_type == 3)}] = deal('Touch_Move');
        [conds{TrialTable.Stimulation == 1 & (TrialTable.Trial_type == 2 | TrialTable.Trial_type == 4)}] = deal('Touch_Stay');
        [conds{TrialTable.Stimulation == 2 & (TrialTable.Trial_type == 1 | TrialTable.Trial_type == 3)}] = deal('Audio_Move');
        [conds{TrialTable.Stimulation == 2 & (TrialTable.Trial_type == 2 | TrialTable.Trial_type == 4)}] = deal('Audio_Stay');
        [conds{TrialTable.Stimulation == 3 & (TrialTable.Trial_type == 1 | TrialTable.Trial_type == 3)}] = deal('Control_Move');
        [conds{TrialTable.Stimulation == 3 & (TrialTable.Trial_type == 2 | TrialTable.Trial_type == 4)}] = deal('Control_Stay');
        D = conditions(D, ':', conds);
        D.save(); 
    
        cfg = []; 
        cfg.D = D; 
        spm_eeg_average(cfg); 
    
        D_location = strcat(subj_folder, '\spm\msubjective_hEOG_tvEOG_thdMID', ID, '.mat');
    
        S.D(i,:) = D_location; 
    end
    
    spm_eeg_grandmean(S)
    
    D = spm_eeg_load('F:\Gian_Polina_2025\02Data\ID01\01EEG_20250606\spm\grand_mean.mat');
    D.copy('F:\Gian_Polina_2025\02Data\00GroupAnalyses\grand_mean.mat')
end

%Then start extracting stuff
for mm = 1:length(suffixes)
    
    suffix = suffixes(mm);

    %Set second level folder for main eff post-stim
    results_second_level_Touch = strcat(folder, '00GroupAnalyses/', prefix, '20250606_Touch', suffix);
    results_second_level_Audio = strcat(folder, '00GroupAnalyses/', prefix, '20250606_Audio', suffix);
    
    %% PLOT IMGS!
    beta = [];
    for ID = subjects
        ID = char(ID);
        
        index_for_storing = find(strcmp(ID, subjects));
        
        verbose = 0; %specify whether you want each preproc step printed in a ps file (yes = 1; no = 0);
        notch = 0;
        
        %Stuff for SPM
        subj_folder = strcat(folder, '/ID', ID, '/01EEG_20250606/');
    
        %Stuff for FT
        caplocation = 'F:/02Data/03Utils/biosemi64.lay';
        neighbourslocation = 'F:/02Data/03Utils/biosemi64_neighb.mat';
    
        %Define first level where betas are stored
        first_level_folder = strcat(folder, 'ID', ID, '/02FirstLevel/');
        results_first_level = strcat(first_level_folder, prefix, '20250606', suffix);
    
        %% LOAD DATASET AND REJ TRIALS
        if strcmp(ID, '01')
            load(strcat(subj_folder, 'preprocessed_-2_2_20250606_denoise.mat'))
    
            %create structure to store data from imgs
            cfg = [];
            cfg.channel = 1:64;
            cfg.latency = [-0.05 0.5];
            data = ft_selectdata(cfg, data);
            cfg = [];
            ERP = ft_timelockanalysis(cfg, data);
        end
    
        %% IMPORT BETA IMAGES FOR PLOTTING
        for i = 1:6
            order_scans = ["Touch_Move", "Touch_Stay", "Audio_Move", "Audio_Stay", "Control_Move", "Control_Stay"];     
            name = order_scans(i); 
            beta.(name){index_for_storing} = ERP;
            beta.(name){index_for_storing}.avg = gian_extract_SPM_images(strcat(results_first_level, '/beta_000', num2str(i), '.nii'), strcat(folder, 'ID', ID, '\00Behavioural\neuronavigation\mat\ID', ID, 'pos.mat'));
            %beta.(name){index_for_storing}.avg = gian_extract_SPM_images(strcat(results_first_level, '/beta_000', num2str(i), '.nii'), coor2D(spm_eeg_load('F:\Gian_Polina_2025\02Data\00GroupAnalyses\grand_mean.mat')));
        end
    
        % %% IMPORT CON IMAGES FOR PLOTTING
        for i = 3:6
            order_scans = ["Touch_Move_Control", "Touch_Stay_Control", "Audio_Move_Control", "Audio_Stay_Control"];     
            name = order_scans(i-2);
            con.(name){index_for_storing} = ERP;
            con.(name){index_for_storing}.avg = gian_extract_SPM_images(strcat(results_first_level, '/con_000', num2str(i), '.nii'), strcat(folder, 'ID', ID, '\00Behavioural\neuronavigation\mat\ID', ID, 'pos.mat'));
            %con.(name){index_for_storing}.avg = gian_extract_SPM_images(strcat(results_first_level, '/con_000', num2str(i), '.nii'), coor2D(spm_eeg_load('F:\Gian_Polina_2025\02Data\00GroupAnalyses\grand_mean.mat')));
        end
    end
    
    %% beta imgs
    cfg = [];
    Touch_Move = ft_timelockgrandaverage(cfg, beta.Touch_Move{:});
    Touch_Stay = ft_timelockgrandaverage(cfg, beta.Touch_Stay{:});
    Audio_Move = ft_timelockgrandaverage(cfg, beta.Audio_Move{:});
    Audio_Stay = ft_timelockgrandaverage(cfg, beta.Audio_Stay{:});
    Control_Move = ft_timelockgrandaverage(cfg, beta.Control_Move{:});
    Control_Stay = ft_timelockgrandaverage(cfg, beta.Control_Stay{:});
    
    %calculate error term
    Touch_Move.err = sqrt(Touch_Move.var) ./ sqrt(Touch_Move.dof); 
    Touch_Stay.err = sqrt(Touch_Stay.var) ./ sqrt(Touch_Stay.dof); 
    Audio_Move.err = sqrt(Audio_Move.var) ./ sqrt(Audio_Move.dof); 
    Audio_Stay.err = sqrt(Audio_Stay.var) ./ sqrt(Audio_Stay.dof); 
    Control_Move.err = sqrt(Control_Move.var) ./ sqrt(Control_Move.dof); 
    Control_Stay.err = sqrt(Control_Stay.var) ./ sqrt(Control_Stay.dof); 
    
    %con imgs
    cfg = []; 
    con_Touch_Move_Control = ft_timelockgrandaverage(cfg, con.Touch_Move_Control{:});
    con_Touch_Stay_Control = ft_timelockgrandaverage(cfg, con.Touch_Stay_Control{:});
    con_Audio_Move_Control = ft_timelockgrandaverage(cfg, con.Audio_Move_Control{:});
    con_Audio_Stay_Control = ft_timelockgrandaverage(cfg, con.Audio_Stay_Control{:});
    
    con_Touch_Move_Control.err = sqrt(con_Touch_Move_Control.var) ./ sqrt(con_Touch_Move_Control.dof); 
    con_Touch_Stay_Control.err = sqrt(con_Touch_Stay_Control.var) ./ sqrt(con_Touch_Stay_Control.dof); 
    con_Audio_Move_Control.err = sqrt(con_Audio_Move_Control.var) ./ sqrt(con_Audio_Move_Control.dof); 
    con_Audio_Stay_Control.err = sqrt(con_Audio_Stay_Control.var) ./ sqrt(con_Audio_Stay_Control.dof); 
    
    %% PLOT INTERACTION TOUCH x CONTROL
    %create folder for imgs
    img_folder = strcat(results_second_level_Touch, '/00results_interaction_Touch_x_Control');
    if ~exist(img_folder)
        mkdir(img_folder)
    end
    
    %Extract image from cluster
    load(strcat(results_second_level_Touch, '/SPM.mat'))
    spm('defaults', 'EEG')
    matlabbatch{1}.spm.stats.results.spmmat = cellstr(strcat(results_second_level_Touch, '/SPM.mat'));
    matlabbatch{1}.spm.stats.results.conspec.titlestr = '';
    matlabbatch{1}.spm.stats.results.conspec.contrasts = 3;
    matlabbatch{1}.spm.stats.results.conspec.threshdesc = 'none';
    matlabbatch{1}.spm.stats.results.conspec.thresh = 0.001;
    matlabbatch{1}.spm.stats.results.conspec.extent = 0;
    matlabbatch{1}.spm.stats.results.conspec.conjunction = 1;
    matlabbatch{1}.spm.stats.results.conspec.mask.none = 1;
    matlabbatch{1}.spm.stats.results.units = 2;
    matlabbatch{1}.spm.stats.results.export{1}.nary.basename = 'Int_Touch_Control';
    spm_jobman('run', matlabbatch); 
    clear matlabbatch
    
    [clust_chans times centroid time_centroid true_mask] = gian_extract_channels_from_cluster(strcat(results_second_level_Touch, '/spmF_0003_Int_Touch_Control.nii'), 'spmF_0003.nii',1);
    
    cfg = []; 
    cfg.layout = caplocation; 
    layout = ft_prepare_layout(cfg);
    
    for cluster_num = 1:length(clust_chans)
        %create mask for plotting
        % [porcodio porcamadonna] = find(Touch_Move_EqualProb.label == clust_chans{cluster_num});
        % mask = zeros(size(Touch_Move_EqualProb.avg,1), size(Touch_Move_EqualProb.avg,2));
        % mask(porcodio,times{cluster_num}) = 1; 
    
    
        % singleplot beta whole cluster
        cfg = []; 
        cfg.colors = [0, 128, 0; ... %rich green
              215, 38, 56; ... %deep red
              166, 215, 91; ... %Lime Green
              233, 150, 58]/255; %Soft Orange;
        cfg.linestyle = {'-', '-', '-', '-'};
        cfg.layout = caplocation;
        cfg.mask = true_mask{cluster_num};
        cfg.channel = clust_chans{cluster_num};
        %cfg.channel = "CP1"
        %cfg.baseline = [-0.05 -0.005];
        cfg.xlim = [-0.05 0.5];
        cfg.ylim = [-1.5 2.5];
        GIAN_plot_data(cfg, Touch_Move, Touch_Stay, Control_Move, Control_Stay)
        exportgraphics(gcf, strcat(img_folder, '/singleplot_betas_cluster', int2str(cluster_num), '.emf'))
        close all
    
        % singleplot con whole cluster
        cfg = []; 
        cfg.colors = [0, 128, 0; ... %rich green
                      215, 38, 56]/255; %deep red
        cfg.linestyle = {'-', '-'};
        cfg.layout = caplocation;
        cfg.channel = clust_chans{cluster_num};
        cfg.mask = true_mask{cluster_num};
        %cfg.baseline = [-0.05 -0.005];
        cfg.xlim = [-0.05 0.5];
        cfg.ylim = [-1.5 2.5];
        %cfg.printlayers = 1;
        %cfg.output_printlayers = strcat(img_folder, '/singleplot_cons_cluster', int2str(cluster_num));
        GIAN_plot_data(cfg, con_Touch_Move_Control, con_Touch_Stay_Control)
        exportgraphics(gcf, strcat(img_folder, '/singleplot_cons_cluster', int2str(cluster_num), '.emf'))
        close all
    
        % singleplot beta centroid
        cfg = []; 
        cfg.colors = [0, 128, 0; ... %rich green
              215, 38, 56; ... %deep red
              166, 215, 91; ... %Lime Green
              233, 150, 58]/255; %Soft Orange;
        cfg.linestyle = {'-', '-', '-', '-'};
        cfg.layout = caplocation;
        cfg.mask = true_mask{cluster_num};
        cfg.channel = centroid{cluster_num};
        %cfg.channel = "CP1"
        %cfg.baseline = [-0.05 -0.005];
        cfg.xlim = [-0.05 0.5];
        cfg.ylim = [-1.5 2.5];
        GIAN_plot_data(cfg, Touch_Move, Touch_Stay, Control_Move, Control_Stay)
        exportgraphics(gcf, strcat(img_folder, '/singleplot_betas_centroid', int2str(cluster_num), '.emf'))
        close all
    
        % singleplot con centroid
        cfg = []; 
        cfg.colors = [0, 128, 0; ... %rich green
                      215, 38, 56]/255; %deep red
        cfg.linestyle = {'-', '-', '-'};
        cfg.layout = caplocation;
        cfg.channel = centroid{cluster_num};
        cfg.mask = true_mask{cluster_num};
        %cfg.baseline = [-0.05 -0.005];
        cfg.xlim = [-0.05 0.5];
        cfg.ylim = [-1.5 2.5];
        % cfg.printlayers = 1;
        % cfg.output_printlayers = strcat(img_folder, '/singleplot_cons_centroid', int2str(cluster_num));
        GIAN_plot_data(cfg, con_Touch_Move_Control, con_Touch_Stay_Control)
        exportgraphics(gcf, strcat(img_folder, '/singleplot_cons_centroid', int2str(cluster_num), '.emf'))
        close all
    
        %topoplot centroid
        cfg = [];
        cfg.operation = '(x1*(1) + x2*(-1)) + (x3*(-1) + x4*(1))';
        cfg.parameter = 'avg';
        prova_prosciutto = ft_math(cfg, Touch_Move, Touch_Stay, Control_Move, Control_Stay); 
        timelims = Touch_Move.time(times{cluster_num}); 
        cfg = [];
        cfg.layout = caplocation;
        %cfg.baseline = [-0.05 -0.005];
        cfg.xlim = [Touch_Move.time(time_centroid{cluster_num})-0.005 Touch_Move.time(time_centroid{cluster_num})+0.005];
        cfg.zlim = [-1 1];
        cfg.colorbar = 'no'; 
        cfg.marker = 'off';
        ft_topoplotER(cfg, prova_prosciutto);
        hold on
        index = arrayfun(@(k) find(strncmp(centroid{cluster_num}{k},data.label,3)), 1:length(centroid{cluster_num}));
        for i = 1:length(index)
            plot(layout.pos(index(i),1),layout.pos(index(i),2),'o', 'Color', [0 0 0], 'MarkerSize', 30, 'MarkerFaceColor', [1 1 1], 'LineWidth', 3)
        end
        set(gcf,'units','normalized','outerpos',[0 0 1 1.2]);    
        exportgraphics(gcf, strcat(img_folder, '/topoplot_centroid', int2str(cluster_num), '.emf'))
        close all
    
        %topoplot cluster
        cfg = [];
        cfg.layout = caplocation;
        %cfg.baseline = [-0.05 -0.005];
        cfg.xlim = [Touch_Move.time(times{cluster_num}(1)) Touch_Move.time(times{cluster_num}(end))];
        cfg.zlim = [-1 1];
        cfg.colorbar = 'no';
        cfg.marker = 'off';
        ft_topoplotER(cfg, prova_prosciutto);
        hold on
        index = arrayfun(@(k) find(strncmp(clust_chans{cluster_num}{k},data.label,3)), 1:length(clust_chans{cluster_num}));
        for i = 1:length(index)
            plot(layout.pos(index(i),1),layout.pos(index(i),2),'o', 'Color', [0 0 0], 'MarkerSize', 30, 'MarkerFaceColor', [1 1 1], 'LineWidth', 3)
        end
        set(gcf,'units','normalized','outerpos',[0 0 1 1.2]);    
        exportgraphics(gcf, strcat(img_folder, '/topoplot_cluster', int2str(cluster_num), '.emf'))
        close all
    
        if cluster_num == 1
            %topoplot over time
            cfg = [];
            cfg.layout = caplocation;
            %cfg.baseline = [-0.05 -0.005];
            cfg.xlim = [0:0.025:0.5];
            cfg.zlim = [-1 1];
            cfg.marker = 'off';
            ft_topoplotER(cfg, prova_prosciutto)
            set(gcf,'units','normalized','outerpos',[0 0 1 1.2]);    
            exportgraphics(gcf, strcat(img_folder, '/topoplot_timedetail', int2str(cluster_num), '.emf'))
            close all
        end
    
        %topoplot sequence, significant electrodes highligthed. 
        % try
        %     prova_crudo = prova_prosciutto;
        %     prova_crudo.avg((true_mask{cluster_num}==0)) = nan;
        %     cfg = [];
        %     cfg.layout = caplocation;
        %     %cfg.baseline = [-0.05 -0.005];
        %     cfg.xlim = [0 min(timelims):((max(timelims)-min(timelims))/5):max(timelims) 0.5];
        %     cfg.zlim = [-1 1];
        %     cfg.colormap = '*RdBu';
        %     ft_topoplotER(cfg, prova_crudo)
        %     set(gcf,'units','normalized','outerpos',[0 0 1 1.2]);    
        %     exportgraphics(gcf, strcat(img_folder, '/topoplot_timedetail_cluster', int2str(cluster_num), '.emf'))
        %     close all
        % end
    
        %multiplot betas
        figure;
        Touch_Move.mask = true_mask{cluster_num}; 
        cfg = []; 
        cfg.linecolor = [0, 128, 0; ... %rich green
                      215, 38, 56; ... %deep red
                      166, 215, 91; ... %Lime Green
                      233, 150, 58]/255; %Soft Orange;
        cfg.layout = caplocation;
        %cfg.baseline = [-0.05 -0.005];
        cfg.maskparameter = 'mask';
        cfg.maskfacealpha = 0.2;
        ft_multiplotER(cfg, Touch_Move, Touch_Stay, Control_Move, Control_Stay)
        set(gcf,'units','normalized','outerpos',[0 0 1 1.2]);    
        exportgraphics(gcf, strcat(img_folder, '/multiplot_beta_cluster', int2str(cluster_num), '.emf'))
        close all
    
        %multiplot cons
        figure;
        con_Touch_Move_Control.mask = true_mask{cluster_num}; 
        cfg = []; 
        cfg.linecolor = [0, 128, 0; ... %rich green
                      215, 38, 56]/255; %deep red
        cfg.layout = caplocation;
        cfg.maskparameter = 'mask';
        cfg.maskfacealpha = 0.2;
        ft_multiplotER(cfg, con_Touch_Move_Control, con_Touch_Stay_Control)
        set(gcf,'units','normalized','outerpos',[0 0 1 1.2]);    
        exportgraphics(gcf, strcat(img_folder, '/multiplot_cons_cluster', int2str(cluster_num), '.emf'))
        close all
    
        %barplot cluster
        index = arrayfun(@(k) find(strncmp(clust_chans{cluster_num}{k},data.label,3)), 1:length(clust_chans{cluster_num}));
        order_scans = ["Touch_Move", "Touch_Stay", "Control_Move", "Control_Stay"]; 
        bar_values = []; 
        for i = 1:length(order_scans)
            values = []; 
            for y = 1:length(subjects)
                values = [values mean(beta.(order_scans(i)){y}.avg(index, times{cluster_num}), [1 2])];
            end
            bar_values.(order_scans(i)).mean = mean(values); 
            bar_values.(order_scans(i)).var = var(values); 
        end
     
        colors_to_plot = [0, 128, 0; ... %rich green
                      215, 38, 56; ... %deep red
                      166, 215, 91; ... %Lime Green
                      233, 150, 58]/255;%Soft Orange
        figure;
        hold on
        for i = 1:4
            aaa = bar(i, bar_values.(order_scans(i)).mean, 'FaceColor', colors_to_plot(i,:), 'BarWidth',1, 'FaceAlpha', 1);
            errorbar([i],  bar_values.(order_scans(i)).mean, sqrt(bar_values.(order_scans(i)).var)/sqrt(length(subjects)),'k','LineWidth', 0.5,'linestyle','none','HandleVisibility','off'); 
        end
        set(gca,'xticklabel',{[]})
        set(gca,'xtick',[])
        ylim([0 3])
        exportgraphics(gcf, strcat(img_folder, '/barplot_wholemask_cluster', int2str(cluster_num), '.emf'))
        close all
    
    
        %barplot centroid
        index = arrayfun(@(k) find(strncmp(centroid{cluster_num}{k},data.label,3)), 1:length(centroid{cluster_num}));
        order_scans = ["Touch_Move", "Touch_Stay", "Control_Move", "Control_Stay"]; 
        bar_values = []; 
        for i = 1:length(order_scans)
            values = []; 
            for y = 1:length(subjects)
                values = [values mean(beta.(order_scans(i)){y}.avg(index, time_centroid{cluster_num}), [1 2])];
            end
            bar_values.(order_scans(i)).mean = mean(values); 
            bar_values.(order_scans(i)).var = var(values); 
        end
     
        colors_to_plot = [0, 128, 0; ... %rich green
                      215, 38, 56; ... %deep red
                      166, 215, 91; ... %Lime Green
                      233, 150, 58]/255;%Soft Orange
        
        figure; 
        hold on
        for i = 1:4
            aaa = bar(i, bar_values.(order_scans(i)).mean, 'FaceColor', colors_to_plot(i,:), 'BarWidth',1, 'FaceAlpha', 1);
            errorbar([i],  bar_values.(order_scans(i)).mean, sqrt(bar_values.(order_scans(i)).var)/sqrt(length(subjects)),'k','LineWidth', 0.5,'linestyle','none','HandleVisibility','off'); 
        end
        set(gca,'xticklabel',{[]})
        set(gca,'xtick',[])
        ylim([0 3])
        exportgraphics(gcf, strcat(img_folder, '/barplot_wholemask_centroid', int2str(cluster_num), '.emf'))
        close all
    end
    
    %% PLOT INTERACTION AUDIO x CONTROL
    %create folder for imgs
    img_folder = strcat(results_second_level_Audio, '/00results_interaction_Audio_x_Control');
    if ~exist(img_folder)
        mkdir(img_folder)
    end
    
    %Extract image from cluster
    load(strcat(results_second_level_Audio, '/SPM.mat'))
    spm('defaults', 'EEG')
    matlabbatch{1}.spm.stats.results.spmmat = cellstr(strcat(results_second_level_Audio, '/SPM.mat'));
    matlabbatch{1}.spm.stats.results.conspec.titlestr = '';
    matlabbatch{1}.spm.stats.results.conspec.contrasts = 3;
    matlabbatch{1}.spm.stats.results.conspec.threshdesc = 'none';
    matlabbatch{1}.spm.stats.results.conspec.thresh = 0.001;
    matlabbatch{1}.spm.stats.results.conspec.extent = 0;
    matlabbatch{1}.spm.stats.results.conspec.conjunction = 1;
    matlabbatch{1}.spm.stats.results.conspec.mask.none = 1;
    matlabbatch{1}.spm.stats.results.units = 2;
    matlabbatch{1}.spm.stats.results.export{1}.nary.basename = 'Int_Audio_Control';
    spm_jobman('run', matlabbatch); 
    clear matlabbatch
    
    [clust_chans times centroid time_centroid true_mask] = gian_extract_channels_from_cluster(strcat(results_second_level_Audio, '/spmF_0003_Int_Audio_Control.nii'), 'spmF_0003.nii',2);
    
    cfg = []; 
    cfg.layout = caplocation; 
    layout = ft_prepare_layout(cfg);
    
    for cluster_num = 1:length(clust_chans)
        % singleplot beta whole cluster
        cfg = []; 
        cfg.colors = [0, 109, 91; ... %dark teal green
                      168, 51, 61; ... %muted red
                      166, 215, 91; ...%Lime Green
                      233, 150, 58]/255; %Soft Orange
        cfg.linestyle = {'-', '-', '-', '-'};
        cfg.layout = caplocation;
        cfg.mask = true_mask{cluster_num};
        cfg.channel = clust_chans{cluster_num};
        %cfg.channel = "CP1"
        %cfg.baseline = [-0.05 -0.005];
        cfg.xlim = [-0.05 0.5];
        cfg.ylim = [-1.5 2.5];
        GIAN_plot_data(cfg, Audio_Move, Audio_Stay, Control_Move, Control_Stay)
        exportgraphics(gcf, strcat(img_folder, '/singleplot_betas_cluster', int2str(cluster_num), '.emf'))
        close all
    
        % singleplot con whole cluster
        cfg = []; 
        cfg.colors = [0, 109, 91; ... %dark teal green
                      168, 51, 61]/255; %muted red
        cfg.linestyle = {'-', '-'};
        cfg.layout = caplocation;
        cfg.channel = clust_chans{cluster_num};
        cfg.mask = true_mask{cluster_num};
        %cfg.baseline = [-0.05 -0.005];
        cfg.xlim = [-0.05 0.5];
        cfg.ylim = [-1.5 2.5];
        %cfg.printlayers = 1;
        %cfg.output_printlayers = strcat(img_folder, '/singleplot_cons_cluster', int2str(cluster_num));
        GIAN_plot_data(cfg, con_Audio_Move_Control, con_Audio_Stay_Control)
        exportgraphics(gcf, strcat(img_folder, '/singleplot_cons_cluster', int2str(cluster_num), '.emf'))
        close all
    
        % singleplot beta centroid
        cfg = []; 
        cfg.colors = [0, 109, 91; ... %dark teal green
                      168, 51, 61; ... %muted red
                      166, 215, 91; ...%Lime Green
                      233, 150, 58]/255; %Soft Orange
        cfg.linestyle = {'-', '-', '-', '-'};
        cfg.layout = caplocation;
        cfg.mask = true_mask{cluster_num};
        cfg.channel = centroid{cluster_num};
        %cfg.channel = "CP1"
        %cfg.baseline = [-0.05 -0.005];
        cfg.xlim = [-0.05 0.5];
        cfg.ylim = [-1.5 2.5];
        GIAN_plot_data(cfg, Audio_Move, Audio_Stay, Control_Move, Control_Stay)
        exportgraphics(gcf, strcat(img_folder, '/singleplot_betas_centroid', int2str(cluster_num), '.emf'))
        close all
    
        % singleplot con centroid
        cfg = []; 
        cfg.colors = [0, 109, 91; ... %dark teal green
                      168, 51, 61]/255; %muted red
        cfg.linestyle = {'-', '-', '-'};
        cfg.layout = caplocation;
        cfg.channel = centroid{cluster_num};
        cfg.mask = true_mask{cluster_num};
        %cfg.baseline = [-0.05 -0.005];
        cfg.xlim = [-0.05 0.5];
        cfg.ylim = [-1.5 2.5];
        % cfg.printlayers = 1;
        % cfg.output_printlayers = strcat(img_folder, '/singleplot_cons_centroid', int2str(cluster_num));
        GIAN_plot_data(cfg, con_Audio_Move_Control, con_Audio_Stay_Control)
        exportgraphics(gcf, strcat(img_folder, '/singleplot_cons_centroid', int2str(cluster_num), '.emf'))
        close all
    
        %topoplot centroid
        cfg = [];
        cfg.operation = '(x1*(1) + x2*(-1)) + (x3*(-1) + x4*(1))';
        cfg.parameter = 'avg';
        prova_prosciutto = ft_math(cfg, Audio_Move, Audio_Stay, Control_Move, Control_Stay); 
        timelims = Audio_Move.time(times{cluster_num}); 
        cfg = [];
        cfg.layout = caplocation;
        %cfg.baseline = [-0.05 -0.005];
        cfg.xlim = [Audio_Move.time(time_centroid{cluster_num})-0.005 Audio_Move.time(time_centroid{cluster_num})+0.005];
        cfg.zlim = [-1 1];
        cfg.colorbar = 'no'; 
        cfg.marker = 'off';
        ft_topoplotER(cfg, prova_prosciutto);
        hold on
        index = arrayfun(@(k) find(strncmp(centroid{cluster_num}{k},data.label,3)), 1:length(centroid{cluster_num}));
        for i = 1:length(index)
            plot(layout.pos(index(i),1),layout.pos(index(i),2),'o', 'Color', [0 0 0], 'MarkerSize', 30, 'MarkerFaceColor', [1 1 1], 'LineWidth', 3)
        end
        set(gcf,'units','normalized','outerpos',[0 0 1 1.2]);    
        exportgraphics(gcf, strcat(img_folder, '/topoplot_centroid', int2str(cluster_num), '.emf'))
        close all
    
        %topoplot cluster
        cfg = [];
        cfg.layout = caplocation;
        %cfg.baseline = [-0.05 -0.005];
        cfg.xlim = [Audio_Move.time(times{cluster_num}(1)) Audio_Move.time(times{cluster_num}(end))];
        cfg.zlim = [-1 1];
        cfg.colorbar = 'no'; 
        cfg.marker = 'off';
        ft_topoplotER(cfg, prova_prosciutto);
        hold on
        index = arrayfun(@(k) find(strncmp(clust_chans{cluster_num}{k},data.label,3)), 1:length(clust_chans{cluster_num}));
        for i = 1:length(index)
            plot(layout.pos(index(i),1),layout.pos(index(i),2),'o', 'Color', [0 0 0], 'MarkerSize', 30, 'MarkerFaceColor', [1 1 1], 'LineWidth', 3)
        end
        set(gcf,'units','normalized','outerpos',[0 0 1 1.2]);    
        exportgraphics(gcf, strcat(img_folder, '/topoplot_cluster', int2str(cluster_num), '.emf'))
        close all
    
        if cluster_num == 1
            %topoplot over time
            cfg = [];
            cfg.layout = caplocation;
            %cfg.baseline = [-0.05 -0.005];
            cfg.xlim = [0:0.025:0.5];
            cfg.zlim = [-1 1];
            cfg.marker = 'off';
            ft_topoplotER(cfg, prova_prosciutto)
            set(gcf,'units','normalized','outerpos',[0 0 1 1.2]);    
            exportgraphics(gcf, strcat(img_folder, '/topoplot_timedetail', int2str(cluster_num), '.emf'))
            close all
        end
    
        %topoplot sequence, significant electrodes highligthed. 
        % try
        %     prova_crudo = prova_prosciutto;
        %     prova_crudo.avg((true_mask{cluster_num}==0)) = nan;
        %     cfg = [];
        %     cfg.layout = caplocation;
        %     %cfg.baseline = [-0.05 -0.005];
        %     cfg.xlim = [0 min(timelims):((max(timelims)-min(timelims))/5):max(timelims) 0.5];
        %     cfg.zlim = [-1 1];
        %     cfg.colormap = '*RdBu';
        %     ft_topoplotER(cfg, prova_crudo)
        %     set(gcf,'units','normalized','outerpos',[0 0 1 1.2]);    
        %     exportgraphics(gcf, strcat(img_folder, '/topoplot_timedetail_cluster', int2str(cluster_num), '.emf'))
        %     close all
        % end
    
        %multiplot betas
        figure;
        Audio_Move.mask = true_mask{cluster_num}; 
        cfg = []; 
        cfg.linecolor = [0, 0, 1; ... %blue
                        0.4, 0.4, 1; ... %light blue
                        0.7, 0.7, 1; ... %very light blue
                        1, 0, 0; ... %red
                        1, 0.4, 0.4 %light red
                        1, 0.7, 0.7]; %very light red
        cfg.layout = caplocation;
        %cfg.baseline = [-0.05 -0.005];
        cfg.maskparameter = 'mask';
        cfg.maskfacealpha = 0.2;
        set(gcf,'units','normalized','outerpos',[0 0 1 1.2]);    
        ft_multiplotER(cfg, Audio_Move, Audio_Stay, Control_Move, Control_Stay)
        exportgraphics(gcf, strcat(img_folder, '/multiplot_beta_cluster', int2str(cluster_num), '.emf'))
        close all
    
        %multiplot cons
        figure;
        con_Audio_Move_Control.mask = true_mask{cluster_num}; 
        cfg = []; 
        cfg.linecolor = [1, 0, 0; ... %red
                        1, 0.4, 0.4 %light red
                        1, 0.7, 0.7]; %very light red
        cfg.layout = caplocation;
        %cfg.baseline = [-0.05 -0.005];
        cfg.maskparameter = 'mask';
        cfg.maskfacealpha = 0.2;
        set(gcf,'units','normalized','outerpos',[0 0 1 1.2]);    
        ft_multiplotER(cfg, con_Audio_Move_Control, con_Audio_Stay_Control)
        exportgraphics(gcf, strcat(img_folder, '/multiplot_cons_cluster', int2str(cluster_num), '.emf'))
        close all
    
        %barplot cluster
        index = arrayfun(@(k) find(strncmp(clust_chans{cluster_num}{k},data.label,3)), 1:length(clust_chans{cluster_num}));
        order_scans = ["Audio_Move", "Audio_Stay", "Control_Move", "Control_Stay"]; 
        bar_values = []; 
        for i = 1:length(order_scans)
            values = []; 
            for y = 1:length(subjects)
                values = [values mean(beta.(order_scans(i)){y}.avg(index, times{cluster_num}), [1 2])];
            end
            bar_values.(order_scans(i)).mean = mean(values); 
            bar_values.(order_scans(i)).var = var(values); 
        end
     
        colors_to_plot = [0, 109, 91; ... %dark teal green
                      168, 51, 61; ... %muted red
                      166, 215, 91; ... %Lime Green
                      233, 150, 58]/255;%Soft Orange
        figure;
        hold on
        for i = 1:4
            aaa = bar(i, bar_values.(order_scans(i)).mean, 'FaceColor', colors_to_plot(i,:), 'BarWidth',1, 'FaceAlpha', 1);
            errorbar([i],  bar_values.(order_scans(i)).mean, sqrt(bar_values.(order_scans(i)).var)/sqrt(length(subjects)),'k','LineWidth', 0.5,'linestyle','none','HandleVisibility','off'); 
        end
        set(gca,'xticklabel',{[]})
        set(gca,'xtick',[])
        ylim([0 3])
        exportgraphics(gcf, strcat(img_folder, '/barplot_wholemask_cluster', int2str(cluster_num), '.emf'))
        close all
    
    
        %barplot centroid
        index = arrayfun(@(k) find(strncmp(centroid{cluster_num}{k},data.label,3)), 1:length(centroid{cluster_num}));
        order_scans = ["Audio_Move", "Audio_Stay", "Control_Move", "Control_Stay"]; 
        bar_values = []; 
        for i = 1:length(order_scans)
            values = []; 
            for y = 1:length(subjects)
                values = [values mean(beta.(order_scans(i)){y}.avg(index, time_centroid{cluster_num}), [1 2])];
            end
            bar_values.(order_scans(i)).mean = mean(values); 
            bar_values.(order_scans(i)).var = var(values); 
        end
     
        colors_to_plot = [0, 109, 91; ... %dark teal green
                      168, 51, 61; ... %muted red
                      166, 215, 91; ... %Lime Green
                      233, 150, 58]/255;%Soft Orange
        figure; 
        hold on
        for i = 1:4
            aaa = bar(i, bar_values.(order_scans(i)).mean, 'FaceColor', colors_to_plot(i,:), 'BarWidth',1, 'FaceAlpha', 1);
            errorbar([i],  bar_values.(order_scans(i)).mean, sqrt(bar_values.(order_scans(i)).var)/sqrt(length(subjects)),'k','LineWidth', 0.5,'linestyle','none','HandleVisibility','off'); 
        end
        set(gca,'xticklabel',{[]})
        set(gca,'xtick',[])
        ylim([0 3])
        exportgraphics(gcf, strcat(img_folder, '/barplot_wholemask_centroid', int2str(cluster_num), '.emf'))
        close all
    end
end
