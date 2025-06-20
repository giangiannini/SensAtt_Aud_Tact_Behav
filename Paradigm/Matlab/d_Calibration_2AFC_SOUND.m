%% 2AFC calibration
% This script will run a 2AFC task, starting from an input voltage of xx
% mA, it will automatically generate a staircase of 7 stimuli (-20% to 20%
% around the original stimulus).
% The 2AFC task will then continue by presenting to participants always the
% same stimulation (originally inputted) and will require them to compare
% it against any other 7 stimuli for an n amount of times. 

clear; clc; 

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% FIELDS TO MODIFY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

OG_dB = 90; %dB
n = 6; %amount of comparisons for each stimulation to the OG_intensity. 
max_distance = 12; %percent

ID = ['30']; % change the ID field to save it in the correct location. 

session = 1; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Log = []; 
Log.trials = []; 
Log.responses = []; 

base_folder = 'C:\Gian\GG_SensAtt_V2_2025\02Data';
subj_folder = strcat(base_folder, '\ID', ID, '\00Behavioural');

if isfile(strcat(subj_folder, '\new_intensities_auditory.mat'))
    load(strcat(subj_folder, "\new_intensities_auditory.mat"))
    session = 2; 
    sprintf('Loading previous experiment data')
else
    sprintf('Running calibration for the first time')
end

intensities_n = 9; 


%% Constants for db conversion
% Constants for Sennheiser HD206
sensitivity_dB = 108;         % Sensitivity in dB SPL per 1 V
impedance = 24;              % Impedance in ohms
V_ref = 1;               % Reference power in watts (1 mW)
G_dB = 10;                   % Amplifier gain in dB
G = 10^(G_dB/20);            % Convert dB gain to linear

%% Analog Output Configuration
config_io;
outp(16376,0);
ao = aio_setup64([3]);

%% Intensities and trial table
if isfile(strcat(subj_folder, '\new_intensities_auditory.mat'))
    intensities = new_intensities_auditory; 
else
    intensities = linspace(OG_dB*(1-max_distance/100), OG_dB*(1+max_distance/100),9);
end

iti = 800 + (1000-800) .* rand(n*9,1); %generate n*9 random numbers between 1400 and 1600.

Log.trials = [repmat(intensities', n, 1), iti, repmat([1:2]', length(intensities)*n/2,1)];
Log.trials = Shuffle(Log.trials); 

Log.intensities = intensities; 
Log.n = n; 

Stim1_V = spl_to_voltage(OG_dB, sensitivity_dB, V_ref, G);

Log.stim1_V = Stim1_V;
Log.stim1_dB = OG_dB;

%% Generate Stimulus Waveforms
stim_len = 10;                                                             
stim_wave = zeros(5000,1);
stim_wave(2:(stim_len+1)) = 1;  

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% START THE EXP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set Up Experiment Screen
close all;
Screen('Preference', 'SkipSyncTests', 1);
% Get the screen numbers
screens = Screen('Screens');
% Select the external screen if it is present, else revert to the native screen
screenNumber = 1;
% Define black, white and grey
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
grey = white / 2;
% Open an on screen window and color it grey
[window, windowRect] = Screen('OpenWindow', screenNumber, grey); %[10 20 600 600] or screens
% get pixels
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
% Set the blend funciton for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
% Query the frame duration
ifi = Screen('GetFlipInterval', window);
% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
% Setup the text type for the window
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 36);
% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);
% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 20;
% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
% Set the line width for our fixation cross
lineWidthPix = 4;
waitframes = 1; 
% Draw the fixation cross in white, set it to the center of our screen and
% set good quality antialiasing
Screen('DrawLines', window, allCoords,...
    lineWidthPix, white, [xCenter yCenter]);
% Flip to the screen
HideCursor();
Screen('Flip', window);

%% Define Keys of Interest
KbName('UnifyKeyNames')
enterKey = KbName('return');
spaceKey = KbName('space');


escapeKey = KbName('ESCAPE');
leftKey = KbName('DownArrow');
rightKey = KbName('UpArrow');
WaitSecs(5);

%% Draw Instructions
Screen('TextSize', window, 30);
DrawFormattedText(window, ...
    ['In this calibration phase you will receive two stimulations. \n ' ...
    'Your task is to compare the second against the first one and report \n' ...
    'whether it was High or Low.'], ...
    'center', screenYpixels * 0.5, black,[],[],[],2);
