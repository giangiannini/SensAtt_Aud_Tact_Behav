%% SECOND LEVEL 
clear;clc;
addpath(genpath('C:/Users/nnu02/Documents/MATLAB/spm12'));
addpath('C:/Users/nnu02/Documents/MATLAB/fieldtrip-20220827');
ft_defaults

subjects = ["01" "03" "04" "05" "06" "07" "08" "09" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30"];
%subjects = ["04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25"];

%subjects = ["02" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20"];

folder = 'F:/Gian_Polina_2025/02Data/';

% suffixes = ["_standard_position_all_standards", "_standard_position_before_deviants", ...
%             "_subjective_position_all_standards", "_subjective_position_before_deviants", ...
%             "_subjective_position_realigned_all_standards", "_subjective_position_realigned_before_deviants", ...
%             "_standard_position_old_all_standards", "_standard_position_old_before_deviants"]; 

suffixes = ["_denoise_subjective_2ndstim"]; 

suffixes_first_level = char("_denoise_subjective_2ndStim");

for mm = 1:length(suffixes)
    suffix = char(suffixes(mm));
    prefix = '';
    
    %Set second level folder for main eff post-stim
    results_second_level_Touch = strcat(folder, '00GroupAnalyses/', prefix, '20250606_Touch', suffix);
    if ~exist(results_second_level_Touch, 'dir')
        mkdir(results_second_level_Touch)
    end

    results_second_level_Audio = strcat(folder, '00GroupAnalyses/', prefix, '20250606_Audio', suffix);
    if ~exist(results_second_level_Audio, 'dir')
        mkdir(results_second_level_Audio)
    end
    
    spm eeg
    
    %% SECOND LEVEL STATISTICS TOUCH
    matlabbatch{1}.spm.stats.factorial_design.dir = {results_second_level_Touch};
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).name = 'subject';
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).dept = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).name = 'Touch_noTouch';
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).dept = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).name = 'Move_Stay';
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).dept = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).ancova = 0;

    for i = 1:length(subjects)
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(i).scans = {
                                                                                      strcat('F:\Gian_Polina_2025\02Data\ID', char(subjects(i)), '\02FirstLevel\', '20250606', suffixes_first_level, '\beta_0001.nii,1')
                                                                                      strcat('F:\Gian_Polina_2025\02Data\ID', char(subjects(i)), '\02FirstLevel\', '20250606', suffixes_first_level, '\beta_0002.nii,1')
                                                                                      strcat('F:\Gian_Polina_2025\02Data\ID', char(subjects(i)), '\02FirstLevel\', '20250606', suffixes_first_level, '\beta_0005.nii,1')
                                                                                      strcat('F:\Gian_Polina_2025\02Data\ID', char(subjects(i)), '\02FirstLevel\', '20250606', suffixes_first_level, '\beta_0006.nii,1')
                                                                                      };
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(i).conds = [1 1
                                                                                      1 2
                                                                                      2 1
                                                                                      2 2];
    end
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.inter.fnums = [2
                                                                                      3];
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{2}.fmain.fnum = 1;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    Con=spm_make_contrasts([2 2]);
    factors_numbers = ["1"; "2"];
    factors_names = ["Touch"; "Movement"];
    for i = 2:length(Con)
        matlabbatch{3}.spm.stats.con.consess{i-1}.fcon.name = replace(Con(i).name, factors_numbers, factors_names);
        matlabbatch{3}.spm.stats.con.consess{i-1}.fcon.weights = Con(i).c;
        matlabbatch{3}.spm.stats.con.consess{i-1}.fcon.sessrep = 'none';
    end
    spm_jobman('run', matlabbatch);
    clear matlabbatch

    %% SECOND LEVEL STATISTICS AUDIO
    matlabbatch{1}.spm.stats.factorial_design.dir = {results_second_level_Audio};
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).name = 'subject';
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).dept = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).name = 'Audio_noAudio';
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).dept = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).name = 'Move_Stay';
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).dept = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).ancova = 0;

    for i = 1:length(subjects)
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(i).scans = {
                                                                                      strcat('F:\Gian_Polina_2025\02Data\ID', char(subjects(i)), '\02FirstLevel\', '20250606', suffixes_first_level, '\beta_0003.nii,1')
                                                                                      strcat('F:\Gian_Polina_2025\02Data\ID', char(subjects(i)), '\02FirstLevel\', '20250606', suffixes_first_level, '\beta_0004.nii,1')
                                                                                      strcat('F:\Gian_Polina_2025\02Data\ID', char(subjects(i)), '\02FirstLevel\', '20250606', suffixes_first_level, '\beta_0005.nii,1')
                                                                                      strcat('F:\Gian_Polina_2025\02Data\ID', char(subjects(i)), '\02FirstLevel\', '20250606', suffixes_first_level, '\beta_0006.nii,1')
                                                                                      };
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(i).conds = [1 1
                                                                                      1 2
                                                                                      2 1
                                                                                      2 2];
    end
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.inter.fnums = [2
                                                                                      3];
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{2}.fmain.fnum = 1;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    Con=spm_make_contrasts([2 2]);
    factors_numbers = ["1"; "2"];
    factors_names = ["Audio"; "Movement"];
    for i = 2:length(Con)
        matlabbatch{3}.spm.stats.con.consess{i-1}.fcon.name = replace(Con(i).name, factors_numbers, factors_names);
        matlabbatch{3}.spm.stats.con.consess{i-1}.fcon.weights = Con(i).c;
        matlabbatch{3}.spm.stats.con.consess{i-1}.fcon.sessrep = 'none';
    end
    spm_jobman('run', matlabbatch);
    clear matlabbatch
end
