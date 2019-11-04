clear;clc

% Fill in the subject number and log directory for logging. Then logging is
% inititated
subject = 'TEST_Joni';
logdir = 'C:\Users\mthio.LA020080\Documents\GitHub\vtstask\logfiles\';
logfile = fopen(strcat(logdir, 'log_subject_', subject, '.txt'), 'a');
logger(logfile, char(strcat('Initiate logging for subject', {' '}, subject))); 

% register the amplifier
devices = daq.getDevices;  % register DAQ devices
s = daq.createSession('ni'); % Create session with NI devices

% serial ports
PORT_OUT = "COM5"; % only for ECoG
PORT_IN = "COM8";  % check 'seriallist' 

% DAQ devices. One daq device can hold 10 stimulators. If more than 10
% stimulators are needed, use two DAQ devices. 
daq1 = 'cDAQ1mod1';
daq2 = 'cDAQ1mod2';

nrOutputs = 15;
nrOutputs1 = 5;
nrOutputs2 = 10;
amplitude = 2;
frequency = 30; %can be adjusted

%% Create output signal
% This part of the module creates the output signal. First, specify the
% number of outputs, amplitude and frequency. Then, determine the
% stimulation time and pause time. These variables are then used to create
% a single instance of the signal. This is subsequently used in generating
% the stimulation matrices.

% stimulation variables seperate stimulator
stimdur_on = .32;
stimdur_off = .08;
stimdur_total = 3.2;

restdur = 14.4; % Rest between stimulation sets (after stimulation stops)
% restTime = restdur + stimdur_total;
pDur = 6.4;
pTime = pDur + stimdur_total;
reps_stim = stimdur_total/(stimdur_on+stimdur_off);

% create signal per stimulator
signal_stim = createSignal(frequency, amplitude, stimdur_on, stimdur_off, reps_stim);

%% Load files for experiment
% Here the file is loaded that is used in the experiment.The file
% contains the pseudo-randomized order of the left right wave experiment.

% --- read file with randomised stimulations ---
% rand_filename = 'randomfingers.txt';
% randFile = fopen(rand_filename);
% randcell = textscan(randFile, '%d');
% randomlist = cell2mat(randcell);
% fclose(randFile);
% randlength = length(randomlist)/nrOutputs;
% orderlist = transpose(reshape(randomlist, [nrOutputs,randlength]));

%% log files for experiments
%can be used to load in .txt for fixed onsets and outputs needed
%for stimulation, variables are now hardcoded
    %left right wave design
     onsets_lr = [14.4, 24, 33.6, 43.2, 52.8,... 
              67.2, 76.8, 86.4, 96, 105.6];
     outputlist_lr = [1,2,3; 4,5,6; 7,8,9; 10,11,12; 13,14,15;
                  13,14,15; 10,11,12; 7,8,9; 4,5,6; 1,2,3]; 
     %Down up design
     onsets_dup = [14.4, 24, 33.6, 48, 57.6, 67.2];
     frequency_dup = [10, 20, 30, 10, 20, 30];
     amplitude_dup = [1, 1, 1, 2, 2, 2];
     outputlist_dup = [1,4,7,10,13; 2,5,8,11,14; 3,6,9,12,15;
                      3,6,9,12,15; 2,5,8,11,14; 1,4,7,10,13];
     signal_list = [0.32, .08, 8; 0.32, .08, 8; 0.32, .08, 8; 
         0.32, .08, 8; 0.32, .08, 8; 0.32, .08, 8;];
     
     %Diagonal design
     onsets_diag = [14.4, 24, 33.6, 48, 57.6, 67.2];
     
     outputlist_diag = [1,5,9,11,15;2,6,7,12,13;3,4,8,10,14;
                        3,4,8,10,14;2,6,7,12,13;1,5,9,11,15];
     
%      outputlist_diag = [1,5,9,11,13; 2,6,8,10,14;3,5,7,11,15;
%                         3,5,7,11,15; 2,6,8,10,14; 1,5,9,11,13];
%  fprintf(logfile, '\n%s: %s\n', ... 
%      'wave stimulation filename: ', 'there is no file'); 
%% add all the channels to the session
% Add all the stimulators (channels) to the seession, otherwise they cannot
% be used. Use the DAQ device that was registered.

addChannels(s, nrOutputs1, daq1)
addChannels(s, nrOutputs2, daq2);

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
    sp_in.Timeout = inf;
catch ME
    warning('no input serial port found. input serial port set to 0');
    sp_in = 0;
end


try
%% --- stimulate all ---
    % All fingers are stimulated at certain intervals following the HRF
    % design. The matrix is generated using the 'createStimAllMat'
    % function. Logger logs when fingers are stimulated. 
    
    logger(logfile, 'INPUTS STIMULATE:', 0);
    logvars(logfile, nrOutputs, amplitude, frequency, stimdur_on, stimdur_off, stimdur_total);

    %CHANGE according to design onsets and outputlist
    %stimAllMat = createStimlrMat(nrOutputs, signal_stim, onsets_diag, outputlist_diag);
    stimAllMat = createStimMat(nrOutputs, signal_list, onsets_dup, outputlist_dup,...
        frequency_dup, amplitude_dup);
    stimAllMat2 = stimAllMat(:, 1:10);
    stimAllMat1 = stimAllMat(:, 11:15);

    queueOutputData(s, [stimAllMat1, stimAllMat2])
    if sp_in ~=0
        fmri_trigger(sp_in, logfile, 'Start stimulating all outputs')
    end
    tic
    s.startBackground
    % Send trigger to serialport
    if sp_out ~= 0
        fprintf(sp_out, '%c', 20);
    end
    %CHANGE onsets and outputlist
    logger(logfile, char(strcat('start time delay is', {' '}, num2str(toc))))
    loglr(logfile, onsets_diag, stimdur_total, outputlist_diag, sp_out);
    if sp_in ~=0
        fmri_trigger(sp_in, logfile, 'End of stimulating all outputs')
        stop(s);
    else
        pause
    end
    
        % --- Close serial ports ---
    % Serial ports should be closed, otherwise it will not remain open and
    % the serialport cannot be registered again as 'sp_in' or 'sp_out'.
    % This could distort the process. To manually check whether the ports
    % are still open, type in 'instrfind' in the cmd line. 
    
    if sp_out ~= 0
        disp(strcat('closing serial port:',{' '}, PORT_OUT));
        fclose(sp_out);
    end
    
    if sp_in ~= 0
        fclose(sp_in);
        disp(strcat('closing serial port:',{' '}, PORT_IN));
    end
    fclose(logfile);
    
catch e
    if sp_out ~= 0
        fclose(sp_out);
        disp(strcat('closing serial port:',{' '}, PORT_OUT));
    end
    
    if sp_in ~= 0
        fclose(sp_in);
        disp(strcat('closing serial port:',{' '}, PORT_IN));
    end
    fclose(logfile);
    fprintf(2, e.message);
end
