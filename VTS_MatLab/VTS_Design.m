clear

devices = daq.getDevices;  % register DAQ devices
s = daq.createSession('ni'); % Create session with NI devices
nrOutputs = 5;
fingers = 5;
restdur = 14.4;  
pTime = 7;

% serial ports
PORT_OUT = "COM5";
PORT_IN = "COM9";

% DAQ devices
daq1 = 'cDAQ1mod1';
daq2 = 'cDAQ1mod2';

%Create output signal
% s.DurationInSeconds = 1.6;  % duration of stimulus in seconds
Amplitude = 1; %TODO: Find out what the output amplitude is (in voltage)
Frequency = 30 ; %Hz
Stimulation = 2;
onset = [10, 15, 20, 25];
randlist = [1,3,5,2,4;4,2,5,3,1];
% outputSignal = createOutputSignal(Frequency, Amplitude, Stimulation);
signal = createSignal(Frequency, Amplitude, Stimulation);

seqmat = createStimSeqMat(nrOutputs, signal, 2, restdur, pTime);
stimAllMat = createStimAllMat(nrOutputs, signal, onset);
randmat = createStimRandMat(nrOutputs, signal, randlist, restdur, pTime);

%% add all the channels to the session

%addChannels(s, nrOutputs, daq1)
addChannels(s, nrOutputs, daq2);

%% add excel file for onsets

%hrf_onsets = xlsread('hrf_onsets.xlsx');

% --- Onsets based on hrf_pattern ---
hrf_tsv = tdfread('sub-V7818_ses-UMC-7T_task-hrfpattern_run-1_20180306T170321.tsv');
hrf_onsets =  hrf_tsv.onset;
% hrf_onsets = [3 ];

%% --- Open serial ports if available ---
try
    sp_out = serial(PORT_OUT);
    fopen(sp_out);
    disp(strcat('opening serial port:', {' '}, PORT_OUT));
catch ME
    warning('no output serial port found. output serial port set to 0');
    sp_out = 0;
end

try
    sp_in = serial(PORT_IN);
    fopen(sp_in);
    disp(strcat('opening serial port:', {' '}, PORT_IN));
    sp_in.Timeout = 60;
catch ME
    warning('no input serial port found. input serial port set to 0');
    sp_in = 0;
end

try
    
    % --- stimulate all ---
    
%     queueOutputData(s, stimAllMat)
%     if sp_in ~=0
%         fmri_trigger(sp_in, 'Start stimulating all outputs')
%     end
%     
%     s.startForeground
%     
%     if sp_in ~=0
%         fmri_trigger(sp_in, 'End of stimulation')
%     end
    
%     tic
%     running = 1;
%     i = 1;
%     prev = 0;
%     disp(strcat('pause:',{' '}, num2str(hrf_onsets(i)), {' '}, 'second(s)'));
%     
%     while running
%         if round(toc, 4) == round(hrf_onsets(i), 4)
%             toc
%             disp(strcat('stimAll: run ',{' '}, string(i)))
%             prev = hrf_onsets(i);
%             stimAll(s, outputSignal, nrOutputs, sp_out);
%             if i == length(hrf_onsets)
%                 disp('end of stimulate all experiment')
%                 break
%             end
%             i = i + 1;
%             disp(strcat('pause:',{' '}, num2str(hrf_onsets(i) - prev), {' '}, 'second(s)'));
%         end
%     end
%     

    %% --- stimulate sequential ---
    queueOutputData(s, seqmat)
    if sp_in ~=0
        fmri_trigger(sp_in, 'Start stimulating all outputs')
    end
    
    s.startForeground
    
    if sp_in ~=0
        fmri_trigger(sp_in, 'End of stimulation')
    end

%     reversed = false;
%     for i = 1:8
%         tic
%         disp(strcat('stimulate in sequence, run ',{' '}, string(i)))
%         stimSeqSW(s, outputSignal, nrOutputs, reversed, restdur, pTime);
%         reversed = ~reversed;
%     end
%     disp('end of stimulate in sequence experiment')
%     disp(toc(seq_timer))
    
    %% --- stimulate within finger --- 
%     if sp_in ~=0
%         fmri_trigger(sp_in, 'Start stimulating outputs within finger')
%     end
%     
%     disp('stimWithin:')
%     stimWithin(s, outputSignal, nrOutputs, sp_out, fingers);
    
    %% --- stimulate random ---
    
    queueOutputData(s, randmat)
    if sp_in ~=0
        fmri_trigger(sp_in, 'Start stimulating all outputs')
    end
    
    s.startForeground
    
    if sp_in ~=0
        fmri_trigger(sp_in, 'End of stimulation')
    end
%     if sp_in ~=0
%         fmri_trigger(sp_in, 'Start stimulating outputs at random')
%     end
%     rand_timer = tic;
%     read file with randomised stimulations
%     randFile = fopen('randomlist_5_fingers.txt');
%     randcell = textscan(randFile, '%d');
%     randomlist = cell2mat(randcell);
%     fclose(randFile);
%     
%     randlength = length(randomlist)/fingers;
%     orderlist = transpose(reshape(randomlist, [5,8]));
%     
%     for i = 1:randlength
%         disp(strcat('stimulate random, run ',{' '}, string(i)))
%         order = orderlist(i,:);
%         stimRandSW(s, outputSignal, nrOutputs, order, restdur, pTime, sp_out);
%     end
%     disp('end of stimulate random experiment')
%     toc(rand_timer)
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

% function outputSignal = createOutputSignal(frequency, amplitude, duration)
% 
% values = linspace(0,2*pi * frequency *duration,...
%     duration*1000)';
% outputSignal = amplitude.*sin(values);
% end
