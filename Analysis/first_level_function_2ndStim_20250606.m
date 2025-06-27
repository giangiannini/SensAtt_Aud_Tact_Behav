function [] = first_level_function_20250606(ID)
    addpath(genpath('C:/Users/nnu02/Documents/MATLAB/spm12'));

    folder = 'F:/Gian_Polina_2025/02Data/';

    ID = char(ID);
    
    %Stuff for SPM
    subj_folder = strcat(folder, 'ID', ID, '/01EEG_20250606/');

    %copy paste the loc file
    loc_dir = strcat(folder, 'ID', ID, '/00Behavioural/');

    suffix = '_denoise_subjective_2ndStim';
    %suffix = '_FINAL_FINAL_FINAL_subjective';
    %suffix = '_FINAL_FINAL_FINAL_new_second_stim_subjective';
    prefix = ''; 

    first_level_folder = strcat(folder, '/ID', ID, '/02FirstLevel/');
    if ~exist(first_level_folder, 'dir')
        mkdir(first_level_folder)
    end

    results_first_level = strcat(first_level_folder, prefix, '20250606', suffix);
    if ~exist(results_first_level, 'dir')
        mkdir(results_first_level)
    end

    %Stuff for FT
    caplocation = 'E:/02Data/03Utils/biosemi64.lay';
    neighbourslocation = 'E:/02Data/03Utils/biosemi64_neighb.mat';

    cd(subj_folder) %jump in the right folder

    %% IMPORT BEHAVIOURAL DATA
    load(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\01EEG_20250606\TrialTable.mat'));

    %% FIRST LEVEL
    matlabbatch{1}.spm.stats.factorial_design.dir = {results_first_level};
    dir_source = dir(strcat(subj_folder, 'spm/subjective_2ndStim_hEOG_tvEOG_thdMID', char(ID), '/', prefix, 'data', suffix, '.nii'));
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans = cellstr(spm_select('expand', strcat(dir_source.folder, filesep, dir_source.name)));
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).c = double(TrialTable.Stimulation == 1 & (TrialTable.Trial_type == 1 | TrialTable.Trial_type == 3));
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).cname = 'Touch_Move';
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(1).iCC = 5;
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(2).c = double(TrialTable.Stimulation == 1 & (TrialTable.Trial_type == 2 | TrialTable.Trial_type == 4));
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(2).cname = 'Touch_Stay';
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(2).iCC = 5;
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(3).c = double(TrialTable.Stimulation == 2 & (TrialTable.Trial_type == 1 | TrialTable.Trial_type == 3));
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(3).cname = 'Audio_Move';
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(3).iCC = 5;   
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(4).c = double(TrialTable.Stimulation == 2 & (TrialTable.Trial_type == 2 | TrialTable.Trial_type == 4));
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(4).cname = 'Audio_Stay';
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(4).iCC = 5;
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(5).c = double(TrialTable.Stimulation == 3 & (TrialTable.Trial_type == 1 | TrialTable.Trial_type == 3));
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(5).cname = 'Control_Move';
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(5).iCC = 5;        
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(6).c = double(TrialTable.Stimulation == 3 & (TrialTable.Trial_type == 2 | TrialTable.Trial_type == 4));
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(6).cname = 'Control_Stay';
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(6).iCC = 5;
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 0;
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
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'SA_Touch';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1 0 0 -1 1];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'SA_Audio';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 0 1 -1 -1 1];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Touch_Move_Control';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [1 0 0 0 -1 0];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Touch_Stay_Control';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0 1 0 0 0 -1];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'Audio_Move_Control';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [0 0 1 0 -1 0];
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'Audio_Stay_Control';
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [0 0 0 1 0 -1];
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';

    spm_jobman('run', matlabbatch);
    clear matlabbatch
end