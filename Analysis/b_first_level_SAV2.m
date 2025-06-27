clc;clear;
addpath(genpath('C:/Users/nnu02/Documents/MATLAB/spm12'));
addpath('C:/Users/nnu02/Documents/MATLAB/fieldtrip-master');
addpath('E:/02Data/03Utils/Functions/');
ft_defaults;
subjects = ["01" "03" "04" "05" "06" "07" "08" "09" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30"];
%subjects = ["01" "03" "04" "05" "06" "07" "08" "09" "11" "12" "13" "14" "15" "16" "17" "18" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30"];
% for i = 1:length(subjects)
%     SAV2_convert2imgs_20250606(char(subjects(i)))
%     first_level_function_20250606(char(subjects(i)))
% end

for i = 1:length(subjects)
    SAV2_convert2imgs_2ndStim_20250606(char(subjects(i)))
    first_level_function_2ndStim_20250606(char(subjects(i)))
end
