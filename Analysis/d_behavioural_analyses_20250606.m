%% z_ERP_analyses_group

%% SETUP 
clear; clc; 

subjects = ["01" "03", "04" "05" "06" "07" "08" "09" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30"];

bigTrialTable = []; 

for i = 1:length(subjects)

    ID = char(subjects(i)); 
        
    caplocation = 'F:/02Data/03Utils/biosemi64.lay';
    
    %% LOAD rejected trials and missed trials, log and trial tables and adjust them 
    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606\missed_trials.mat'))
    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606\rejected_trials.mat'))
    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606\rejected_trials_RT.mat'))


    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606', "\ExperimentLog.mat"))
    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606', "\TrialTable.mat"))

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
    % if i ~= find(subjects == "18")
    %     %extract start and end of each condition
    %     touches = find(ExperimentLog{:,5} == "Stim_1");
    %     start_end = [];
    %     for tt = 1:length(touches)
    %         if ExperimentLog{touches(tt)-2,5} ~= "GO"
    %             error('porcodioooo')
    %         end
    %         start_end = [start_end; ExperimentLog{touches(tt)-2,6}, ExperimentLog{touches(tt),6}];
    %     end
    % 
    %     if length(start_end) ~= size(TrialTable,1)
    %         error('Something is off with calculating stuff')
    %     end
    % 
    %     %FIRST FILL OUT THE MOVEMENT CONDITIONS
    %     %import hand movements
    %     opts = delimitedTextImportOptions("NumVariables", 7);
    %     opts.DataLines = [4, Inf];
    %     opts.Delimiter = "\t";
    %     opts.VariableNames = ["Timems", "Index_x", "Index_y", "Index_z", "Index_rotx", "Index_roty", "Index_rotz"];
    %     opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double"];
    %     opts.ExtraColumnsRule = "ignore";
    %     opts.EmptyLineRule = "read";
    %     ExperimentHandPositions = readtable(strcat("F:\Gian_Polina_2025\02Data\ID", ID, "\00Behavioural\Experiment_Hand_Positions_ID", ID, ".txt"), opts);
    %     clear opts
    % 
    %     %frequency_Unity = [frequency_Unity mean(diff(ExperimentHandPositions.Timems))];
    % 
    %     %movements = find(velocity_table.movement_conditions == "Move");
    %     total_rt = [];
    %     for se = 1:length(start_end)
    %         [value start_pos] = min(abs(ExperimentHandPositions.Timems - start_end(se,1)));
    %         [value end_pos] = min(abs(ExperimentHandPositions.Timems - start_end(se,2)));
    %         velocities = [];
    %         for j = 1:length(start_pos:end_pos)-1
    %             delta_space = sqrt((ExperimentHandPositions{start_pos+(j)-1,2}-ExperimentHandPositions{start_pos+(j),2})^2 + (ExperimentHandPositions{start_pos+(j)-1,4}-ExperimentHandPositions{start_pos+(j),4})^2);
    %             delta_time = (ExperimentHandPositions{start_pos+(j),1}-ExperimentHandPositions{start_pos+(j)-1,1})/1000; %in secs
    %             velocities = [velocities delta_space/delta_time];
    %         end
    %         if TrialTable.Trial_type(se) == 1 || TrialTable.Trial_type(se) == 3
    %             %plot(velocities)
    %             rt = (ExperimentHandPositions{end_pos,1} - ExperimentHandPositions{start_pos+find(velocities > 0.1,1)-1,1}); %do not take og start GO but when participant started to move
    %             total_rt = [total_rt; rt];
    %         else
    %             rt = (ExperimentHandPositions{end_pos,1} - ExperimentHandPositions{start_pos,1}); %do not take og start GO but when participant started to move
    %             total_rt = [total_rt; rt];
    %         end
    %     end
    % 
    %     TrialTable.rt = total_rt; 
    % 
    %     all_Behavioural.mean_rt_Stay{i} = mean(TrialTable.rt((TrialTable.Trial_type == 2  | TrialTable.Trial_type == 4))); 
    %     all_Behavioural.mean_rt_Move{i} = mean(TrialTable.rt((TrialTable.Trial_type == 2  | TrialTable.Trial_type == 4))); 
    %     all_Behavioural.mean_rt_Stay_T{i} = mean(TrialTable.rt((TrialTable.Trial_type == 2  | TrialTable.Trial_type == 4) & TrialTable.Stimulation == 1)); 
    %     all_Behavioural.mean_rt_Move_T{i} = mean(TrialTable.rt((TrialTable.Trial_type == 1  | TrialTable.Trial_type == 3) & TrialTable.Stimulation == 1)); 
    %     all_Behavioural.mean_rt_Stay_A{i} = mean(TrialTable.rt((TrialTable.Trial_type == 2  | TrialTable.Trial_type == 4) & TrialTable.Stimulation == 2)); 
    %     all_Behavioural.mean_rt_Move_A{i} = mean(TrialTable.rt((TrialTable.Trial_type == 1  | TrialTable.Trial_type == 3) & TrialTable.Stimulation == 2)); 
    %     all_Behavioural.mean_rt_Stay_C{i} = mean(TrialTable.rt((TrialTable.Trial_type == 2  | TrialTable.Trial_type == 4) & TrialTable.Stimulation == 3)); 
    %     all_Behavioural.mean_rt_Move_C{i} = mean(TrialTable.rt((TrialTable.Trial_type == 1  | TrialTable.Trial_type == 3) & TrialTable.Stimulation == 3));
    % else
    %     TrialTable.rt = nan(size(TrialTable,1),1);
    % end

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
category = ["mean_velocity_Stay_T", "mean_velocity_Stay_A", "mean_velocity_Stay_C", "mean_velocity_Move_T", "mean_velocity_Move_A", "mean_velocity_Move_C"];

figure;
plot((1:3)-0.05, [mean([all_Behavioural.(category(1)){:}]), ...
           mean([all_Behavioural.(category(2)){:}]), ...
           mean([all_Behavioural.(category(3)){:}])], ...
           'LineStyle', '-', 'Color', [1 0 0]);
hold on; 
plot((1:3)+0.05, [mean([all_Behavioural.(category(4)){:}]), ...
           mean([all_Behavioural.(category(5)){:}]), ...
           mean([all_Behavioural.(category(6)){:}])], ...
           'LineStyle', '-', 'Color', [0 1 0]);
legend({'Move', 'Stay'}, 'AutoUpdate', 'off', 'Location', 'NorthWest')
spaces = [1 2 3; 1 2 3];
for i = 1:length(category)
    space = i - 3*(i>3);
    if i > 3
        errorbar(space+0.05, mean([all_Behavioural.(category(i)){:}]), sqrt(var([all_Behavioural.(category(i)){:}]))./sqrt(numel(all_Behavioural.(category(i)))), 'g', 'CapSize', 0, 'LineWidth', 3);
    else
        errorbar(space-0.05, mean([all_Behavioural.(category(i)){:}]), sqrt(var([all_Behavioural.(category(i)){:}]))./sqrt(numel(all_Behavioural.(category(i)))), 'r', 'CapSize', 0, 'LineWidth', 3);
    end
end
ylim([0.45 0.75])
xlim([0.8 3.2])
xticks([1 2 3])
xticklabels({'Touch', 'Audio', 'Control'})
ylabel('Movement velocity (Uu/s)')
set(gcf, 'Position',  [100, 100, 400, 500])

prova = groupsummary(bigTrialTable, ["MoveStay", "Stimulation", "ID"], 'mean', "velocities");
prova.Stimulation = categorical(prova.Stimulation);
prova.MoveStay = categorical(prova.MoveStay);
prova.ID = categorical(prova.ID);
lm = fitlme(prova,'mean_velocities~MoveStay*Stimulation+(1|ID)', 'DummyVarCoding', 'effects');
anova(lm)

%% RT
prova = groupsummary(bigTrialTable, ["MoveStay", "Stimulation", "ID"], {"mean", "var"}, "RTs");
prova = groupsummary(prova, ["MoveStay", "Stimulation"], {"mean", "var"}, "mean_RTs");


figure;
plot((1:2)+0.05, [prova{4,4}, prova{5,4}], 'LineStyle', '-', 'Color', [0 1 0]); %move touch and audio
hold on; 
plot((1:2)-0.05, [prova{1,4}, prova{2,4}], 'LineStyle', '-', 'Color', [1 0 0]); %stay touch and audio
legend({'Move', 'Stay'}, 'AutoUpdate', 'off', 'Location', 'NorthWest')
spaces = [1 2; 1 2];
for i = 1:4
    space = i - 2*(i>2);
    if i > 2
        errorbar(space+0.05, prova{i+1,4}, sqrt(prova{i+1,5})./sqrt(prova{i+1,3}), 'g', 'CapSize', 0, 'LineWidth', 3);
    else
        errorbar(space-0.05, prova{i,4}, sqrt(prova{i,5})./sqrt(prova{i,3}), 'r', 'CapSize', 0, 'LineWidth', 3);
    end
end
xticks([1 2])
xlim([0.8 2.2])
ylim([650 800])
xticklabels({'Touch', 'Audio'})
ylabel('Response Time (ms)')
set(gcf, 'Position',  [100, 100, 250, 500])

figure;
plot((1:2), [prova{3,4}, prova{6,4}], 'LineStyle', '-', 'Color', [0.5 0.5 0.5]); %move touch and audio
hold on; 
errorbar(1, prova{3,4}, sqrt(prova{3,5})./sqrt(prova{3,3}), 'Color', [0.5 0.5 0.5], 'CapSize', 0, 'LineWidth', 3);
errorbar(2, prova{6,4}, sqrt(prova{6,5})./sqrt(prova{6,3}), 'Color', [0.5 0.5 0.5], 'CapSize', 0, 'LineWidth', 3);
xticks([1 2])
ylim([650 800])
xlim([0.8 2.2])
xticklabels({'Move', 'Stay',})
ylabel('Response Time (ms)')
set(gcf, 'Position',  [100, 100, 150, 500])


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

% %Test for differences across movement type, stimulus intensities and
% %stimulus type
% prova = groupsummary(bigTrialTable(bigTrialTable.Stimulation ~= 3,:), ["MoveStay", "Stimulation", "Intensities", "ID"], 'mean', "RTs");
% prova.Stimulation = categorical(prova.Stimulation);
% prova.Intensities = categorical(prova.Intensities); 
% prova.MoveStay = categorical(prova.MoveStay);
% prova.ID = categorical(prova.ID);
% lm = fitlme(prova,'mean_RTs ~ 1 + MoveStay + Stimulation + Intensities + MoveStay:Stimulation + MoveStay:Intensities + Stimulation:Intensities + MoveStay:Stimulation:Intensities+( 1 | ID )', 'DummyVarCoding', 'effects')
% lm = fitlme(prova,'mean_RTs ~ MoveStay*Stimulation*Intensities', 'DummyVarCoding', 'effects')
% anova(lm)



%% OVERALL ACCURACY
%Build up the table for the accuracy
bigTrialTable.Accuracy = bigTrialTable.Responses;
for i = 1:size(bigTrialTable,1)
    if bigTrialTable.Intensities(i) < 5 && bigTrialTable.Stimulation(i) ~= 3
        bigTrialTable.Accuracy(i) = abs(1 - bigTrialTable.Accuracy(i));
    end
    if bigTrialTable.Control(i) == 2 && bigTrialTable.Stimulation(i) == 3
        bigTrialTable.Accuracy(i) = abs(1 - bigTrialTable.Accuracy(i));
    end
end

%accuracy overall (omit central stimulus and control condition) 
prova = groupsummary(bigTrialTable(bigTrialTable.Intensities ~= 5, :), ["MoveStay", "Stimulation", "ID"], {"sum"}, "Accuracy");
prova.accuracy = prova.sum_Accuracy ./ prova.GroupCount * 100; 
prova = groupsummary(prova, ["MoveStay", "Stimulation"], {"mean", "var"}, "accuracy");

figure;
plot((1:2)+0.05, [prova{4,4}, prova{5,4}], 'LineStyle', '-', 'Color', [0 1 0]); %move touch and audio
hold on; 
plot((1:2)-0.05, [prova{1,4}, prova{2,4}], 'LineStyle', '-', 'Color', [1 0 0]); %stay touch and audio
legend({'Move', 'Stay'}, 'AutoUpdate', 'off', 'Location', 'NorthWest')
spaces = [1 2; 1 2];
for i = 1:4
    space = i - 2*(i>2);
    if i > 2
        errorbar(space+0.05, prova{i+1,4}, sqrt(prova{i+1,5})./sqrt(prova{i+1,3}), 'g', 'CapSize', 0, 'LineWidth', 3);
    else
        errorbar(space-0.05, prova{i,4}, sqrt(prova{i,5})./sqrt(prova{i,3}), 'r', 'CapSize', 0, 'LineWidth', 3);
    end
end
xticks([1 2])
ylim([75 95])
xlim([0.8 2.2])
xticklabels({'Touch', 'Audio'})
ylabel('Accuracy (%)')
set(gcf, 'Position',  [100, 100, 250, 500])

figure;
plot((1:2), [prova{3,4}, prova{6,4}], 'LineStyle', '-', 'Color', [0.5 0.5 0.5]); %move touch and audio
hold on; 
errorbar(1, prova{3,4}, sqrt(prova{3,5})./sqrt(prova{3,3}), 'Color', [0.5 0.5 0.5], 'CapSize', 0, 'LineWidth', 3);
errorbar(2, prova{6,4}, sqrt(prova{6,5})./sqrt(prova{6,3}), 'Color', [0.5 0.5 0.5], 'CapSize', 0, 'LineWidth', 3);
xticks([1 2])
ylim([75 95])
xlim([0.8 2.2])
xticklabels({'Move', 'Stay',})
ylabel('Accuracy (%)')
set(gcf, 'Position',  [100, 100, 150, 500])


%Test comparison task
prova = groupsummary(bigTrialTable(bigTrialTable.Intensities ~= 5 & bigTrialTable.Stimulation ~= 3, :), ["MoveStay", "Stimulation", "ID"], {"sum"}, "Accuracy");
prova.accuracy = prova.sum_Accuracy ./ prova.GroupCount * 100; 
prova.Stimulation = categorical(prova.Stimulation);
prova.MoveStay = categorical(prova.MoveStay);
prova.ID = categorical(prova.ID);
lm = fitlme(prova, 'accuracy~MoveStay*Stimulation+(1|ID)', 'dummyvarcoding', 'reference');
anova(lm)

%Test control task 
prova = groupsummary(bigTrialTable(bigTrialTable.Intensities == 0 & bigTrialTable.Stimulation == 3, :), ["MoveStay", "ID"], {"sum"}, "Accuracy");
prova.accuracy = prova.sum_Accuracy ./ prova.GroupCount * 100; 
prova.MoveStay = categorical(prova.MoveStay);
prova.ID = categorical(prova.ID);
lm = fitlme(prova, 'accuracy~MoveStay+(1|ID)');
anova(lm)

%% PSYCHOMETRIC FUNCITON USING PSIGNIFIT
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

    plot(result.data(:,1),result.data(:,2)./result.data(:,3),'o', 'Color', [colors(m,:), 0.2], 'LineWidth', 3);
    errorbar(result.data(:,1),result.data(:,2)./result.data(:,3), sqrt(var(tot_hits,0,2))./sqrt(28), 'Color', [colors(m,:), 0.2], 'CapSize', 0, 'LineWidth', 3, "LineStyle", "none");

    x = linspace(min(result.data(:,1)),max(result.data(:,1)),1000);
    fitValues = (1-result.Fit(3)-result.Fit(4))*arrayfun(@(x) result.options.sigmoidHandle(x,result.Fit(1),result.Fit(2)),x)+result.Fit(4);
    hline = plot(x, fitValues, 'Color', colors(m,:));

    thresh = plot([result.Fit(1),result.Fit(1)], [0, 0.5], 'Color', colors(m,:), 'LineStyle', '-', 'LineWidth', 3);
end
xlabel('Stimuli (absolute)')
ylabel('Hit proportion')
title('Psychometric function for Touch modality')
set(gcf, 'Position',  [100, 100, 650, 500])


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

    plot(result.data(:,1),result.data(:,2)./result.data(:,3),'o', 'Color', [colors(m,:), 0.2], 'LineWidth', 3);
    errorbar(result.data(:,1),result.data(:,2)./result.data(:,3), sqrt(var(tot_hits,0,2))./sqrt(28), 'Color', [colors(m,:), 0.2], 'CapSize', 0, 'LineWidth', 3, "LineStyle", "none");
    x = linspace(min(result.data(:,1)),max(result.data(:,1)),1000);
    fitValues = (1-result.Fit(3)-result.Fit(4))*arrayfun(@(x) result.options.sigmoidHandle(x,result.Fit(1),result.Fit(2)),x)+result.Fit(4);
    hline = plot(x, fitValues, 'Color', colors(m,:));
        
    thresh = plot([result.Fit(1),result.Fit(1)], [0, 0.5], 'Color', colors(m,:), 'LineStyle', '-', 'LineWidth', 3);
end
xlabel('Stimuli (absolute)')
ylabel('Hit proportion')
title('Psychometric function for Audio modality')
set(gcf, 'Position',  [100, 100, 650, 500])