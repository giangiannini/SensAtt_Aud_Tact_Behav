%% PLOT REJECTED TRIALS

subjects = ["01" "03", "04" "05" "06" "07" "08" "09" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30"];

folder = 'F:/Gian_Polina_2025/02Data';

tot_rejected_EEG = []; 
tot_rejected_RT = []; 
tot_missed = []; 
tot_tot = []; 
tot_channels = []; 
for i = 1:length(subjects)
    ID = char(subjects(i)); 
    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606\rejected_trials.mat'))
    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606\rejected_trials_RT.mat'))
    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606\missed_trials.mat'))
    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606\bad_chan_manual.mat'))
    tot_rejected_EEG = [tot_rejected_EEG numel(rejected_trials)];
    tot_rejected_RT = [tot_rejected_RT numel(rejected_trials_RT)];
    tot_missed = [tot_missed numel(missed_trials)];
    tot_tot = [tot_tot numel(unique([rejected_trials rejected_trials_RT' missed_trials']))];
    tot_channels = [tot_channels numel(bad_chan_manual)];
end

figure; 
bar(tot_rejected_EEG/640*100); 
ylim([0 100])
xticks(1:numel(subjects))
xticklabels(subjects)
title(sprintf('Average number of bad EEG trials: %.2f%% (+/- %.2f%%)', mean(tot_rejected_EEG)/640*100, std(tot_rejected_EEG)/640*100))

figure; 
bar(tot_rejected_RT/640*100); 
ylim([0 100])
xticks(1:numel(subjects))
xticklabels(subjects)
title(sprintf('Average number of bad BEHAVIOURAL trials: %.2f%% (+/- %.2f%%)', mean(tot_rejected_RT)/640*100, std(tot_rejected_RT)/640*100))

figure; 
bar(tot_missed/640*100); 
ylim([0 100])
xticks(1:numel(subjects))
xticklabels(subjects)
title(sprintf('Average number of missed trials: %.2f%% (+/- %.2f%%)', mean(tot_missed)/640*100, std(tot_missed)/640*100))


figure; 
bar(tot_tot/640*100); 
ylim([0 100])
xticks(1:numel(subjects))
xticklabels(subjects)
title(sprintf('Average number of TOTAL trials rejected: %.2f%% (+/- %.2f%%)', mean(tot_tot)/640*100, std(tot_tot)/640*100))

figure; 
bar(tot_channels); 
ylim([0 100])
xticks(1:numel(subjects))
xticklabels(subjects)
title(sprintf('Average number of channels rejected: %.2f%% (+/- %.2f%%)', mean(tot_channels), std(tot_channels)))







% %% PLOT REMOVED CHANNELS
% tot_rejected = []; 
% for i = 1:length(subjects)
%     ID = char(subjects(i)); 
%     load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_detrend\bad_chan_manual.mat'))
%     index = arrayfun(@(k) find(strncmp(bad_chan_manual{k},data.label,3)), 1:length(bad_chan_manual));
%     tot_rejected = [tot_rejected index];
% end
% 
% channels_rejected_totals = []; 
% [channels_rejected_totals(:,1) channels_rejected_totals(:,2)] = groupcounts(tot_rejected');
% 
% cols = 2160;
% rows = 3840;
% left_color = [1 1 1]; % white
% right_color = [0 0.25 0.5]; % color according to the attached image
% right_color = [0.4 0 0];
% cmap = interp1([0, 1], [left_color; right_color], linspace(0, 1, cols));
% img = repmat(1:cols, rows, 1);
% imshow(img, cmap)
% 
% 
% cfg = []; 
% cfg.layout = caplocation; 
% layout = ft_prepare_layout(cfg); 
% figure('Renderer', 'painters', 'Position', [10 10 500 500])
% hold on; 
% for i = 1:length(channels_rejected_totals)
%     plot(layout.pos(channels_rejected_totals(i,2),1), layout.pos(channels_rejected_totals(i,2),2), 'ko', 'MarkerFaceColor', cmap(length(cmap)/max(channels_rejected_totals(:,1))*channels_rejected_totals(i,1),:));
% end
% plot(layout.outline{1}(:,1), layout.outline{1}(:,2), 'k-');
% %plot(layout.pos(index,1), layout.pos(index,2), 'ko', 'MarkerFaceColor', [0 0 0], 'LineWidth', 5);
% xlim([-0.6 0.6])
% ylim([-0.6 0.6])


