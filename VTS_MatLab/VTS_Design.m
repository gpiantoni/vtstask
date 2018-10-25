devices = daq.getDevices;  % register DAQ devices

s = daq.createSession('ni'); % Create session with NI devices
nrOutputs = 5;
fingers = 5;

% serial ports
PORT_OUT = "COM5";
PORT_IN = "COM7";

% DAQ devices
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

%hrf_onsets = xlsread('hrf_onsets.xlsx');

% --- Onsets based on hrf_pattern ---
% hrf_tsv = tdfread('sub-V7818_ses-UMC-7T_task-hrfpattern_run-1_20180306T170321.tsv');
% hrf_onsets =  hrf_tsv.onset;
hrf_onsets = [0 1 2];

%% Stimulate the piezo stimulators
% stimAll stimulates all the stimulators at once 
% stimPerFinger stimulates all stimulators per finger
% stimSeq stimulates the stimulators in sequence
% stimWithin stimulates the stimulators in sequence per finger
%For more info: $help METHODNAME 
% 

% --- Open serial ports if available ---
try
    sp_out = serial(PORT_OUT);
    disp(strcat('opening serial port:', {' '}, PORT_OUT));
    fopen(sp_out);
catch ME
    warning('no output serial port found. output serial port set to 0');
    sp_out = 0;
end

try
    sp_in = serial(PORT_IN);
    disp(strcat('opening serial port:', {' '}, PORT_IN));
    fopen(sp_in);
catch ME
    warning('no input serial port found. input serial port set to 0');
    sp_in = 0;
end

%% Start experiments
try
    
    % --- stimulate all ---
    if sp_in ~=0
        fmri_trigger(sp_in, 'Start stimulating all outputs')
    end
    
    prev = 0;
    for i = 1:length(hrf_onsets)
        disp(hrf_onsets(i)-prev)
        pause(hrf_onsets(i) - prev);
        disp(strcat('stimAll: run', string(i)))
        stimAll(s, outputSignal, nrOutputs, sp_out)
        prev = hrf_onsets(i);
    end
    
    % --- stimulate per finger ---
%     if sp_in ~=0
%         fmri_trigger(sp_in, 'Start stimulating outputs per finger')
%     end
%     
%     disp('stimPerFinger:')
%     stimPerFinger(s, outputSignal, nrOutputs, sp_out, fingers);

    % --- stimilate sequential ---
%     if sp_in ~=0
%         fmri_trigger(sp_in, 'Start stimulating outputs in sequence')
%     end

%     for i = 1:7
%         disp(strcat('stimSeq: run', string(i)))
%         stimSeq(s, outputSignal, nrOutputs, sp_out, fingers, 1);
%     end

    % --- stimulate within finger --- 
%     if sp_in ~=0
%         fmri_trigger(sp_in, 'Start stimulating outputs within finger')
%     end
%     
%     disp('stimWithin:')
%     stimWithin(s, outputSignal, nrOutputs, sp_out, fingers);
    
    % --- stimulate random ---
    if sp_in ~=0
        fmri_trigger(sp_in, 'Start stimulating outputs at random')
    end
    
    randomlist = 
    for i = 1:2
        stimRand(s, outputSignal, nrOutputs, sp_out, .8);
    end
    
    % --- Close serial ports ---
    
    if sp_out ~= 0
        disp(strcat('closing serial port:',{' '}, PORT_OUT));
        fclose(sp_out);
    end
    
    if sp_in ~= 0
        fclose(sp_in);
        disp(strcat('closing serial port:',{' '}, PORT_IN));
    end
    
catch ME
    if sp_out ~= 0
        fclose(sp_out);
        disp(strcat('closing serial port:',{' '}, PORT_OUT));
    end
    
    if sp_in ~= 0
        fclose(sp_in);
        disp(strcat('closing serial port:',{' '}, PORT_IN));
    end
end

        

