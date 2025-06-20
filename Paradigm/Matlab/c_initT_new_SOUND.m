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
Hz = 440;

time = linspace(0,1,50000);
sound_wave = a*sin(2*pi*Hz*time);


stim_wave = zeros(intra_len*nStim+stim_len+2,1);                              
figure; plot(stim_wave); hold on; 
stim_wave(2:(stim_len+1)) = 1;
%stim_wave(2:(stim_len+1)) = sound_wave(2:(stim_len+1)); 
plot(stim_wave); hold off


%% Stimulation
while 1
    intensity = input('Stimulus intensity (mA): ');
    if isempty(intensity)
        break
    end
%     if intensity > 2
%         error('Stimulus is too high!')
%     end
    data = stim_wave*intensity;
    % data = painwave'*intensity;
    stop(ao);
    queueOutputData(ao,data);
    ao.startBackground();
    WaitSecs(0.5);
end

stop(ao)
delete(ao)
clear ao
    
    
