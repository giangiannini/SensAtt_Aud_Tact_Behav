%% z_ERP_analyses_group

%% SETUP 
clear; clc; 

subjects = ["01" "03", "04" "05" "06" "07" "08" "09" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30"];
%subjects = ["03", "04" "05" "06" "07" "08" "09" "12" "13" "14" "15" "16" "18" "20" "21" "22" "23" "24" "25" "26" "28" "29" "30"];
%subjects = ["03", "04" "05" "06" "11" "12" "17" "20"  "24" "26" "27" "28" "29"];
%subjects = ["01", "03", "04" "05" "08" "09" "12" "13" "14" "16" "17" "18" "20" "21" "22" "23" "26" "27" "28" "29" "30"];

bigTrialTable = []; 

for i = 1:length(subjects)

    ID = char(subjects(i)); 
        
    caplocation = 'F:/02Data/03Utils/biosemi64.lay';
    
    %% LOAD rejected trials and missed trials, log and trial tables and adjust them 
    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_FINAL_FINAL\missed_trials.mat'))
    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_FINAL_FINAL\rejected_trials_FINAL_FINAL_FINAL.mat'))
    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_FINAL_FINAL\rejected_trials_RT.mat'))


    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_FINAL_FINAL', "\ExperimentLog_FINAL_FINAL_FINAL.mat"))
    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_FINAL_FINAL', "\TrialTable_FINAL_FINAL_FINAL.mat"))

    %% BEHAVIOURAL Velocity
    Velocities_Stay = table2array(ExperimentLog(ExperimentLog.Event_Name == "Velocity" & (ExperimentLog.TrialType == 2  | ExperimentLog.TrialType == 4),6));
    Velocities_Move = table2array(ExperimentLog(ExperimentLog.Event_Name == "Velocity" & (ExperimentLog.TrialType == 1  | ExperimentLog.TrialType == 3),6));
    Velocities_Stay_T = table2array(ExperimentLog(ExperimentLog.Event_Name == "Velocity" & (ExperimentLog.TrialType == 2  | ExperimentLog.TrialType == 4) & ExperimentLog.Stimulation == 1,6));
    Velocities_Move_T = table2array(ExperimentLog(ExperimentLog.Event_Name == "Velocity" & (ExperimentLog.TrialType == 1  | ExperimentLog.TrialType == 3) & ExperimentLog.Stimulation == 1,6));
    Velocities_Stay_A = table2array(ExperimentLog(ExperimentLog.Event_Name == "Velocity" & (ExperimentLog.TrialType == 2  | ExperimentLog.TrialType == 4) & ExperimentLog.Stimulation == 2,6));
    Velocities_Move_A = table2array(ExperimentLog(ExperimentLog.Event_Name == "Velocity" & (ExperimentLog.TrialType == 1  | ExperimentLog.TrialType == 3) & ExperimentLog.Stimulation == 2,6));
    Velocities_Stay_C = table2array(ExperimentLog(ExperimentLog.Event_Name == "Velocity" & (ExperimentLog.TrialType == 2  | ExperimentLog.TrialType == 4) & ExperimentLog.Stimulation == 3,6));
    Velocities_Move_C = table2array(ExperimentLog(ExperimentLog.Event_Name == "Velocity" & (ExperimentLog.TrialType == 1  | ExperimentLog.TrialType == 3) & ExperimentLog.Stimulation == 3,6));
    all_Behavioural.mean_velocity_Stay{i} = mean(Velocities_Stay); 
    all_Behavioural.mean_velocity_Move{i} = mean(Velocities_Move); 
    all_Behavioural.mean_velocity_Stay_T{i} = mean(Velocities_Stay_T); 
    all_Behavioural.mean_velocity_Move_T{i} = mean(Velocities_Move_T); 
    all_Behavioural.mean_velocity_Stay_A{i} = mean(Velocities_Stay_A); 
    all_Behavioural.mean_velocity_Move_A{i} = mean(Velocities_Move_A); 
    all_Behavioural.mean_velocity_Stay_C{i} = mean(Velocities_Stay_C); 
    all_Behavioural.mean_velocity_Move_C{i} = mean(Velocities_Move_C); 

    velocities = ExperimentLog{ExperimentLog.Event_Name == "Velocity",6};
    TrialTable.velocities = velocities; 

    %% BEHAVIOURAL Trial Time
    if i ~= find(subjects == "18")
        %extract start and end of each condition
        touches = find(ExperimentLog{:,5} == "Stim_1");
        start_end = [];
        for tt = 1:length(touches)
            if ExperimentLog{touches(tt)-2,5} ~= "GO"
                error('porcodioooo')
            end
            start_end = [start_end; ExperimentLog{touches(tt)-2,6}, ExperimentLog{touches(tt),6}];
        end
    
        if length(start_end) ~= size(TrialTable,1)
            error('Something is off with calculating stuff')
        end
    
        %FIRST FILL OUT THE MOVEMENT CONDITIONS
        %import hand movements
        opts = delimitedTextImportOptions("NumVariables", 7);
        opts.DataLines = [4, Inf];
        opts.Delimiter = "\t";
        opts.VariableNames = ["Timems", "Index_x", "Index_y", "Index_z", "Index_rotx", "Index_roty", "Index_rotz"];
        opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double"];
        opts.ExtraColumnsRule = "ignore";
        opts.EmptyLineRule = "read";
        ExperimentHandPositions = readtable(strcat("F:\Gian_Polina_2025\02Data\ID", ID, "\00Behavioural\Experiment_Hand_Positions_ID", ID, ".txt"), opts);
        clear opts
    
        %frequency_Unity = [frequency_Unity mean(diff(ExperimentHandPositions.Timems))];
    
        %movements = find(velocity_table.movement_conditions == "Move");
        total_rt = [];
        for se = 1:length(start_end)
            [value start_pos] = min(abs(ExperimentHandPositions.Timems - start_end(se,1)));
            [value end_pos] = min(abs(ExperimentHandPositions.Timems - start_end(se,2)));
            velocities = [];
            for j = 1:length(start_pos:end_pos)-1
                delta_space = sqrt((ExperimentHandPositions{start_pos+(j)-1,2}-ExperimentHandPositions{start_pos+(j),2})^2 + (ExperimentHandPositions{start_pos+(j)-1,4}-ExperimentHandPositions{start_pos+(j),4})^2);
                delta_time = (ExperimentHandPositions{start_pos+(j),1}-ExperimentHandPositions{start_pos+(j)-1,1})/1000; %in secs
                velocities = [velocities delta_space/delta_time];
            end
            if TrialTable.Trial_type(se) == 1 || TrialTable.Trial_type(se) == 3
                %plot(velocities)
                rt = (ExperimentHandPositions{end_pos,1} - ExperimentHandPositions{start_pos+find(velocities > 0.1,1)-1,1}); %do not take og start GO but when participant started to move
                total_rt = [total_rt; rt];
            else
                rt = (ExperimentHandPositions{end_pos,1} - ExperimentHandPositions{start_pos,1}); %do not take og start GO but when participant started to move
                total_rt = [total_rt; rt];
            end
        end
    
        TrialTable.rt = total_rt; 
    
        all_Behavioural.mean_rt_Stay{i} = mean(TrialTable.rt((TrialTable.Trial_type == 2  | TrialTable.Trial_type == 4))); 
        all_Behavioural.mean_rt_Move{i} = mean(TrialTable.rt((TrialTable.Trial_type == 2  | TrialTable.Trial_type == 4))); 
        all_Behavioural.mean_rt_Stay_T{i} = mean(TrialTable.rt((TrialTable.Trial_type == 2  | TrialTable.Trial_type == 4) & TrialTable.Stimulation == 1)); 
        all_Behavioural.mean_rt_Move_T{i} = mean(TrialTable.rt((TrialTable.Trial_type == 1  | TrialTable.Trial_type == 3) & TrialTable.Stimulation == 1)); 
        all_Behavioural.mean_rt_Stay_A{i} = mean(TrialTable.rt((TrialTable.Trial_type == 2  | TrialTable.Trial_type == 4) & TrialTable.Stimulation == 2)); 
        all_Behavioural.mean_rt_Move_A{i} = mean(TrialTable.rt((TrialTable.Trial_type == 1  | TrialTable.Trial_type == 3) & TrialTable.Stimulation == 2)); 
        all_Behavioural.mean_rt_Stay_C{i} = mean(TrialTable.rt((TrialTable.Trial_type == 2  | TrialTable.Trial_type == 4) & TrialTable.Stimulation == 3)); 
        all_Behavioural.mean_rt_Move_C{i} = mean(TrialTable.rt((TrialTable.Trial_type == 1  | TrialTable.Trial_type == 3) & TrialTable.Stimulation == 3));
    else
        TrialTable.rt = nan(size(TrialTable,1),1);
    end

    %% BEHAVIOURAL Trial Time
    % TrialTime_Stay = table2array(ExperimentLog(ExperimentLog.Event_Name == "Stim_1" & (ExperimentLog.TrialType == 2  | ExperimentLog.TrialType == 4),6)) - ...
    %                  table2array(ExperimentLog(ExperimentLog.Event_Name == "GO" & (ExperimentLog.TrialType == 2  | ExperimentLog.TrialType == 4),6));
    % TrialTime_Move = table2array(ExperimentLog(ExperimentLog.Event_Name == "Stim_1" & (ExperimentLog.TrialType == 1  | ExperimentLog.TrialType == 3),6)) - ...
    %                  table2array(ExperimentLog(ExperimentLog.Event_Name == "GO" & (ExperimentLog.TrialType == 1  | ExperimentLog.TrialType == 3),6));
    % TrialTime_Stay_T = table2array(ExperimentLog(ExperimentLog.Event_Name == "Stim_1" & (ExperimentLog.TrialType == 2  | ExperimentLog.TrialType == 4) & ExperimentLog.Stimulation == 1,6)) - ...
    %                    table2array(ExperimentLog(ExperimentLog.Event_Name == "GO" & (ExperimentLog.TrialType == 2  | ExperimentLog.TrialType == 4) & ExperimentLog.Stimulation == 1,6));
    % TrialTime_Move_T = table2array(ExperimentLog(ExperimentLog.Event_Name == "Stim_1" & (ExperimentLog.TrialType == 1  | ExperimentLog.TrialType == 3) & ExperimentLog.Stimulation == 1,6)) - ...
    %                    table2array(ExperimentLog(ExperimentLog.Event_Name == "GO" & (ExperimentLog.TrialType == 1  | ExperimentLog.TrialType == 3) & ExperimentLog.Stimulation == 1,6));
    % TrialTime_Stay_A = table2array(ExperimentLog(ExperimentLog.Event_Name == "Stim_1" & (ExperimentLog.TrialType == 2  | ExperimentLog.TrialType == 4) & ExperimentLog.Stimulation == 2,6)) - ...
    %                    table2array(ExperimentLog(ExperimentLog.Event_Name == "GO" & (ExperimentLog.TrialType == 2  | ExperimentLog.TrialType == 4) & ExperimentLog.Stimulation == 2,6));
    % TrialTime_Move_A = table2array(ExperimentLog(ExperimentLog.Event_Name == "Stim_1" & (ExperimentLog.TrialType == 1  | ExperimentLog.TrialType == 3) & ExperimentLog.Stimulation == 2,6)) - ...
    %                    table2array(ExperimentLog(ExperimentLog.Event_Name == "GO" & (ExperimentLog.TrialType == 1  | ExperimentLog.TrialType == 3) & ExperimentLog.Stimulation == 2,6));
    % TrialTime_Stay_C = table2array(ExperimentLog(ExperimentLog.Event_Name == "Stim_1" & (ExperimentLog.TrialType == 2  | ExperimentLog.TrialType == 4) & ExperimentLog.Stimulation == 3,6)) - ...
    %                    table2array(ExperimentLog(ExperimentLog.Event_Name == "GO" & (ExperimentLog.TrialType == 2  | ExperimentLog.TrialType == 4) & ExperimentLog.Stimulation == 3,6));
    % TrialTime_Move_C = table2array(ExperimentLog(ExperimentLog.Event_Name == "Stim_1" & (ExperimentLog.TrialType == 1  | ExperimentLog.TrialType == 3) & ExperimentLog.Stimulation == 3,6)) - ...
    %                    table2array(ExperimentLog(ExperimentLog.Event_Name == "GO" & (ExperimentLog.TrialType == 1  | ExperimentLog.TrialType == 3) & ExperimentLog.Stimulation == 3,6));
    % all_Behavioural.mean_velocity_Stay{i} = mean(TrialTime_Stay); 
    % all_Behavioural.mean_velocity_Move{i} = mean(TrialTime_Move); 
    % all_Behavioural.mean_velocity_Stay_T{i} = mean(TrialTime_Stay_T); 
    % all_Behavioural.mean_velocity_Move_T{i} = mean(TrialTime_Move_T); 
    % all_Behavioural.mean_velocity_Stay_A{i} = mean(TrialTime_Stay_A); 
    % all_Behavioural.mean_velocity_Move_A{i} = mean(TrialTime_Move_A); 
    % all_Behavioural.mean_velocity_Stay_C{i} = mean(TrialTime_Stay_C); 
    % all_Behavioural.mean_velocity_Move_C{i} = mean(TrialTime_Move_C); 

    %% BEHAVIOURAL Response Time
    LowsHighs = find((ExperimentLog.Event_Name == "Low" | ExperimentLog.Event_Name == "High")); 
    Stays = find((ExperimentLog.TrialType == 2  | ExperimentLog.TrialType == 4));
    Moves = find((ExperimentLog.TrialType == 1  | ExperimentLog.TrialType == 3));
    RT_Stay = table2array(ExperimentLog(LowsHighs(ismember(LowsHighs, Stays)),6)) - table2array(ExperimentLog(LowsHighs(ismember(LowsHighs, Stays))-1,6)) - 500;
    RT_Move = table2array(ExperimentLog(LowsHighs(ismember(LowsHighs, Moves)),6)) - table2array(ExperimentLog(LowsHighs(ismember(LowsHighs, Moves))-1,6)) - 500;
    all_Behavioural.mean_RT_Stay{i} = mean(RT_Stay); 
    all_Behavioural.mean_RT_Move{i} = mean(RT_Move); 

    %now also store RT for each stimulus intensity
    RTs = table2array(ExperimentLog(LowsHighs,6)) - table2array(ExperimentLog(LowsHighs-1,6)) - 500;
    TrialTable.RTs = RTs; 

    Stays = find((TrialTable.Trial_type == 2  | TrialTable.Trial_type == 4));
    Moves = find((TrialTable.Trial_type == 1  | TrialTable.Trial_type == 3));

    TrialTable.MoveStay = zeros(size(TrialTable,1),1); 
    TrialTable.MoveStay(Stays) = 1; 
    TrialTable.MoveStay(Moves) = 2; 

    summary = groupsummary(TrialTable, ["MoveStay", "Stim_auditory_2", "Stim_tactile_2"], "mean", "RTs");
    if summary.Stim_auditory_2(1) == 0 && summary.Stim_auditory_2(20) == 0 && size(summary,1) == 38
        all_Behavioural.RT_Stay_9stimuli_Touch{i} = summary.mean_RTs(2:10);
        all_Behavioural.RT_Move_9stimuli_Touch{i} = summary.mean_RTs(21:29); 
        all_Behavioural.RT_Stay_9stimuli_Audio{i} = summary.mean_RTs(11:19);
        all_Behavioural.RT_Move_9stimuli_Audio{i} = summary.mean_RTs(30:38); 
    else
        error('diokäne')
    end

    %% BEHAVIOURAL Psychometric - Touch 
    Stimuli_touch = unique(TrialTable.Stim_tactile_2(:)); 
    Stimuli_touch(find(Stimuli_touch == 0)) = []; 

    Stimuli_audio = unique(TrialTable.Stim_auditory_2(:)); 
    Stimuli_audio(find(Stimuli_audio == 0)) = []; 
        
    Stimuli = TrialTable.Stim_tactile_2(:) + TrialTable.Stim_auditory_2(:);
    Responses = ExperimentLog((ExperimentLog.Event_Name == "Low" | ExperimentLog.Event_Name == "High"),:);
    Responses.Stimuli = Stimuli; 
    Responses.Event_Name_2(Responses.Event_Name == "High") = 1; 

    Responses.Intensities = Responses.Stimuli; 
    for mm = 1:size(Responses,1)
        if Responses.Stimulation(mm) == 1
        	Responses.Intensities(mm) = find(Responses.Intensities(mm) == Stimuli_touch);
        elseif Responses.Stimulation(mm) == 2
        	Responses.Intensities(mm) = find(Responses.Intensities(mm) == Stimuli_audio);
        end
    end
    
    output_summary = groupsummary(Responses(Responses.Stimulation == 1,:), ["Stimuli"], @(x)sum(x==1),"Event_Name_2");
    hits = [output_summary.fun1_Event_Name_2 ./ output_summary.GroupCount];
    output_summary.hits = hits; 
    all_Behavioural.Hits_Touch{i} = output_summary; 

    %% BEHAVIOURAL Psychometric - Audio 
    output_summary = groupsummary(Responses(Responses.Stimulation == 2,:), ["Stimuli"], @(x)sum(x==1),"Event_Name_2");
    hits = [output_summary.fun1_Event_Name_2 ./ output_summary.GroupCount];
    output_summary.hits = hits; 
    all_Behavioural.Hits_Audio{i} = output_summary; 

    %% BEHAVIOURAL Psychometric - Touch / Audio - Move / Stay
    trialtype = [1 3; 2 4];
    colors = ['g' 'r'];
    titles = ["Tactile", "Auditory"];
    names = ["Hits_Touch_Move", "Hits_Touch_Stay", "Hits_Audio_Move", "Hits_Audio_Stay"];
    counter = 0; 
    for m = 1:2
        for n = 1:2
            counter = counter + 1;
            output_summary = groupsummary(Responses(Responses.Stimulation == m & (Responses.TrialType == trialtype(n,1) | Responses.TrialType == trialtype(n,2)),:), ["Stimuli"], @(x)sum(x==1),"Event_Name_2");
            hits = [output_summary.fun1_Event_Name_2 ./ output_summary.GroupCount];
            output_summary.hits = hits;
            all_Behavioural.(names(counter)){i} = output_summary;
        end
    end
    
    %% PUT TOGETHER EVERYTHING FOR STATS
    TrialTable.Responses = Responses.Event_Name_2; 
    TrialTable.Intensities = Responses.Intensities; 
    TrialTable.ID = repmat(i,size(TrialTable,1),1);
    bigTrialTable = [bigTrialTable; TrialTable];
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% BEHAVIOURAL GROUP ANALYSES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% VELOCITY and TIME
Velocity_M = mean([all_Behavioural.mean_velocity_Move{:}]);
err_M = sqrt(var([all_Behavioural.mean_velocity_Move{:}]))./sqrt(numel(all_Behavioural.mean_velocity_Move));
Velocity_S = mean([all_Behavioural.mean_velocity_Stay{:}]);
err_S = sqrt(var([all_Behavioural.mean_velocity_Stay{:}]))./sqrt(numel(all_Behavioural.mean_velocity_Stay));

figure; 
bar(1, Velocity_S, 'r');
hold on;
bar(2, Velocity_M, 'g');
errorbar(1, Velocity_S, err_S, 'k');
errorbar(2, Velocity_M, err_M, 'k');
xticks([])
% ylim([0 0.45])
legend({'Stay', 'Move'});
title('Velocity across stay and Move conditions (Uu/Sec)')

Velocity_M = mean([all_Behavioural.mean_velocity_Move{:}]);
err_M = sqrt(var([all_Behavioural.mean_velocity_Move{:}]))./sqrt(numel(all_Behavioural.mean_velocity_Move)); 


% % % % %category = ["mean_velocity_Stay_T", "mean_velocity_Move_T", "mean_velocity_Stay_A", "mean_velocity_Move_A", "mean_velocity_Stay_C", "mean_velocity_Move_C"];
% % % % category = ["mean_velocity_Stay_T", "mean_velocity_Stay_A", "mean_velocity_Stay_C", "mean_velocity_Move_T", "mean_velocity_Move_A", "mean_velocity_Move_C"];
% % % % figure; hold on; 
% % % % space = 0; 
% % % % for i = 1:length(category)
% % % %     space = space + 1; 
% % % %     if i == 3 || i == 5
% % % %         space = space+1;
% % % %     end
% % % %     if i == 1 || i == 3 || i == 5
% % % %         bar(space, mean([all_Behavioural.(category(i)){:}]), 'r')
% % % %     else
% % % %         bar(space, mean([all_Behavioural.(category(i)){:}]), 'g')
% % % %     end
% % % %     errorbar(space, mean([all_Behavioural.(category(i)){:}]), sqrt(var([all_Behavioural.(category(i)){:}]))./sqrt(numel(all_Behavioural.(category(i)))), 'k');
% % % % end
% % % % legend({'Stay', '', 'Move'});
% % % % xticks([1.5 4.5 7.5])
% % % % xticklabels(["Touch" "Audio" "Control"])

category = ["mean_velocity_Stay_T", "mean_velocity_Stay_A", "mean_velocity_Stay_C", "mean_velocity_Move_T", "mean_velocity_Move_A", "mean_velocity_Move_C"];
colors_to_plot = [215, 38, 56; ...
                   168, 51, 61; ...
                   233, 150, 58; ...
                   0, 128, 0; ...
                   0, 109, 91; ...
                   166, 215, 91]/255;
figure; hold on; 
space = 0; 
for i = 1:length(category)
    space = space + 1; 
    if i == 4 
        space = space+1;
    end
    
    bar(space, mean([all_Behavioural.(category(i)){:}]), 'FaceColor', colors_to_plot(i,:))
    errorbar(space, mean([all_Behavioural.(category(i)){:}]), sqrt(var([all_Behavioural.(category(i)){:}]))./sqrt(numel(all_Behavioural.(category(i)))), 'k');
end
%legend({'Stay', '', '', '', '', '', '', '', 'Move'});
xticks([1 2 3 5 6 7])
xticklabels(["Touch" "Audio" "Control" "Touch" "Audio" "Control"])
ylabel('Velocity of movement execution (Uu/s)')






% rt_M = mean([all_Behavioural.mean_rt_Move{:}]);
% err_M = sqrt(var([all_Behavioural.mean_rt_Move{:}]))./sqrt(numel(all_Behavioural.mean_rt_Move)); 
% rt_S = mean([all_Behavioural.mean_rt_Stay{:}]);
% err_S = sqrt(var([all_Behavioural.mean_rt_Stay{:}]))./sqrt(numel(all_Behavioural.mean_rt_Stay)); 
% figure; 
% bar(1, rt_S, 'r');
% hold on;
% bar(2, rt_M, 'g');
% errorbar(1, rt_S, err_S, 'k');
% errorbar(2, rt_M, err_M, 'k');
% xticks([])
% % ylim([0 0.45])
% legend({'Stay', 'Move'});
% title('Response Time across stay and Move conditions (Uu/Sec)')

% category = ["mean_rt_Stay_T", "mean_rt_Move_T", "mean_rt_Stay_A", "mean_rt_Move_A", "mean_rt_Stay_C", "mean_rt_Move_C"];
% figure; hold on; 
% space = 0; 
% for i = 1:length(category)
%     space = space + 1; 
%     if i == 3 || i == 5
%         space = space+1;
%     end
%     if i == 1 || i == 3 || i == 5
%         bar(space, mean([all_Behavioural.(category(i)){:}]), 'r')
%     else
%         bar(space, mean([all_Behavioural.(category(i)){:}]), 'g')
%     end
%     errorbar(space, mean([all_Behavioural.(category(i)){:}]), sqrt(var([all_Behavioural.(category(i)){:}]))./sqrt(numel(all_Behavioural.(category(i)))), 'k');
% end
% legend({'Stay', '', 'Move'});
% xticks([1.5 4.5 7.5])
% xticklabels(["Touch" "Audio" "Control"])



category = ["mean_rt_Stay_T", "mean_rt_Stay_A", "mean_rt_Stay_C", "mean_rt_Move_T", "mean_rt_Move_A", "mean_rt_Move_C"];
colors_to_plot = [215, 38, 56; ...
                   168, 51, 61; ...
                   233, 150, 58; ...
                   0, 128, 0; ...
                   0, 109, 91; ...
                   166, 215, 91]/255;
figure; hold on; 
space = 0; 
for i = 1:length(category)
    space = space + 1; 
    if i == 4 
        space = space+1;
    end
    
    bar(space, mean([all_Behavioural.(category(i)){:}]), 'FaceColor', colors_to_plot(i,:))
    errorbar(space, mean([all_Behavioural.(category(i)){:}]), sqrt(var([all_Behavioural.(category(i)){:}]))./sqrt(numel(all_Behavioural.(category(i)))), 'k');
end
%legend({'Stay', '', '', '', '', '', '', '', 'Move'});
xticks([1 2 3 5 6 7])
xticklabels(["Touch" "Audio" "Control" "Touch" "Audio" "Control"])
ylabel('Time of movement execution (ms)')

%% TEST FOR DIFFERENCES
prova = groupsummary(bigTrialTable, ["MoveStay", "Stimulation", "ID"], 'mean', "velocities");
prova.Stimulation = categorical(prova.Stimulation);
prova.MoveStay = categorical(prova.MoveStay);
prova.ID = categorical(prova.ID);
lm = fitlme(prova,'mean_velocities~MoveStay*Stimulation+(1|ID)', 'DummyVarCoding', 'effects')
anova(lm)


prova = groupsummary(bigTrialTable, ["MoveStay", "Stimulation", "ID"], 'mean', "rt");
prova.Stimulation = categorical(prova.Stimulation);
prova.MoveStay = categorical(prova.MoveStay);
prova.ID = categorical(prova.ID);
lm = fitlme(prova,'mean_rt~MoveStay*Stimulation+(1|ID)', 'DummyVarCoding', 'effects');
anova(lm)


% bigTrialTable.Stimulation = categorical(bigTrialTable.Stimulation);
% bigTrialTable.MoveStay = categorical(bigTrialTable.MoveStay);
% bigTrialTable.ID = categorical(bigTrialTable.ID);
% lm = fitlme(bigTrialTable,'rt~MoveStay+Stimulation+(1|ID)', 'DummyVarCoding', 'effects');
% anova(lm)

%% RT
% RT_M = mean([all_Behavioural.mean_RT_Move{:}]);
% err_M = sqrt(var([all_Behavioural.mean_RT_Move{:}]))./sqrt(numel(all_Behavioural.mean_RT_Move)); 
% RT_S = mean([all_Behavioural.mean_RT_Stay{:}]);
% err_S = sqrt(var([all_Behavioural.mean_RT_Stay{:}]))./sqrt(numel(all_Behavioural.mean_RT_Stay)); 
% 
% 
% figure; 
% bar(1, RT_S, 'r');
% hold on; 
% bar(2, RT_M, 'g')
% errorbar(1, RT_S, err_S, 'k')
% errorbar(2, RT_M, err_M, 'k')
% ylim([0 1200])
% xticks([]); 
% legend({'Stay', 'Move'});
% title('Response time across Move and Stay trials')


prova = groupsummary(bigTrialTable, ["MoveStay", "Stimulation", "ID"], {"mean", "var"}, "RTs");
prova = groupsummary(prova, ["MoveStay", "Stimulation"], {"mean", "var"}, "mean_RTs");

figure; hold on;
for i = 1:size(prova,1)
    space = space + 1; 
    if i == 4 
        space = space+1;
    end
    
    bar(space, prova.mean_mean_RTs(i), 'FaceColor', colors_to_plot(i,:));
    errorbar(space, prova.mean_mean_RTs(i), sqrt(prova.var_mean_RTs(i))./sqrt(prova.GroupCount(i)), 'k');
end
xticks([1 2 3 5 6 7])
xticklabels(["Touch" "Audio" "Control" "Touch" "Audio" "Control"])
ylabel('Time of movement execution (ms)')



figure; 
bar([1:9]-0.15, mean(cat(2, all_Behavioural.RT_Stay_9stimuli_Touch{:}),2), 'FaceColor',[1 0 0], 'FaceAlpha', 0.5, 'BarWidth', 0.5); 
hold on; 
errorbar([1:9]-0.15, mean(cat(2, all_Behavioural.RT_Stay_9stimuli_Touch{:}),2), sqrt(var(cat(2, all_Behavioural.RT_Stay_9stimuli_Touch{:})'))./sqrt(numel(all_Behavioural.mean_RT_Move)), 'k', 'LineStyle', 'none')
bar([1:9]+0.15, mean(cat(2, all_Behavioural.RT_Move_9stimuli_Touch{:}),2), 'FaceColor',[0 1 0], 'FaceAlpha', 0.5,  'BarWidth', 0.5)
errorbar([1:9]+0.15, mean(cat(2, all_Behavioural.RT_Move_9stimuli_Touch{:}),2), sqrt(var(cat(2, all_Behavioural.RT_Move_9stimuli_Touch{:})'))./sqrt(numel(all_Behavioural.mean_RT_Move)), 'k', 'LineStyle', 'none')
title('Response time across Touch stimulus intensity and Move and Stay trials')
legend({'Stay', '', 'Move'})
xticks([1:9])
xlabel('Stimulus intensities')
ylabel('ms')
ylim([0 800])

figure; 
bar([1:9]-0.15, mean(cat(2, all_Behavioural.RT_Stay_9stimuli_Audio{:}),2), 'FaceColor',[1 0 0], 'FaceAlpha', 0.5, 'BarWidth', 0.5); 
hold on; 
errorbar([1:9]-0.15, mean(cat(2, all_Behavioural.RT_Stay_9stimuli_Audio{:}),2), sqrt(var(cat(2, all_Behavioural.RT_Stay_9stimuli_Audio{:})'))./sqrt(numel(all_Behavioural.mean_RT_Move)), 'k', 'LineStyle', 'none')
bar([1:9]+0.15, mean(cat(2, all_Behavioural.RT_Move_9stimuli_Audio{:}),2), 'FaceColor',[0 1 0], 'FaceAlpha', 0.5,  'BarWidth', 0.5)
errorbar([1:9]+0.15, mean(cat(2, all_Behavioural.RT_Move_9stimuli_Audio{:}),2), sqrt(var(cat(2, all_Behavioural.RT_Move_9stimuli_Audio{:})'))./sqrt(numel(all_Behavioural.mean_RT_Move)), 'k', 'LineStyle', 'none')
title('Response time across Audio stimulus intensity and Move and Stay trials')
legend({'Stay', '', 'Move'})
xticks([1:9])
xlabel('Stimulus intensities')
ylabel('ms')
ylim([0 800])

%Test only differences across the two tasks
prova = groupsummary(bigTrialTable(bigTrialTable.Stimulation ~= 3,:), ["MoveStay", "Stimulation", "ID"], 'mean', "RTs");
prova.Stimulation = categorical(prova.Stimulation);
prova.MoveStay = categorical(prova.MoveStay);
prova.ID = categorical(prova.ID);
lm = fitlme(prova,'mean_RTs~MoveStay*Stimulation+(1|ID)', 'DummyVarCoding', 'effects')
anova(lm)

prova = groupsummary(bigTrialTable(bigTrialTable.Stimulation == 3,:), ["MoveStay", "ID"], 'mean', "RTs");
prova.MoveStay = categorical(prova.MoveStay);
prova.ID = categorical(prova.ID);
lm = fitlme(prova,'mean_RTs~MoveStay+(1|ID)', 'DummyVarCoding', 'effects')
anova(lm)


%% OVERALL ACCURACY
%Build up the table for the accuracy
bigTrialTable.Accuracy = bigTrialTable.Responses;
for i = 1:size(bigTrialTable,1)
    if bigTrialTable.Intensities(i) < 5
        bigTrialTable.Accuracy(i) = abs(1 - bigTrialTable.Accuracy(i));
    end
end

%accuracy overall (omit central stimulus and control condition) 
prova = groupsummary(bigTrialTable(bigTrialTable.Intensities ~= 5 & bigTrialTable.Stimulation ~= 3, :), ["MoveStay", "Stimulation", "ID"], {"sum"}, "Accuracy");
prova.accuracy = prova.sum_Accuracy ./ prova.GroupCount * 100; 
prova = groupsummary(prova, ["MoveStay", "Stimulation"], {"mean", "var"}, "accuracy");

colors_to_plot = [215, 38, 56; ...
                   168, 51, 61; ...
                   0, 128, 0; ...
                   0, 109, 91]/255;
space = 0; 
figure; hold on;
for i = 1:size(prova,1)
    space = space + 1; 
    if i == 3
        space = space+1;
    end
    
    bar(space, prova.mean_accuracy(i), 'FaceColor', colors_to_plot(i,:));
    errorbar(space, prova.mean_accuracy(i), sqrt(prova.var_accuracy(i))./sqrt(prova.GroupCount(i)), 'k');
end
xticks([1 2 4 5])
xticklabels(["Touch" "Audio" "Touch" "Audio"])
ylabel('Accuracy (%)')

prova = groupsummary(bigTrialTable(bigTrialTable.Intensities ~= 5 & bigTrialTable.Stimulation ~= 3, :), ["MoveStay", "Stimulation", "ID"], {"sum"}, "Accuracy");
prova.accuracy = prova.sum_Accuracy ./ prova.GroupCount * 100; 
prova.Stimulation = categorical(prova.Stimulation);
prova.MoveStay = categorical(prova.MoveStay);
prova.ID = categorical(prova.ID);
lm = fitlme(prova, 'accuracy~MoveStay*Stimulation+(1|ID)');
anova(lm)




%accuracy control task
for i = 1:size(bigTrialTable,1)
    if bigTrialTable.Control(i) == 2
        bigTrialTable.Responses(i) = abs(1 - bigTrialTable.Responses(i));
    end
end
prova = groupsummary(bigTrialTable(bigTrialTable.Intensities == 0 & bigTrialTable.Stimulation == 3, :), ["MoveStay", "ID"], {"sum"}, "Responses");
prova.accuracy = prova.sum_Responses ./ prova.GroupCount * 100; 
prova = groupsummary(prova, ["MoveStay"], {"mean", "var"}, "accuracy");

colors_to_plot = [233, 150, 58; ...
                  166, 215, 91]/255;
space = 0; 
figure; hold on;
for i = 1:size(prova,1)
    space = space + 1; 
    if i == 2
        space = space+1;
    end
    
    bar(space, prova.mean_accuracy(i), 'FaceColor', colors_to_plot(i,:));
    errorbar(space, prova.mean_accuracy(i), sqrt(prova.var_accuracy(i))./sqrt(prova.GroupCount(i)), 'k');
end
xticks([1 3])
xticklabels(["Stay" "Move"])
ylabel('Accuracy control task (%)')

prova = groupsummary(bigTrialTable(bigTrialTable.Intensities == 0 & bigTrialTable.Stimulation == 3, :), ["MoveStay", "ID"], {"sum"}, "Responses");
prova.accuracy = prova.sum_Responses ./ prova.GroupCount * 100; 
prova.MoveStay = categorical(prova.MoveStay);
prova.ID = categorical(prova.ID);
lm = fitlme(prova, 'accuracy~MoveStay+(1|ID)');
anova(lm)




%% Psychometric - Audio / Touch
% names = ["Hits_Touch", "Hits_Audio"];
% titles = ["Tactile", "Auditory"];
% for i = 1:length(names)
%     tot_hits = []; 
%     for n = 1:length(all_Behavioural.(names(i)))
%         tot_hits(:,n) = all_Behavioural.(names(i)){n}{:,4};
%     end
%     avg_tot_hits = mean(tot_hits, 2); 
% 
%     [ Qpre, p, sm, varcov] = fit_logistic(1:9, avg_tot_hits');
%     t = linspace(1,9,1000); 
%     Qinf = p(2); 
%     alpha = p(3); 
%     thalf = p(1); 
%     Q = Qinf./(1 + exp(-alpha*(t-thalf)));
% 
%     Q_thresh = 0.5;
%     t_thresh = thalf - (1 / alpha) * log(Qinf / Q_thresh - 1);
%     %fprintf('Intensity at which Q = 0.5: %.4f\n', t_halfQ);
% 
%     figure; plot(1:9, avg_tot_hits', 'o');
%     hold on; plot(t, Q);
%     plot([t_thresh t_thresh], [0 Q_thresh], 'r--', 'LineWidth', 1.5);
%     plot([0 t_thresh], [Q_thresh Q_thresh], 'r--', 'LineWidth', 1.5);
%     xlabel('Intensities')
%     ylabel('Hit Proportion')
%     title(titles(i))
% end

%% Psychometric - Audio / Touch - Move / Stay
% colors = ['g' 'r'];
% titles = ["Tactile", "Auditory"];
% names = ["Hits_Touch_Move", "Hits_Touch_Stay"; "Hits_Audio_Move", "Hits_Audio_Stay"];
% p = []; 
% for m = 1:2
%     figure; 
%     for i = 1:2
%         tot_hits = []; 
%         for n = 1:length(all_Behavioural.(names(m,i)))
%             tot_hits(:,n) = all_Behavioural.(names(m,i)){n}{:,4};
%         end
%         avg_tot_hits = mean(tot_hits, 2); 
% 
%         [ Qpre, p, sm, varcov] = fit_logistic(1:9, avg_tot_hits');
%         t = linspace(1,9,1000); 
%         Qinf = p(2);
%         alpha = p(3);
%         thalf = p(1);
%         Q = Qinf./(1 + exp(-alpha*(t-thalf)));
% 
%         Q_thresh = 0.5;
%         t_thresh = thalf - (1 / alpha) * log(Qinf / Q_thresh - 1);
% 
%         hold on; plot(t, Q, colors(i));
%         plot([t_thresh t_thresh], [0 Q_thresh], '--', 'Color', colors(i), 'LineWidth', 1.5);
%         plot([0 t_thresh], [Q_thresh Q_thresh], '--', 'Color', colors(i), 'LineWidth', 1.5);
%         xlabel('Intensities')
%         ylabel('Hit Proportion')
%         ylim([0 1])
%         title(titles(m))
%     end
%     legend({'Move','','', 'Stay'}, 'AutoUpdate', 'off', 'Location', 'northwest')
%     for i = 1:2
%         tot_hits = []; 
%         for n = 1:length(all_Behavioural.(names(m,i)))
%             tot_hits(:,n) = all_Behavioural.(names(m,i)){n}{:,4};
%         end
%         avg_tot_hits = mean(tot_hits, 2); 
%         plot(1:9, avg_tot_hits, strcat(colors(i), 'o'));
%     end
% end

%% PLOT EACH SINGLE PSYCHOMETRIC FUNCTION
% figure; 
% for i = 1:length(subjects)
%     subplot(5,6,i)
%     [ Qpre, p, sm, varcov] = fit_logistic(1:9, all_Behavioural.Hits_Touch{i}.hits');
%     t = linspace(1,9,1000); 
%     Qinf = p(2); 
%     alpha = p(3); 
%     thalf = p(1); 
%     Q = Qinf./(1 + exp(-alpha*(t-thalf)));
% 
%     plot(1:9, all_Behavioural.Hits_Touch{i}.hits', 'o');
%     hold on; plot(t, Q); hold off;
%     title(sprintf('Subject: %s', subjects(i)))
% end
% sgtitle('Tactile')
% 
% 
% figure; 
% for i = 1:length(subjects)
%     subplot(5,6,i)
%     [ Qpre, p, sm, varcov] = fit_logistic(1:9, all_Behavioural.Hits_Audio{i}.hits');
%     t = linspace(1,9,1000); 
%     Qinf = p(2); 
%     alpha = p(3); 
%     thalf = p(1); 
%     Q = Qinf./(1 + exp(-alpha*(t-thalf)));
% 
%     plot(1:9, all_Behavioural.Hits_Audio{i}.hits', 'o');
%     hold on; plot(t, Q); hold off;
%     ylim([0 1])
%     title(sprintf('Subject: %s', subjects(i)))
% end
% sgtitle('Audio')
% 
% 
% colors = ['g' 'r'];
% titles = ["Tactile", "Auditory"];
% names = ["Hits_Touch_Move", "Hits_Touch_Stay"; "Hits_Audio_Move", "Hits_Audio_Stay"];
% p = []; 
% for m = 1:2
%     figure; 
%     for subj=1:length(subjects)
%         subplot(5,6,subj)
%         for i = 1:2        
%             [ Qpre, p, sm, varcov] = fit_logistic(1:9, all_Behavioural.(names(m,i)){subj}.hits');
%             t = linspace(1,9,1000); 
%             Qinf = p(2);
%             alpha = p(3);
%             thalf = p(1);
%             Q = Qinf./(1 + exp(-alpha*(t-thalf)));
% 
%             hold on; plot(t, Q, colors(i));
%             ylim([0 1])
%             title(sprintf('Subject: %s', subjects(subj)))
%         end
%         %legend({'Move', 'Stay'}, 'AutoUpdate', 'off', 'Location', 'northwest')
%         for i = 1:2
%             plot(1:9, all_Behavioural.(names(m,i)){subj}.hits', strcat(colors(i), 'o'));
%         end
%     end
%     sgtitle(titles(m))
% end

%% PSYCHOMETRIC FUNCITON USING PSIGNIFIT
% category = ["mean_rt_Stay_T", "mean_rt_Stay_A", "mean_rt_Stay_C", "mean_rt_Move_T", "mean_rt_Move_A", "mean_rt_Move_C"];
% colors_to_plot = [215, 38, 56; ...
%                    168, 51, 61; ...
%                    233, 150, 58; ...
%                    0, 128, 0; ...
%                    0, 109, 91; ...
%                    166, 215, 91]/255;
names = ["Hits_Touch_Move", "Hits_Touch_Stay"];
colors = [0, 128, 0; ...
          215, 38, 56]/255;
figure; hold on; 
tot_hits = []; tot_GroupCount = []; tot_CorrResp = []; 
for m = 1:length(names)
    for n = 1:length(all_Behavioural.(names(m)))
        tot_GroupCount(:,n) = all_Behavioural.(names(m)){n}{:,2};
        tot_CorrResp(:,n) = all_Behavioural.(names(m)){n}{:,3}; 
        tot_hits(:,n) = all_Behavioural.(names(m)){n}{:,4};
    end
    data = [(1:9)', mean(tot_CorrResp, 2), mean(tot_GroupCount, 2)];
    options = struct; 
    options.sigmoidName = 'logistic'; 
    options.expType = 'YesNo';
    result = psignifit(data,options);

    plot(result.data(:,1),result.data(:,2)./result.data(:,3),'o', 'Color', [colors(m,:), 0.2]);
    x = linspace(min(result.data(:,1)),max(result.data(:,1)),1000);
    fitValues = (1-result.Fit(3)-result.Fit(4))*arrayfun(@(x) result.options.sigmoidHandle(x,result.Fit(1),result.Fit(2)),x)+result.Fit(4);
    hline = plot(x, fitValues, 'Color', colors(m,:));

    thresh = plot([result.Fit(1),result.Fit(1)], [0, 0.5], 'Color', colors(m,:), 'LineStyle', '-', 'LineWidth', 3);
end
xlabel('Stimuli (absolute)')
ylabel('Hit proportion')
title('Psychometric function for Touch modality')


names = ["Hits_Audio_Move", "Hits_Audio_Stay"];
colors = [0, 109, 91; ...
          168, 51, 61]/255;
figure; hold on; 
tot_hits = []; tot_GroupCount = []; tot_CorrResp = []; 
for m = 1:length(names)
    for n = 1:length(all_Behavioural.(names(m)))
        tot_GroupCount(:,n) = all_Behavioural.(names(m)){n}{:,2};
        tot_CorrResp(:,n) = all_Behavioural.(names(m)){n}{:,3}; 
        tot_hits(:,n) = all_Behavioural.(names(m)){n}{:,4};
    end
    data = [(1:9)', mean(tot_CorrResp, 2), mean(tot_GroupCount, 2)];
    options = struct; 
    options.sigmoidName = 'logistic'; 
    options.expType = 'YesNo';
    result = psignifit(data,options);

    plot(result.data(:,1),result.data(:,2)./result.data(:,3),'o', 'Color', [colors(m,:), 0.2]);
    x = linspace(min(result.data(:,1)),max(result.data(:,1)),1000);
    fitValues = (1-result.Fit(3)-result.Fit(4))*arrayfun(@(x) result.options.sigmoidHandle(x,result.Fit(1),result.Fit(2)),x)+result.Fit(4);
    hline = plot(x, fitValues, 'Color', colors(m,:));
        
    thresh = plot([result.Fit(1),result.Fit(1)], [0, 0.5], 'Color', colors(m,:), 'LineStyle', '-', 'LineWidth', 3);
end
xlabel('Stimuli (absolute)')
ylabel('Hit proportion')
title('Psychometric function for Audio modality')

%% THRESHOLD USING USING PSIGNIFIT
table_thresholds = []; 
conditions = ["Hits_Touch_Move", "Hits_Touch_Stay"];
for i = 1:length(subjects)
    for mm = 1:length(conditions)
        data = [(1:9)', all_Behavioural.(conditions(mm)){i}.fun1_Event_Name_2, all_Behavioural.(conditions(mm)){i}.GroupCount];
        options = struct; 
        options.sigmoidName = 'logistic'; 
        options.expType = 'YesNo';
        result = psignifit(data,options);
        table_thresholds = [table_thresholds; mm, i, result.Fit(1)];
    end
end
table_thresholds = array2table(table_thresholds, 'VariableNames', {'MoveStay', 'ID', 'Threshold'});

prova = groupsummary(table_thresholds, ["MoveStay"], {'mean', 'var'}, "Threshold");
figure; hold on;  
scatter(ones(size(table_thresholds,1)/2,1), table_thresholds.Threshold(1:2:size(table_thresholds)), 'g');
scatter(ones(size(table_thresholds,1)/2,1)*2, table_thresholds.Threshold(2:2:size(table_thresholds)), 'r');
plot([0.75 1.25], [prova.mean_Threshold(1) prova.mean_Threshold(1)], '-k', 'LineWidth', 3);
plot([1.75 2.25], [prova.mean_Threshold(2) prova.mean_Threshold(2)], '-k', 'LineWidth', 3);
for m = 1:size(table_thresholds,1)/2
    plot([1 2], [table_thresholds.Threshold(m*2-1) table_thresholds.Threshold(m*2)], 'Color', [0 0 0 0.2]);
    xlim([0 3])
end
ylabel('Threshold (absolute intensity)')
xticks([1 2])
xticklabels(["Move", "Stay"])
title('Thresholds for Touch conditions')

lm = fitlme(table_thresholds, 'Threshold~MoveStay+(1|ID)');
anova(lm)


table_thresholds = []; 
conditions = ["Hits_Audio_Move", "Hits_Audio_Stay"];
for i = 1:length(subjects)
    for mm = 1:length(conditions)
        data = [(1:9)', all_Behavioural.(conditions(mm)){i}.fun1_Event_Name_2, all_Behavioural.(conditions(mm)){i}.GroupCount];
        options = struct; 
        options.sigmoidName = 'logistic'; 
        options.expType = 'YesNo';
        result = psignifit(data,options);
        table_thresholds = [table_thresholds; mm, i, result.Fit(1)];
    end
end
table_thresholds = array2table(table_thresholds, 'VariableNames', {'MoveStay', 'ID', 'Threshold'});

prova = groupsummary(table_thresholds, ["MoveStay"], {'mean', 'var'}, "Threshold");
figure; hold on;  
scatter(ones(size(table_thresholds,1)/2,1), table_thresholds.Threshold(1:2:size(table_thresholds)), 'g');
scatter(ones(size(table_thresholds,1)/2,1)*2, table_thresholds.Threshold(2:2:size(table_thresholds)), 'r');
plot([0.75 1.25], [prova.mean_Threshold(1) prova.mean_Threshold(1)], '-k', 'LineWidth', 3);
plot([1.75 2.25], [prova.mean_Threshold(2) prova.mean_Threshold(2)], '-k', 'LineWidth', 3);
for m = 1:size(table_thresholds,1)/2
    plot([1 2], [table_thresholds.Threshold(m*2-1) table_thresholds.Threshold(m*2)], 'Color', [0 0 0 0.2]);
    xlim([0 3])
end
ylabel('Threshold (absolute intensity)')
xticks([1 2])
xticklabels(["Move", "Stay"])
title('Thresholds for Audio conditions')

lm = fitlme(table_thresholds, 'Threshold~MoveStay+(1|ID)');
anova(lm)


