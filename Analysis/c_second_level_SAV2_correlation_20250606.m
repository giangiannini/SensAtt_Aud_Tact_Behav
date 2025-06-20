%% SECOND LEVEL 
clear;clc;
addpath(genpath('C:/Users/nnu02/Documents/MATLAB/spm12'));
addpath('C:/Users/nnu02/Documents/MATLAB/fieldtrip-20220827');
ft_defaults

subjects = ["01" "03" "04" "05" "06" "07" "08" "09" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30"];

folder = 'F:/Gian_Polina_2025/02Data/';

% suffixes = ["_standard_position_all_standards", "_standard_position_before_deviants", ...
%             "_subjective_position_all_standards", "_subjective_position_before_deviants", ...
%             "_subjective_position_realigned_all_standards", "_subjective_position_realigned_before_deviants", ...
%             "_standard_position_old_all_standards", "_standard_position_old_before_deviants"]; 

suffixes = ["_denoise_subjective"];
suffix_first_level = '_denoise_subjective';

for mm = 1:length(suffixes)
    suffix = char(suffixes(mm));
    prefix = '';
    
    %Set second level folder for main eff post-stim
    results_second_level_Touch_thresh = strcat(folder, '00GroupAnalyses/', prefix, '20250606_corr_Touch_Thresh', suffix);
    if ~exist(results_second_level_Touch_thresh, 'dir')
        mkdir(results_second_level_Touch_thresh)
    end

    results_second_level_Audio_thresh = strcat(folder, '00GroupAnalyses/', prefix, '20250606_corr_Audio_Thresh', suffix);
    if ~exist(results_second_level_Audio_thresh, 'dir')
        mkdir(results_second_level_Audio_thresh)
    end

    results_second_level_Touch_slope = strcat(folder, '00GroupAnalyses/', prefix, '20250606_corr_Touch_Slope', suffix);
    if ~exist(results_second_level_Touch_slope, 'dir')
        mkdir(results_second_level_Touch_slope)
    end

    results_second_level_Audio_slope = strcat(folder, '00GroupAnalyses/', prefix, '20250606_corr_Audio_Slope', suffix);
    if ~exist(results_second_level_Audio_slope, 'dir')
        mkdir(results_second_level_Audio_slope)
    end
    
    spm eeg

    %% EXTRACT CORR INDICES 
    if ~isfile("F:\Gian_Polina_2025\02Data\00GroupAnalyses\corr_index_thresh.mat")
        corr_index_thresh = []; 
    
        table_thresholds_audio = []; 
        table_thresholds_touch = []; 
    
        table_slopes_audio = []; 
        table_slopes_touch = []; 
    
        all_Behavioural = []; 
    
        for i = 1:length(subjects)
            ID = char(subjects(i)); 
            load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606', "\ExperimentLog.mat"))
            load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606', "\TrialTable.mat"))
    
            Stimuli = TrialTable.Stim_tactile_2(:) + TrialTable.Stim_auditory_2(:);
            Responses = ExperimentLog((ExperimentLog.Event_Name == "Low" | ExperimentLog.Event_Name == "High"),:);
            Responses.Stimuli = Stimuli; 
            Responses.Event_Name_2(Responses.Event_Name == "High") = 1; 
    
            trialtype = [1 3; 2 4];
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
    
            conditions = ["Hits_Touch_Move", "Hits_Touch_Stay"];
            for mm = 1:length(conditions)
                data = [(1:9)', all_Behavioural.(conditions(mm)){i}.fun1_Event_Name_2, all_Behavioural.(conditions(mm)){i}.GroupCount];
                options = struct; 
                options.sigmoidName = 'logistic'; 
                options.expType = 'YesNo';
                result = psignifit(data,options);
                slope = getSlope(result, 5); 
                threshold = getThreshold(result, 0.5);
                table_thresholds_touch = [table_thresholds_touch; mm, i, threshold];
                table_slopes_touch = [table_slopes_touch; mm, i, slope];
            end
    
            conditions = ["Hits_Audio_Move", "Hits_Audio_Stay"];
            for mm = 1:length(conditions)
                data = [(1:9)', all_Behavioural.(conditions(mm)){i}.fun1_Event_Name_2, all_Behavioural.(conditions(mm)){i}.GroupCount];
                options = struct; 
                options.sigmoidName = 'logistic'; 
                options.expType = 'YesNo';
                result = psignifit(data,options);
                slope = getSlope(result, 5); 
                threshold = getThreshold(result, 0.5);
                table_thresholds_audio = [table_thresholds_audio; mm, i, threshold];
                table_slopes_audio = [table_slopes_audio; mm, i, slope];
            end
        end
    
        table_thresholds_touch = array2table(table_thresholds_touch, 'VariableNames', {'MoveStay', 'ID', 'Threshold'});
        table_thresholds_audio = array2table(table_thresholds_audio, 'VariableNames', {'MoveStay', 'ID', 'Threshold'});
    
        table_slopes_touch = array2table(table_slopes_touch, 'VariableNames', {'MoveStay', 'ID', 'Slope'});
        table_slopes_audio = array2table(table_slopes_audio, 'VariableNames', {'MoveStay', 'ID', 'Slope'});
    
    
        corr_index_thresh(:,1) = table_thresholds_touch.Threshold(1:2:end) - table_thresholds_touch.Threshold(2:2:end);
        corr_index_thresh(:,2) = table_thresholds_audio.Threshold(1:2:end) - table_thresholds_audio.Threshold(2:2:end);
    
        corr_index_slope(:,1) = table_slopes_touch.Slope(1:2:end) ./ table_slopes_touch.Slope(2:2:end);
        corr_index_slope(:,2) = table_slopes_audio.Slope(1:2:end) ./ table_slopes_audio.Slope(2:2:end);
    
        save("F:\Gian_Polina_2025\02Data\00GroupAnalyses\corr_index_thresh", "corr_index_thresh")
        save("F:\Gian_Polina_2025\02Data\00GroupAnalyses\corr_index_slope", "corr_index_slope")
    else
        load("F:\Gian_Polina_2025\02Data\00GroupAnalyses\corr_index_thresh")
        load("F:\Gian_Polina_2025\02Data\00GroupAnalyses\corr_index_slope")
    end
    
    %% SECOND LEVEL STATISTICS TOUCH
    %thresh
    matlabbatch{1}.spm.stats.factorial_design.dir = {results_second_level_Touch_thresh};
    for i = 1:length(subjects)
        matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans{i,1} = strcat('F:\Gian_Polina_2025\02Data\ID', char(subjects(i)), '\02FirstLevel\', '20250606', suffix_first_level, '\con_0001.nii,1');
    end
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).c = corr_index_thresh(:,1);
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).cname = 'SA';
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.iCC = 5;
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 0;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    %matlabbatch{1}.spm.stats.factorial_design.masking.em = {'F:\Gian_Polina_2025\02Data\00GroupAnalyses\20250606_Touch_denoise_subjective\cluster1.nii'};
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Positive corr';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Negative corr';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    spm_jobman('run', matlabbatch);
    clear matlabbatch


    %slope
    matlabbatch{1}.spm.stats.factorial_design.dir = {results_second_level_Touch_slope};
    for i = 1:length(subjects)
        matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans{i,1} = strcat('F:\Gian_Polina_2025\02Data\ID', char(subjects(i)), '\02FirstLevel\', '20250606', suffix_first_level, '\con_0001.nii,1');
    end
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).c = corr_index_slope(:,1);
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).cname = 'SA';
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.iCC = 5;
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 0;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    %matlabbatch{1}.spm.stats.factorial_design.masking.em = {'F:\Gian_Polina_2025\02Data\00GroupAnalyses\20250606_Touch_denoise_subjective\cluster1.nii'};
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Positive corr';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Negative corr';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    spm_jobman('run', matlabbatch);
    clear matlabbatch



    %% SECOND LEVEL STATISTICS AUDIO
    %thresh
    matlabbatch{1}.spm.stats.factorial_design.dir = {results_second_level_Audio_thresh};
    for i = 1:length(subjects)
        matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans{i,1} = strcat('F:\Gian_Polina_2025\02Data\ID', char(subjects(i)), '\02FirstLevel\', '20250606', suffix_first_level, '\con_0002.nii,1');
    end
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).c = corr_index_thresh(:,2);
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).cname = 'SA';
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.iCC = 5;
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 0;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    %matlabbatch{1}.spm.stats.factorial_design.masking.em = {'F:\Gian_Polina_2025\02Data\00GroupAnalyses\20250606_Audio_denoise_subjective\cluster1.nii'};
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Positive corr';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Negative corr';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    spm_jobman('run', matlabbatch);
    clear matlabbatch

    %slope
    matlabbatch{1}.spm.stats.factorial_design.dir = {results_second_level_Audio_slope};
    for i = 1:length(subjects)
        matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans{i,1} = strcat('F:\Gian_Polina_2025\02Data\ID', char(subjects(i)), '\02FirstLevel\', '20250606', suffix_first_level, '\con_0002.nii,1');
    end
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).c = corr_index_slope(:,2);
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).cname = 'SA';
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.iCC = 5;
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 0;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    %matlabbatch{1}.spm.stats.factorial_design.masking.em = {'F:\Gian_Polina_2025\02Data\00GroupAnalyses\20250606_Audio_denoise_subjective\cluster1.nii'};
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Positive corr';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Negative corr';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    spm_jobman('run', matlabbatch);
    clear matlabbatch
end