Screen('Flip', window);
KbStrokeWait;

%% Start sequence
for i = 1:size(Log.trials,1)
    %% first prepare stimulus and send
    stop(ao);
    Stim1_V = spl_to_voltage(OG_dB, sensitivity_dB, V_ref, G);
    queueOutputData(ao, stim_wave*Stim1_V);
    
    %% ITI
    Screen('DrawLines', window, allCoords,...
    lineWidthPix, white, [xCenter yCenter]);
    vbl = Screen('Flip', window);

    trial_start = vbl; 

%     Screen('DrawLines', window, allCoords,...
%     lineWidthPix, white, [xCenter yCenter]);
%     vbl = Screen('Flip', window, vbl + ((Log.trials(i,2)/1000/ifi - 1) - 0.5) * ifi);

    %% 1 stimulus
    Screen('TextSize', window, 40);
    DrawFormattedText(window, ...
    '1', ...
    'center', screenYpixels * 0.51, white);
    vbl = Screen('Flip', window, vbl + ((Log.trials(i,2)/1000/ifi - 1) - 0.5) * ifi); %Flip after ITI
    ao.startBackground();      
    stop(ao);
    stim2_V = spl_to_voltage(Log.trials(i,1), sensitivity_dB, V_ref, G);
    queueOutputData(ao, stim_wave*stim2_V);

    %% 2 stimulus
    num_secs_to_wait = 1;
    DrawFormattedText(window, ...
    '2', ...
    'center', screenYpixels * 0.51, white);
    vbl = Screen('Flip', window, vbl + ((num_secs_to_wait/ifi - 1) - 0.5) * ifi); %Flip after 0.5 sec
    ao.startBackground();      

    %% Response (draw arrow)
    % Define arrow parameters
    arrowLength = 100; % Length of the arrow
    arrowWidth = 20; % Width of the arrow line
    offset = 50; % Vertical offset for arrows from the center
    textOffset = 150; % Space above each arrow for text
    
    % DRAW NORMAL ARROW
    % Define left arrow points (left side of the screen)
    leftArrowX = xCenter - screenXpixels * 0.05; % 25% to the left of the center
    leftArrowY = yCenter + offset;
    leftArrow = [
        leftArrowX, leftArrowY; % Start of the line
        leftArrowX+5 - arrowLength, leftArrowY % End of the line (pointing left)
    ];
    % Add arrowhead (triangle at the left end)
    leftArrowHead = [
        leftArrowX - arrowLength, leftArrowY; % Base of arrowhead
        leftArrowX - arrowLength + arrowWidth, leftArrowY - arrowWidth; % Top of arrowhead
        leftArrowX - arrowLength + arrowWidth, leftArrowY + arrowWidth; % Bottom of arrowhead
    ];
    
    % Define right arrow points (right side of the screen)
    rightArrowX = xCenter + screenXpixels * 0.05; % 25% to the right of the center
    rightArrowY = yCenter + offset;
    rightArrow = [
        rightArrowX, rightArrowY; % Start of the line
        rightArrowX-5 + arrowLength, rightArrowY % End of the line (pointing right)
    ];
    % Add arrowhead (triangle at the right end)
    rightArrowHead = [
        rightArrowX + arrowLength, rightArrowY; % Base of arrowhead
        rightArrowX + arrowLength - arrowWidth, rightArrowY - arrowWidth; % Top of arrowhead
        rightArrowX + arrowLength - arrowWidth, rightArrowY + arrowWidth; % Bottom of arrowhead
    ];

    respToBeMade = true; 
    
    start_resp = GetSecs(); 
    while respToBeMade == true
        % Draw arrows on screen
        Screen('DrawLines', window, leftArrow', 5, white); % Draw left arrow line in white
        Screen('FillPoly', window, white, leftArrowHead); % Fill left arrowhead in white
        Screen('DrawLines', window, rightArrow', 5, white); % Draw right arrow line in white
        Screen('FillPoly', window, white, rightArrowHead); % Fill right arrowhead in white
        
        % Draw text above each arrow
        if Log.trials(i,3) == 1
            DrawFormattedText(window, 'Low', leftArrowX-arrowLength, leftArrowY - textOffset, white);
            DrawFormattedText(window, 'High', rightArrowX, rightArrowY - textOffset, white);
        elseif Log.trials(i,3) == 2
            DrawFormattedText(window, 'High', leftArrowX-arrowLength, leftArrowY - textOffset, white);
            DrawFormattedText(window, 'Low', rightArrowX, rightArrowY - textOffset, white);
        end  

% % % %         if GetSecs() - start_resp > 1.5
% % % %             DrawFormattedText(window, ...
% % % %                 ['Plase give a response! \n ' ...
% % % %                 'Press any key to continue'], ...
% % % %                 'center', screenYpixels * 0.5, black,[],[],[],2);
% % % %             Screen('Flip', window);
% % % %             KbStrokeWait;
% % % %             respToBeMade = false; 
% % % %         end

        % INPUT CHECK
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(escapeKey)
            ShowCursor;
            sca;
            return
        else
            % DRAW THICK ARROW HEAD
            arrowWidth = 25; % Width of the arrow line
            if keyCode(leftKey)
                % Draw thick arrows
                leftArrowHead = [
                    leftArrowX - arrowLength, leftArrowY; % Base of arrowhead
                    leftArrowX - arrowLength + arrowWidth, leftArrowY - arrowWidth; % Top of arrowhead
                    leftArrowX - arrowLength + arrowWidth, leftArrowY + arrowWidth; % Bottom of arrowhead
                ];

                Screen('DrawLines', window, leftArrow', 8, white); % Draw left arrow line in white
                Screen('FillPoly', window, white, leftArrowHead); % Fill left arrowhead in white
                Screen('DrawLines', window, rightArrow', 5, white); % Draw right arrow line in white
                Screen('FillPoly', window, white, rightArrowHead); % Fill right arrowhead in white
                
                % Draw text above each arrow
                if Log.trials(i,3) == 1
                    DrawFormattedText(window, 'Low', leftArrowX-arrowLength, leftArrowY - textOffset, white);
                    DrawFormattedText(window, 'High', rightArrowX, rightArrowY - textOffset, white);
                elseif Log.trials(i,3) == 2
                    DrawFormattedText(window, 'High', leftArrowX-arrowLength, leftArrowY - textOffset, white);
                    DrawFormattedText(window, 'Low', rightArrowX, rightArrowY - textOffset, white);
                end
                Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                WaitSecs(0.3)

                response = 1;
                respToBeMade = false;

            elseif keyCode(rightKey)
                rightArrowHead = [
                    rightArrowX + arrowLength, rightArrowY; % Base of arrowhead
                    rightArrowX + arrowLength - arrowWidth, rightArrowY - arrowWidth; % Top of arrowhead
                    rightArrowX + arrowLength - arrowWidth, rightArrowY + arrowWidth; % Bottom of arrowhead
                ];

                Screen('DrawLines', window, leftArrow', 5, white); % Draw left arrow line in white
                Screen('FillPoly', window, white, leftArrowHead); % Fill left arrowhead in white
                Screen('DrawLines', window, rightArrow', 8, white); % Draw right arrow line in white
                Screen('FillPoly', window, white, rightArrowHead); % Fill right arrowhead in white
                
                % Draw text above each arrow (RANDOMISED ACROSS CONDITIONS)
                if Log.trials(i,3) == 1
                    DrawFormattedText(window, 'Low', leftArrowX-arrowLength, leftArrowY - textOffset, white);
                    DrawFormattedText(window, 'High', rightArrowX, rightArrowY - textOffset, white);
                elseif Log.trials(i,3) == 2
                    DrawFormattedText(window, 'High', leftArrowX-arrowLength, leftArrowY - textOffset, white);
                    DrawFormattedText(window, 'Low', rightArrowX, rightArrowY - textOffset, white);
                end

                Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                WaitSecs(0.3)

                response = 2;
                respToBeMade = false;
            end
        end


        % Flip the screen to show the content (at each frame of the while
        % loop).
        if GetSecs > vbl + num_secs_to_wait
            Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        end
    end

    Log.responses = [Log.responses; response];

    sprintf("trial number %s", int2str(i))

end
Screen('CloseAll')
ShowCursor();

%% cd into the right folder and prepare to save
if ~exist(subj_folder)
    mkdir(subj_folder)
end
cd(subj_folder)

save(strcat("Log_session_", int2str(session),"_auditory.mat"), "Log");
%% CLEANUP AND ANALYSIS
big_table = [Log.trials, Log.responses];
for i = 1:length(big_table)
    if big_table(i,3) == 2
        if big_table(i,4) == 1
            big_table(i,4) = 2;
        elseif big_table(i,4) == 2
            big_table(i,4) = 1; 
        end
    end
end
big_table(:,4) = big_table(:,4)-1; 
big_table = table(big_table(:,1), big_table(:,2), big_table(:,3), big_table(:,4)); 
big_table = renamevars(big_table,["Var1","Var2","Var3","Var4"], ...
                 ["Intensity","ITI","Flip","Response"]);

output_summary = groupsummary(big_table,"Intensity",@(x)sum(x==1),"Response");
hits = [output_summary.fun1_Response ./ output_summary.GroupCount];
if any(hits == 0)
    hits(find(hits == 0)) = 0.001; 
end
if any(hits==1)
    hits(find(hits == 1)) = 0.999; 
end

output_summary.hits = hits; 

d_consecutive = diff(norminv(hits)); 
d_cumulative = abs(cumsum(d_consecutive)); 
output_summary.d_cumulative = [0.001; d_cumulative];
output_summary.d_consecutive = [0.001; d_consecutive];

%% Psychometric curve
[ Qpre, p, sm, varcov] = fit_logistic(output_summary.Intensity, output_summary.hits);
t = linspace(min(output_summary.Intensity), max(output_summary.Intensity),1000); 
Qinf = p(2); 
alpha = p(3); 
thalf = p(1); 
Q = Qinf./(1 + exp(-alpha*(t-thalf)));

%% Linear Fit
% % % % % l = fitlm(output_summary, 'd_cumulative~Intensity');
% % % % % a = l.Coefficients{2,1}; 
% % % % % b = l.Coefficients{1,1}; 
% % % % % line_to_plot = t*a+b;
% % % % % 
% % % % % figure; plot(output_summary.Intensity, output_summary.d_cumulative, '*'); 
% % % % % hold on; plot(t, line_to_plot);
% % % % % exportgraphics(gca, strcat("cumulative_d", int2str(session) ,".png"))
% % % % % close all
% % % % % %Now determine intensities. 
% % % % % if session == 1
% % % % %     d_OG = OG_intensity*a+b; 
% % % % %     d_intensities = linspace(d_OG-1.5,d_OG+1.5,7); 
% % % % %     
% % % % %     new_intensities = (d_intensities-b)/a; 
% % % % %     display(new_intensities)
% % % % %     save(strcat(subj_folder, "/new_intensities.mat"), "new_intensities")
% % % % % end

if session == 1
    [value, pos_max] = min(abs(Q-0.99));
    max_asyntote = t(pos_max); 
    [value, pos_min] = min(abs(Q-0.01));
    min_asyntote = t(pos_min); 

    new_intensities_auditory_dB = linspace(min_asyntote, max_asyntote, 9); 
    display(new_intensities_auditory_dB)

    new_intensities_auditory_V = []; 
    for i = 1:length(new_intensities_auditory_dB)
        new_intensities_auditory_V(:,i) = spl_to_voltage(new_intensities_auditory_dB(:,i), sensitivity_dB, V_ref, G);
    end

    save(strcat(subj_folder, "/new_intensities_auditory_dB.mat"), "new_intensities_auditory_dB")
    save(strcat(subj_folder, "/new_intensities_auditory_V.mat"), "new_intensities_auditory_V")

    figure; plot(output_summary.Intensity, hits, 'o');
    hold on; plot(t, Q);
    xlabel('Intensities')
    ylabel('Hit Proportion')
    xline(new_intensities_auditory_dB)
    exportgraphics(gca, strcat("psychometric_curve", int2str(session) ,"_auditory.png"))
    close all
else
    figure; plot(output_summary.Intensity, hits, 'o');
    hold on; plot(t, Q);
    xlabel('Intensities')
    ylabel('Hit Proportion')
    exportgraphics(gca, strcat("psychometric_curve", int2str(session) ,"_auditory.png"))
    close all
end

% --- Function to calculate SPL from Voltage ---
function SPL = voltage_to_spl(V_DAQ, sensitivity_dB, V_ref, G)
    V_headphones = G * V_DAQ;
    SPL = sensitivity_dB + 20 * log10(V_headphones / V_ref);
end

% --- Function to calculate Voltage from SPL ---
function V_DAQ = spl_to_voltage(SPL, sensitivity_dB, V_ref, G)
    V_headphones = V_ref * 10^((SPL - sensitivity_dB) / 20);
    V_DAQ = V_headphones / G;
end





