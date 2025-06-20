clear;clc;
addpath(genpath('C:/Users/nnu02/Documents/MATLAB/spm12'));
addpath('C:/Users/nnu02/Documents/MATLAB/fieldtrip-20220827');
ft_defaults

subjects = ["01" "03" "04" "05" "06" "07" "08" "09" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30"];

folder = 'F:/Gian_Polina_2025/02Data/';

prefix = []; 
suffixes = ["_denoise_subjective"]; 
%suffixes = ["_FINAL_FINAL_FINAL_new_subjective", "_FINAL_FINAL_FINAL_subjective"];

for mm = 1:length(suffixes)
    
    suffix = suffixes(mm);

    %Set second level folder for main eff post-stim
    results_second_level_Touch = strcat(folder, '00GroupAnalyses/', prefix, '20250606_corr_Touch_Thresh', suffix);
    results_second_level_Audio = strcat(folder, '00GroupAnalyses/', prefix, '20250606_corr_Audio_Thresh', suffix);

    %% LOAD CORR INDICES
    load("F:\Gian_Polina_2025\02Data\00GroupAnalyses\corr_index_thresh")

    %% LOAD IMAGES
    for i = 1:length(subjects)
        ID = char(subjects(i));
        raw_Touch(:,:,:,i) = niftiread(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\02FirstLevel\20250606_denoise_subjective\con_0001.nii'));
        raw_Audio(:,:,:,i) = niftiread(strcat('F:\Gian_Polina_2025\02Data\ID', ID, '\02FirstLevel\20250606_denoise_subjective\con_0002.nii'));
    end
    
    %% PLOT CORRELATION TOUCH
    %create folder for imgs
    img_folder = strcat(results_second_level_Touch, '/00corr_Touch');
    if ~exist(img_folder)
        mkdir(img_folder)
    end
    
    %Extract image from cluster
    load(strcat(results_second_level_Touch, '/SPM.mat'))
    spm('defaults', 'EEG')
    matlabbatch{1}.spm.stats.results.spmmat = cellstr(strcat(results_second_level_Touch, '/SPM.mat'));
    matlabbatch{1}.spm.stats.results.conspec.titlestr = '';
    matlabbatch{1}.spm.stats.results.conspec.contrasts = 1;
    matlabbatch{1}.spm.stats.results.conspec.threshdesc = 'none';
    matlabbatch{1}.spm.stats.results.conspec.thresh = 0.001;
    matlabbatch{1}.spm.stats.results.conspec.extent = 0;
    matlabbatch{1}.spm.stats.results.conspec.conjunction = 1;
    matlabbatch{1}.spm.stats.results.conspec.mask.none = 1;
    matlabbatch{1}.spm.stats.results.units = 2;
    matlabbatch{1}.spm.stats.results.export{1}.nary.basename = 'Corr';
    spm_jobman('run', matlabbatch); 
    clear matlabbatch
    
    %extract slope image
    slopes = niftiread(strcat(results_second_level_Touch, "\beta_0001.nii"));

    %find where to plot data (centroid) ((FOR THE TOUCH CONDITION I WILL
    %TAKE THE SECOND LEVEL ANALYSES OF THE ERP AS CENTROID AND CLUSTER)
    index = zeros(1,3);
    Tmap = niftiread(strcat('F:\Gian_Polina_2025\02Data\00GroupAnalyses\20250606_Touch_denoise_subjective', '\spmF_0003.nii'));
    %Tmap = niftiread(strcat(results_second_level_Touch, "\spmT_0001.nii"));
    [a b] = max(Tmap(:));
    [index(1) index(2) index(3)] = ind2sub(size(Tmap), b);

    %Confidence intervals
    resms = niftiread(strcat(results_second_level_Touch, '\ResMS.nii'));
    resms_val = resms(index(1), index(2), index(3));
    b_range = linspace(min(corr_index_thresh(:,1))-0.1, max(corr_index_thresh(:,1))+0.1, 100)';
    y_fit = b_range * slopes(index(1), index(2), index(3)); 
    XtX_inv = 1 / sum(corr_index_thresh(:,1).^2);  % For model a ~ b + 0    
    se_fit = sqrt(resms_val * (b_range.^2) * XtX_inv);
    ci = 1.96 * se_fit;  % 95% CI
    
    figure; 
    plot(corr_index_thresh(:,1), squeeze(raw_Touch(index(1), index(2), index(3),:)), '*', 'Color',[0.5 0.5 0.5])
    % p = polyfit(corr_index_thresh(:,2), SA_Audio_points', 1);
    % y_fit = polyval(p, corr_index_thresh(:,2));
    hold on; 
    plot(b_range, y_fit, 'Color',[0.5 0.5 0.5], 'LineWidth', 3); 
    x = b_range;
    y_upper = y_fit + ci;
    y_lower = y_fit - ci;
    x_patch = [x; flipud(x)];
    y_patch = [y_upper; flipud(y_lower)];
    fill(x_patch, y_patch, [0.7 0.7 0.7], 'EdgeColor', 'none', 'FaceAlpha', 0.4);  % light red
    xlim([min(b_range) max(b_range)])
    xlabel('Behavioural attenuation')
    ylabel('Electrophysiological attenuation')
    title('Correlation in Touch modality - Centroid')



    %find where to plot data (cluster)
    index = [];
    Tmap = niftiread(strcat('F:\Gian_Polina_2025\02Data\00GroupAnalyses\20250606_Touch_denoise_subjective', '\spmF_0003_Int_Touch_Control.nii'));
    mask = Tmap == 1;
    indices = find(mask == 1);
    for i = 1:length(indices)
        [index(i,1) index(i,2) index(i,3)] = ind2sub(size(Tmap), indices(i));
    end

    resms = niftiread(strcat(results_second_level_Touch, '\ResMS.nii'));
    
    data_to_plot = [];
    slope_to_plot = [];
    resms_val = [];
    for i = 1:size(index,1)
        data_to_plot(i,:) = squeeze(raw_Touch(index(i,1), index(i,2), index(i,3),:))';
        slope_to_plot(i,:) = squeeze(slopes(index(i,1), index(i,2), index(i,3)))';
        resms_val(i,:) = squeeze(resms(index(i,1), index(i,2), index(i,3)))';
    end
    
    %Confidence intervals
    b_range = linspace(min(corr_index_thresh(:,1))-0.1, max(corr_index_thresh(:,1))+0.1, 100)';
    y_fit = b_range * mean(slope_to_plot); 
    XtX_inv = 1 / sum(corr_index_thresh(:,1).^2);  % For model a ~ b + 0    
    se_fit = sqrt(mean(resms_val) * (b_range.^2) * XtX_inv);
    ci = 1.96 * se_fit;  % 95% CI
    
    figure; 
    plot(corr_index_thresh(:,1), mean(data_to_plot), '*', 'Color',[0.5 0.5 0.5])
    % p = polyfit(corr_index_thresh(:,2), SA_Audio_points', 1);
    % y_fit = polyval(p, corr_index_thresh(:,2));
    hold on; 
    plot(b_range, y_fit, 'Color',[0.5 0.5 0.5], 'LineWidth', 3); 
    x = b_range;
    y_upper = y_fit + ci;
    y_lower = y_fit - ci;
    x_patch = [x; flipud(x)];
    y_patch = [y_upper; flipud(y_lower)];
    fill(x_patch, y_patch, [0.7 0.7 0.7], 'EdgeColor', 'none', 'FaceAlpha', 0.4);  % light red
    xlim([min(b_range) max(b_range)])
    xlabel('Behavioural attenuation')
    ylabel('Electrophysiological attenuation')
    title('Correlation in Touch modality - Cluster')

    
    %% PLOT CORR AUDIO
    %create folder for imgs
    img_folder = strcat(results_second_level_Audio, '/00corr_Audio');
    if ~exist(img_folder)
        mkdir(img_folder)
    end
    
    %Extract image from cluster
    load(strcat(results_second_level_Audio, '/SPM.mat'))
    spm('defaults', 'EEG')
    matlabbatch{1}.spm.stats.results.spmmat = cellstr(strcat(results_second_level_Audio, '/SPM.mat'));
    matlabbatch{1}.spm.stats.results.conspec.titlestr = '';
    matlabbatch{1}.spm.stats.results.conspec.contrasts = 1;
    matlabbatch{1}.spm.stats.results.conspec.threshdesc = 'none';
    matlabbatch{1}.spm.stats.results.conspec.thresh = 0.001;
    matlabbatch{1}.spm.stats.results.conspec.extent = 0;
    matlabbatch{1}.spm.stats.results.conspec.conjunction = 1;
    matlabbatch{1}.spm.stats.results.conspec.mask.none = 1;
    matlabbatch{1}.spm.stats.results.units = 2;
    matlabbatch{1}.spm.stats.results.export{1}.nary.basename = 'Corr';
    spm_jobman('run', matlabbatch); 
    clear matlabbatch
    
    %extract slope image
    slopes = niftiread(strcat(results_second_level_Audio, '\beta_0001.nii'));

    %find where to plot data (centroid)
    index = zeros(1,3);
    Tmap = niftiread(strcat(results_second_level_Audio, '\spmT_0001.nii'));
    [a b] = max(Tmap(:));
    [index(1) index(2) index(3)] = ind2sub(size(Tmap), b);

    %Confidence intervals
    resms = niftiread(strcat(results_second_level_Audio, '\ResMS.nii'));
    resms_val = resms(index(1), index(2), index(3));
    b_range = linspace(min(corr_index_thresh(:,2))-0.1, max(corr_index_thresh(:,2))+0.1, 100)';
    y_fit = b_range * slopes(index(1), index(2), index(3)); 
    XtX_inv = 1 / sum(corr_index_thresh(:,2).^2);  % For model a ~ b + 0    
    se_fit = sqrt(resms_val * (b_range.^2) * XtX_inv);
    ci = 1.96 * se_fit;  % 95% CI
    
    figure; 
    plot(corr_index_thresh(:,2), squeeze(raw_Audio(index(1), index(2), index(3),:)), '*', 'Color',[0.5 0.5 0.5])
    % p = polyfit(corr_index_thresh(:,2), SA_Audio_points', 1);
    % y_fit = polyval(p, corr_index_thresh(:,2));
    hold on; 
    plot(b_range, y_fit, 'Color',[0.5 0.5 0.5], 'LineWidth', 3); 
    x = b_range;
    y_upper = y_fit + ci;
    y_lower = y_fit - ci;
    x_patch = [x; flipud(x)];
    y_patch = [y_upper; flipud(y_lower)];
    fill(x_patch, y_patch, [0.7 0.7 0.7], 'EdgeColor', 'none', 'FaceAlpha', 0.4);  % light red
    xlim([min(b_range) max(b_range)])
    xlabel('Behavioural attenuation')
    ylabel('Electrophysiological attenuation')
    title('Correlation in Audio modality - Centroid')



    %find where to plot data (cluster)
    index = [];
    Tmap = niftiread(strcat(results_second_level_Audio, '\spmT_0001_Corr.nii'));
    mask = Tmap == 1;
    indices = find(mask == 1);
    for i = 1:length(indices)
        [index(i,1) index(i,2) index(i,3)] = ind2sub(size(Tmap), indices(i));
    end

    resms = niftiread(strcat(results_second_level_Audio, '\ResMS.nii'));
    
    data_to_plot = [];
    slope_to_plot = [];
    resms_val = [];
    for i = 1:size(index,1)
        data_to_plot(i,:) = squeeze(raw_Audio(index(i,1), index(i,2), index(i,3),:))';
        slope_to_plot(i,:) = squeeze(slopes(index(i,1), index(i,2), index(i,3)))';
        resms_val(i,:) = squeeze(resms(index(i,1), index(i,2), index(i,3)))';
    end
    
    %Confidence intervals
    b_range = linspace(min(corr_index_thresh(:,2))-0.1, max(corr_index_thresh(:,2))+0.1, 100)';
    y_fit = b_range * mean(slope_to_plot); 
    XtX_inv = 1 / sum(corr_index_thresh(:,2).^2);  % For model a ~ b + 0    
    se_fit = sqrt(mean(resms_val) * (b_range.^2) * XtX_inv);
    ci = 1.96 * se_fit;  % 95% CI
    
    figure; 
    plot(corr_index_thresh(:,2), mean(data_to_plot), '*', 'Color',[0.5 0.5 0.5])
    hold on; 
    plot(b_range, y_fit, 'Color',[0.5 0.5 0.5], 'LineWidth', 3); 
    x = b_range;
    y_upper = y_fit + ci;
    y_lower = y_fit - ci;
    x_patch = [x; flipud(x)];
    y_patch = [y_upper; flipud(y_lower)];
    fill(x_patch, y_patch, [0.7 0.7 0.7], 'EdgeColor', 'none', 'FaceAlpha', 0.4);  % light red
    xlim([min(b_range) max(b_range)])
    xlabel('Behavioural attenuation')
    ylabel('Electrophysiological attenuation')
    title('Correlation in Audio modality - Cluster')

end
