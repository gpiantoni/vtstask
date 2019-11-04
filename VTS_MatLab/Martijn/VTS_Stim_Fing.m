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
PORT_OUT = "COM5";
PORT_IN = "COM8";  % check 'seriallist' 

% DAQ devices. One daq device can hold 10 stimulators. If more than 10
% stimulators are needed, use two DAQ devices. 
daq1 = 'cDAQ1mod1';
daq2 = 'cDAQ1mod2';

nrOutputs = 5;
amplitude = 2;
frequency = 30; %adjust per experiment

%% Create output signal
% This part of the module creates the output signal. First, specify the
% number of outputs, amplitude and frequency. Then, determine the
% stimulation time and pause time. These variables are then used to create
% a single instance of the signal. This is subsequently used in generating
% the stimulation matrices.

% stimulation variables seperate finger stimulation
stimdur_fing_on = .4;
stimdur_fing_off = .1;
stimdur_total_fing = 4;

restdur = 14.4; % Rest between stimulation sets (after stimulation stops)
% restTime = restdur + stimdur_total_fing;
pDur = 10;
pTime = pDur + stimdur_total_fing;
reps_fing = stimdur_total_fing/(stimdur_fing_on+stimdur_fing_off) ;

% create signals for both
signal_fing = createSignal(frequency, amplitude, stimdur_fing_on, stimdur_fing_off, reps_fing);

%% Load files for experiment
% Here the file is loaded that is used in the experiment.The file
% contains the pseudo-randomized order of the single finger digit
% experiments.

% --- read file with randomised stimulations ---
rand_filename = 'randomfingers.txt';
randFile = fopen(rand_filename);
randcell = textscan(randFile, '%d');
randomlist = cell2mat(randcell);
fclose(randFile);
randlength = length(randomlist)/nrOutputs;
orderlist = transpose(reshape(randomlist, [nrOutputs,randlength]));

%% log files for experiments
fprintf(logfile, '\n%s: %s\n', ... 
    'random stimulation filename: ', rand_filename); 

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
% --- stimulate random ---
    % Stimulate individual finger digits in pseudo-randomized order at 30
    % Hz. The stimulation matrix is created as 'randmat' using the 
    % 'createStimFingMat' function. Logger logs which finger is stimulated
    % and when. 
    
    randmat = createStimFingMat(nrOutputs, signal_fing, orderlist, restdur, pTime);
    logger(logfile, 'INPUTS STIMULATE IN RANDOM ORDER #1 :', 0)
    logvars(logfile, nrOutputs, amplitude, frequency, stimdur_fing_on, stimdur_fing_off, ...
        stimdur_total_fing, restdur, pDur, randlength);
    
    queueOutputData(s, randmat)
    
    if sp_in ~=0
        fmri_trigger(sp_in, logfile, 'Start stimulating outputs in random order')
    end
    
    tic
    s.startBackground
    if sp_out ~= 0
        fprintf(sp_out, '%c', 20);
    end
    logger(logfile, char(strcat('start time delay is', {' '}, num2str(toc))))
    logfing(logfile, orderlist, restdur, pTime, stimdur_total_fing, sp_out);
    
    if sp_in ~=0
        fmri_trigger(sp_in, logfile, 'End of stimulating outputs in random order')
        stop(s);
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