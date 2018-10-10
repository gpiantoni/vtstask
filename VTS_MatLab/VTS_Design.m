devices = daq.getDevices;  % register DAQ devices

s = daq.createSession('ni'); % Create session with NI devices
nrOutputs = 5;
fingers = 5;
PORT = "COM5";
daq1 = 'cDAQ1mod1';
daq2 = 'cDAQ1mod2';

%Create output signal
s.DurationInSeconds = 1;  % duration of stimulus in seconds
Amplitude = 1; %TODO: Find out what the output amplitude is (in voltage)
Frequency = 30 ; %Hz
values = linspace(0,2*pi * Frequency *s.DurationInSeconds,...
    s.DurationInSeconds*1000)';
outputSignal = Amplitude.*sin(values);

%% add all the channels to the session

%addChannels(s, nrOutputs, daq1)
addChannels(s, nrOutputs, daq2);

%% add excel file for onsets

hrf_onsets = xlsread('hrf_onsets.xlsx');
%% Stimulate the piezo stimulators
% stimAll stimulates all the stimulators at once 
% stimPerFinger stimulates all stimulators per finger
% stimSeq stimulates the stimulators in sequence
% stimWithin stimulates the stimulators in sequence per finger
%For more info: $help METHODNAME 
% 

% Open serial port if available
try
    sp = serial(PORT);
    disp(strcat('opening serial port:', {' '}, PORT));
    fopen(sp);
catch ME
    warning('no serial port found. sp set to 0');
    sp =0;
end
w = waitforbuttonpress;
% Start experiments
try
    for i = 1:length(hrf_onsets)
        disp('stimAll: ')
        stimAll(s, outputSignal, nrOutputs, sp)
        pause(hrf_onsets(i));
    end

    disp('stimPerFinger:')
    stimPerFinger(s, outputSignal, nrOutputs, sp, fingers);

    disp('stimSeq:')
    stimSeq(s, outputSignal, nrOutputs, sp, fingers);
    
    disp('stimWithin:')
    stimWithin(s, outputSignal, nrOutputs, sp, fingers);
    
    % Close serial port
    if sp ~= 0
        disp(strcat('closing serial port:',{' '}, PORT));
        fclose(sp);
    end
    
catch ME
    if sp ~= 0
        fclose(sp);
        disp(strcat('closing serial port:',{' '}, PORT));
    end
end

        

