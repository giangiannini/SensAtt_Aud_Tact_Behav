%% z_ERP_analyses_group

%% SETUP 
clear; clc; 

subjects = ["01" "03", "04" "05" "06" "07" "08" "09" "11" "12" "13" "14" "15" "16" "17" "18" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30"];
%subjects = ["03", "04" "05" "06" "07" "08" "09" "12" "13" "14" "15" "16" "18" "20" "21" "22" "23" "24" "25" "26" "28" "29" "30"];
%subjects = ["03", "04" "05" "06" "11" "12" "17" "20"  "24" "26" "27" "28" "29"];
%subjects = ["01", "03", "04" "05" "08" "09" "12" "13" "14" "16" "17" "18" "20" "21" "22" "23" "26" "27" "28" "29" "30"];
all_ERPs = []; 
for i = 1:length(subjects)

    ID = char(subjects(i)); 
    caplocation = 'F:/02Data/03Utils/biosemi64.lay';
    
    %% LOAD EEG PREPROCESSED DATA
    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606\preprocessed_-2_2_20250606_denoise.mat')); %evenThoughiscalled 01 it's actually 0.5 HPF

    cfg = []; 
    cfg.demean = 'yes'; 
    cfg.baselinewindow = [-0.05 -0.005];
    data_baselined = ft_preprocessing(cfg, data); 

    %% LOAD log and trial tables and adjust them 
    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606', "\ExperimentLog.mat"))
    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606', "\TrialTable.mat"))

    %% MAIN EFF TOUCH 
    cfg = []; 
    cfg.trials = find(TrialTable.Stimulation == 1);
    all_ERPs.Touch{i} = ft_timelockanalysis(cfg, data_baselined); 

    %% MAIN EFF AUDITION
    cfg = []; 
    cfg.trials = find(TrialTable.Stimulation == 2);
    all_ERPs.Audio{i} = ft_timelockanalysis(cfg, data_baselined); 

    %% TOUCH Effect across move and stay
    cfg = []; 
    cfg.trials = find(TrialTable.Stimulation == 1 & (TrialTable.Trial_type == 1 | TrialTable.Trial_type == 3));
    all_ERPs.Touch_Move{i} = ft_timelockanalysis(cfg, data_baselined); 
    
    cfg = []; 
    cfg.trials = find(TrialTable.Stimulation == 1 & (TrialTable.Trial_type == 2 | TrialTable.Trial_type == 4));
    all_ERPs.Touch_Stay{i} = ft_timelockanalysis(cfg, data_baselined); 

    %% AUDITION Effect across move and stay
    cfg = []; 
    cfg.trials = find(TrialTable.Stimulation == 2 & (TrialTable.Trial_type == 1 | TrialTable.Trial_type == 3));
    all_ERPs.Audio_Move{i} = ft_timelockanalysis(cfg, data_baselined); 
    
    cfg = []; 
    cfg.trials = find(TrialTable.Stimulation == 2 & (TrialTable.Trial_type == 2 | TrialTable.Trial_type == 4));
    all_ERPs.Audio_Stay{i} = ft_timelockanalysis(cfg, data_baselined); 

    %% CONTROL Effect across move and stay
    cfg = []; 
    cfg.trials = find(TrialTable.Stimulation == 3 & (TrialTable.Trial_type == 1 | TrialTable.Trial_type == 3));
    all_ERPs.Control_Move{i} = ft_timelockanalysis(cfg, data_baselined); 
    
    cfg = []; 
    cfg.trials = find(TrialTable.Stimulation == 3 & (TrialTable.Trial_type == 2 | TrialTable.Trial_type == 4));
    all_ERPs.Control_Stay{i} = ft_timelockanalysis(cfg, data_baselined); 
end

%% SET FOLDER TO EXPORT PLOTS 
img_folder = 'F:\Gian_Polina_2025\02Data\00EEGDescriptives';

%% PLOT RTs HIST
% tot_delays = []; 
% for i = 1:length(subjects)
%     ID = char(subjects(i)); 
%     subj_folder = strcat(folder, '/ID', ID, '/01EEG/');
%     cd(subj_folder); 
%     load('list_conditions.mat')
%     load('movement_delays.mat')
%     tot_delays = [tot_delays; diff];
% end
% 
% tot_delays = 0 - tot_delays./2048; 
% 
% figure('Renderer', 'painters', 'Position', [10 10 900 600])
% histogram(tot_delays, 'NumBins', 100, 'FaceColor', 'k')
% xlim([-2 1])
% set(gca,'XTick',[])
% set(gca,'YTick',[])
% exportgraphics(gcf, strcat(img_folder, '/RTs_hist.emf'))
% exportgraphics(gcf, strcat(img_folder, '/RTs_hist.png'))
% close all

%% PLOT FULL IMAGE
cfg = [];
Touch = ft_timelockgrandaverage(cfg, all_ERPs.Touch{:});
Audio = ft_timelockgrandaverage(cfg, all_ERPs.Audio{:});
Touch_Move = ft_timelockgrandaverage(cfg, all_ERPs.Touch_Move{:});
Touch_Stay = ft_timelockgrandaverage(cfg, all_ERPs.Touch_Stay{:});
Audio_Move = ft_timelockgrandaverage(cfg, all_ERPs.Audio_Move{:});
Audio_Stay = ft_timelockgrandaverage(cfg, all_ERPs.Audio_Stay{:});
Control_Move = ft_timelockgrandaverage(cfg, all_ERPs.Control_Move{:});
Control_Stay = ft_timelockgrandaverage(cfg, all_ERPs.Control_Stay{:});

Touch.err = sqrt(Touch.var) ./ sqrt(Touch.dof); 
Audio.err = sqrt(Audio.var) ./ sqrt(Audio.dof); 
Touch_Move.err = sqrt(Touch_Move.var) ./ sqrt(Touch_Move.dof); 
Touch_Stay.err = sqrt(Touch_Stay.var) ./ sqrt(Touch_Stay.dof); 
Audio_Move.err = sqrt(Audio_Move.var) ./ sqrt(Audio_Move.dof); 
Audio_Stay.err = sqrt(Audio_Stay.var) ./ sqrt(Audio_Stay.dof); 
Control_Move.err = sqrt(Control_Move.var) ./ sqrt(Control_Move.dof); 
Control_Stay.err = sqrt(Control_Stay.var) ./ sqrt(Control_Stay.dof); 

%% PLOT ALL DATA
colors = [255 60 54; ... %stay T
         136 255 72; ... %move T
         175 0 23; ...  %stay A
         0 135 65; ... %move A
         136 136 136; ... %stay C
         102 102 102]/255; %move C


cfg = [];
cfg.layout = caplocation;
cfg.colors = colors; 
cfg.linestyle = {'-', '-', '-', '-', '-', '-'};
%cfg.channel = [9 10 11 12 19 32 33 34 48 49 56];
cfg.xlim = [-2 1];
cfg.ylim = [-1 5];
%cfg.ylim = [-3.66 4.33];
%cfg.channel = [11 12 19 32 46 47 48 49 56];
cfg.channel = ["C1", "CP1", "CPz", "Cz"];
cfg.channel = ["FC3", "FC1", "C1", "C3", "CP3", "CP1", "P1", "P3", "Pz", ...
               "CPz", "FC2", "FCz", "Cz", "C2", "CP2", "P2"];
%cfg.channel = [14 15];
cfg.printlayers = 1;
cfg.output_printlayers = strcat(img_folder, '/big_epoch_groupERPs');
GIAN_plot_data(cfg, Touch_Stay, Touch_Move, Audio_Stay, Audio_Move, Control_Stay, Control_Move);
exportgraphics(gcf, strcat(img_folder, '/big_epoch_groupERPs.emf'))
exportgraphics(gcf, strcat(img_folder, '/big_epoch_groupERPs.png'))
close all

cfg.output_printlayers = strcat(img_folder, '/small_epoch_groupERPs');
cfg.xlim = [-0.2 0.5];
cfg.ylim = [-1 3.5];
GIAN_plot_data(cfg, Touch_Stay, Touch_Move, Audio_Stay, Audio_Move, Control_Stay, Control_Move);
exportgraphics(gcf, strcat(img_folder, '/small_epoch_groupERPs.emf'))
exportgraphics(gcf, strcat(img_folder, '/small_epoch_groupERPs.png'))
close all


%% plot layout
cfg = []; 
cfg.layout = caplocation; 
layout = ft_prepare_layout(cfg); 

cfg.channel = ["FC3", "FC1", "C1", "C3", "CP3", "CP1", "P1", "P3", "Pz", ...
               "CPz", "FC2", "FCz", "Cz", "C2", "CP2", "P2"];
index = arrayfun(@(k) find(strncmp(cfg.channel(k),data.label,3)), 1:length(cfg.channel));
figure('Renderer', 'painters', 'Position', [10 10 500 500])
plot(layout.pos(1:64,1), layout.pos(1:64,2), 'ko');
hold on
plot(layout.outline{1}(:,1), layout.outline{1}(:,2), 'k-');
plot(layout.pos(index,1), layout.pos(index,2), 'ko', 'MarkerFaceColor', [0 0 0], 'LineWidth', 5);
xlim([-0.6 0.6])
ylim([-0.6 0.6])
set(gcf, 'color', 'none')
exportgraphics(gcf, strcat(img_folder, '/layout.emf'))
exportgraphics(gcf, strcat(img_folder, '/layout.png'))
close all

%% PLOT EFF OF TOUCH
cfg = []; 
cfg.operation = '((x1 - x2)+(x3-x4))/2';
cfg.parameter = {'avg'}; 
prova = ft_math(cfg, Touch_Move, Control_Move, Touch_Stay, Control_Stay); 

%plot butterfly plot manually
figure('Renderer', 'painters', 'Position', [10 10 900 600])
for i = 1:64
    plot(prova.time, prova.avg(i,:), "Color", [101 96 92]/255, 'LineStyle','-')
    % plot(Touch.time, Touch.avg(i,:), "Color", [1 0 0], 'LineStyle','-')
    % plot(noTouch.time, noTouch.avg(i,:), "Color", [0 0 1], 'LineStyle','-')
    hold on
end
xlim([-0.2 0.5])

xline(0.085)
xline(0.2)
%xline(0.20)
%xline(0.25)
%xline(0.35)
exportgraphics(gcf, strcat(img_folder, '/Touch_butterfly.emf'))
close all

%P100
cfg = []; 
cfg.layout = caplocation; 
cfg.xlim = [0.084 0.086];
cfg.comment = 'no';
cfg.zlim = [-2 2]; 
cfg.marker = 'off';
ft_topoplotER(cfg, prova)
exportgraphics(gcf, strcat(img_folder, '/Touch_topo_100.emf'))
close all


%P200
cfg = []; 
cfg.layout = caplocation; 
cfg.xlim = [0.199 0.201];
cfg.comment = 'no';
cfg.zlim = [-2 2];
cfg.marker = 'off';
ft_topoplotER(cfg, prova)
exportgraphics(gcf, strcat(img_folder, '/Touch_topo_200.emf'))
close all

%% PLOT EFF OF AUDIO
cfg = []; 
cfg.operation = '((x1 - x2)+(x3-x4))/2';
cfg.parameter = {'avg'}; 
prova = ft_math(cfg, Audio_Move, Control_Move, Audio_Stay, Control_Stay); 

%plot butterfly plot manually
figure('Renderer', 'painters', 'Position', [10 10 900 600])
for i = 1:64
    plot(prova.time, prova.avg(i,:), "Color", [101 96 92]/255, 'LineStyle','-')
    % plot(Touch.time, Touch.avg(i,:), "Color", [1 0 0], 'LineStyle','-')
    % plot(noTouch.time, noTouch.avg(i,:), "Color", [0 0 1], 'LineStyle','-')
    hold on
end
xlim([-0.2 0.5])

xline(0.1)
xline(0.18)
%xline(0.20)
%xline(0.35)
exportgraphics(gcf, strcat(img_folder, '/Audio_butterfly.emf'))
close all

%N100
cfg = []; 
cfg.layout = caplocation; 
cfg.xlim = [0.099 0.101];
cfg.comment = 'no';
cfg.zlim = [-2 2]; 
cfg.marker = 'off';
ft_topoplotER(cfg, prova)
exportgraphics(gcf, strcat(img_folder, '/Audio_topo_100.emf'))
close all


%P200
cfg = []; 
cfg.layout = caplocation; 
cfg.xlim = [0.179 0.181];
cfg.comment = 'no';
cfg.zlim = [-2 2];
cfg.marker = 'off';
%cfg.colorbar = 'yes'; 
ft_topoplotER(cfg, prova)
exportgraphics(gcf, strcat(img_folder, '/Audio_topo_200.emf'))
close all
