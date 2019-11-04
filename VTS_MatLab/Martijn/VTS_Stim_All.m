clear;clc

% Fill in the subject number and log directory for logging. Then logging is
% inititated
subject = 'TEST_Joni_2';
logdir = 'C:\Users\mthio.LA020080\Documents\GitHub\vtstask\logfiles\';
logfile = fopen(strcat(logdir, 'log_subject_', subject, '.txt'), 'a');
logger(logfile, char(strcat('Initiate logging for subject', {' '}, subject))); 

% register the amplifier
devices = daq.getDevices;  % register DAQ devices
s = daq.createSession('ni'); % Create session with NI devices

% serial ports
PORT_OUT = "COM5";
PORT_IN = "COM8";  % check 'seriallist' in CMD window

% DAQ devices. One daq device can hold 10 stimulators. If more than 10
% stimulators are needed, use two DAQ devices. 
daq1 = 'cDAQ1mod1';
daq2 = 'cDAQ1mod2';

%% Create output signal
% This part of the module creates the output signal. First, specify the
% number of outputs, amplitude and frequency. Then, determine the
% stimulation time and pause time. These variables are then used to create
% a single instance of the signal. This is subsequently used in generating
% the stimulation matrices.

nrOutputs = 5;
amplitude = 2;
frequency = 30;

% stimulation variables for stimAll
stimdur_all_on = .2;
stimdur_all_off = .05;
stimdur_total_all = .5;
reps_all = stimdur_total_all/(stimdur_all_on+stimdur_all_off);

% create signals for both
signal_all = createSignal(frequency, amplitude, stimdur_all_on, stimdur_all_off, reps_all);

%% Load files for experiment
% Here the files are loaded that are used in the experiment. The first file
% contains the stimulation times of the HRF experiment. The second file
% contains the pseudo-randomized order of the single finger digit
% experiments.

% --- Onsets based on hrf_pattern ---
hrf_filename = 'sub-V7818_ses-UMC-7T_task-hrfpattern_run-1_20180306T170321.tsv';
hrf_tsv = tdfread(hrf_filename);
hrf_onsets =  hrf_tsv.onset;
onsets = hrf_onsets;  % klaar met stimuleren na 252 sec;

%% log files for experiments
fprintf(logfile, '\n%s: %s\n',...
    'hRF onsets: ', num2str(onsets));

%% add all the channels to the session
% Add all the stimulators (channels) to the seession, otherwise they cannot
% be used. Use the DAQ device that was registered.

%addChannels(s, nrOutputs, daq1)
addChannels(s, nrOutputs, daq2);

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
    
    logger(logfile, 'INPUTS STIMULATE ALL:', 0);
    logvars(logfile, nrOutputs, amplitude, frequency, stimdur_all_on, stimdur_all_off, stimdur_total_all);
    
    stimAllMat = createStimAllMat(nrOutputs, signal_all, onsets);

    queueOutputData(s, stimAllMat)
    if sp_in ~=0
        fmri_trigger(sp_in, logfile, 'Start stimulating all outputs')
    end
    tic
    s.startBackground
    % Send trigger to serialport
    if sp_out ~= 0
        fprintf(sp_out, '%c', 20);
    end
    
    logger(logfile, char(strcat('start time delay is', {' '}, num2str(toc))))
    logall(logfile, onsets, stimdur_total_all, sp_out);
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

