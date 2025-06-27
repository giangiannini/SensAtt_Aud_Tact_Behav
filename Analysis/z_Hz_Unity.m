%% Frequency Unity
subjects = ["01" "03" "04" "05" "06" "07" "08" "09" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30"];

frequency_Unity = []; 

for i = 1:length(subjects)

    ID = char(subjects(i)); 

    %FIRST FILL OUT THE MOVEMENT CONDITIONS
    %import hand movements
    opts = delimitedTextImportOptions("NumVariables", 7);
    opts.DataLines = [4, Inf];
    opts.Delimiter = "\t";
    opts.VariableNames = ["Timems", "Index_x", "Index_y", "Index_z", "Index_rotx", "Index_roty", "Index_rotz"];
    opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    ExperimentHandPositions = readtable(strcat('F:\Gian_Polina_2025\02Data\ID', ID, "\00Behavioural\Experiment_Hand_Positions_ID", ID, ".txt"), opts);
    clear opts

    frequency_Unity = [frequency_Unity mean(diff(ExperimentHandPositions.Timems))];

end

Hz_mean = mean(1000./frequency_Unity)
Hz_std = std(1000./frequency_Unity)
