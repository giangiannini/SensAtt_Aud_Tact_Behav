%% Test initial threshold
clear all
close all

duration = 0.002; %1ms pulse
rep = 5; %3 squarewave pulses
pauseTime = 0.003; %200Hz
stimdur = rep*duration + pauseTime*(rep-1);

% Initialize output object
aoc = [3];
doc = [];
ao = aio_setup64(aoc);

% Constants for Sennheiser HD206
sensitivity_dB = 108;         % Sensitivity in dB SPL per 1 V
impedance = 24;              % Impedance in ohms
V_ref = 1;               % Reference power in watts (1 mW)
G_dB = 10;                   % Amplifier gain in dB
G = 10^(G_dB/20);            % Convert dB gain to linear

% With sampling rate = 50000 a 200 microsecond pulse coresponds to 10
% samples
pulse_width = duration*ao.Rate; % pulse_width in datapoints
pause_width = pauseTime*ao.Rate; % pause_width in datapoints
painwave=[];

for r=1:rep
    if r==1
        painwave=[0]; % start with 0
    else
        painwave = [painwave zeros(1,pause_width)]; % append pause
    end
    painwave = [painwave ones(1,pulse_width)]; % append pulse
    if r==rep
        painwave = [painwave 0]; % end with 0
    end
end

intra_len = 2500;                                                          % 5000 = 100ms
stim_len = 10;                                                             % 10 = 200 micro secs
nStim = 2;

a = 1; 
Hz = 500;

time = linspace(0,1,50000);
sound_wave = a*sin(2*pi*Hz*time);


stim_wave = zeros(intra_len*nStim+stim_len+2,1);                              
figure; plot(stim_wave); hold on; 
stim_wave(2:(stim_len+1)) = 1;
%stim_wave(2:(stim_len+1)) = sound_wave(2:(stim_len+1)); 
%plot(stim_wave); hold off


%% Stimulation
while 1
    intensity_dB = input('Stimulus intensity (dB): ');
    if isempty(intensity_dB)
        break
    end

    intensity_V = spl_to_voltage(intensity_dB, sensitivity_dB, V_ref, G);

%     if intensity > 2
%         error('Stimulus is too high!')
%     end
    data = stim_wave*intensity_V;
    % data = painwave'*intensity;
    stop(ao);
    queueOutputData(ao,data);
    ao.startBackground();
    WaitSecs(0.5);
    sprintf('intensity_volt = %.4f', intensity_V)
end

stop(ao)
delete(ao)
clear ao


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

% % % % % --- Example Calculations ---
% % % % % Example 1: Voltage to SPL
% % % % V_example = 0.5; % Voltage in volts
% % % % SPL_result = voltage_to_spl(V_example, sensitivity_dB, impedance, P_ref, G);
% % % % fprintf('SPL for %.2f V RMS: %.2f dB SPL\n', V_example, SPL_result);
% % % % 
% % % % % Example 2: SPL to Voltage
% % % % SPL_target = 100; % Desired SPL in dB
% % % % V_required = spl_to_voltage(SPL_target, sensitivity_dB, impedance, P_ref, G);
% % % % fprintf('Voltage required for %.2f dB SPL: %.4f V RMS\n', SPL_target, V_required);
% % % % 
% % % % % --- User Interaction ---
% % % % V_user = input('Enter voltage in V RMS: ');
% % % % SPL_user = voltage_to_spl(V_user, sensitivity_dB, impedance, P_ref, G);
% % % % fprintf('Calculated SPL: %.2f dB SPL\n', SPL_user);
% % % % 
% % % % SPL_user_target = input('Enter desired SPL in dB: ');
% % % % V_user_required = spl_to_voltage(SPL_user_target, sensitivity_dB, impedance, P_ref, G);
% % % % fprintf('Required Voltage: %.4f V RMS\n', V_user_required);

