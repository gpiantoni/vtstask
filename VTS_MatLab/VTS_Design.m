clear;clc
subject = 'V8635';
logdir = 'C:\Users\mthio.LA020080\Documents\GitHub\vtstask\logfiles\';
logfile = fopen(strcat(logdir, 'log_subject_', subject, '.txt'), 'a');
logger(logfile, char(strcat('Initiate logging for subject', {' '}, subject))); 

devices = daq.getDevices;  % register DAQ devices
s = daq.createSession('ni'); % Create session with NI devices

% serial ports
PORT_OUT = "COM5";
PORT_IN = seriallist;

% DAQ devices
daq1 = 'cDAQ1mod1';
daq2 = 'cDAQ1mod2';

%% Create output signal
nrOutputs = 5;
amplitude = 2; %TODO: Find out what the output amplitude is (in voltage)
frequency = 30;
frequency2 = 110; %Hz
frequency3 = 190;
% stimulation variables for stimAll
stimdur_all_on = .2;
stimdur_all_off = .05;
stimdur_total_all = 16;
reps_all = stimdur_total_all/(stimdur_all_on+stimdur_all_off);

% stimulation variables seperate finger stimulation
stimdur_fing_on = .4;
stimdur_fing_off = .1;
stimdur_total_fing = 4;

restdur = 14.4; % Rest between stimulation (after stimulation stops)
% restTime = restdur + stimdur_total_fing;
pDur = 10;
pTime = pDur + stimdur_total_fing;
reps_fing = stimdur_total_fing/(stimdur_fing_on+stimdur_fing_off) ;

% create signals for both
signal_all = createSignal(frequency, amplitude, stimdur_all_on, stimdur_all_off, reps_all);
signal_fing = createSignal(frequency, amplitude, stimdur_fing_on, stimdur_fing_off, reps_fing);
signal_fing2 = createSignal(frequency2, amplitude, stimdur_fing_on, stimdur_fing_off, reps_fing);
signal_fing3 = createSignal(frequency3, amplitude, stimdur_fing_on, stimdur_fing_off, reps_fing);

% --- Onsets based on hrf_pattern ---
hrf_filename = 'sub-V7818_ses-UMC-7T_task-hrfpattern_run-1_20180306T170321.tsv';
hrf_tsv = tdfread(hrf_filename);
hrf_onsets =  hrf_tsv.onset;
onsets = [16, 48, 80, 112, 144, 172, 204, 236];  % klaar met stimuleren na 252 sec

% --- read file with randomised stimulations ---
rand_filename = 'randomfingers.txt';
randFile = fopen(rand_filename);
randcell = textscan(randFile, '%d');
randomlist = cell2mat(randcell);
fclose(randFile);
randlength = length(randomlist)/nrOutputs;
orderlist = transpose(reshape(randomlist, [nrOutputs,randlength]));

%% log files for experiments
fprintf(logfile, '\n%s: %s\n%s: %s\n\n',...
    'hRF onsets: ', num2str(onsets), ...
    'random stimulation filename: ', rand_filename); 
%% add all the channels to the session
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

%% EXPERIMENTS
try
    %% --- stimulate all ---
    logger(logfile, 'INPUTS STIMULATE ALL:', 0);
    logvars(logfile, nrOutputs, amplitude, frequency, stimdur_all_on, stimdur_all_off, stimdur_total_all);
    
    stimAllMat = createStimAllMat(nrOutputs, signal_all, onsets);

    queueOutputData(s, stimAllMat)
    if sp_in ~=0
        fmri_trigger(sp_in, logfile, 'Start stimulating all outputs')
    end
    tic
    s.startBackground
    logger(logfile, char(strcat('start time delay is', {' '}, num2str(toc))))
    logall(logfile, onsets);
    if sp_in ~=0
        fmri_trigger(sp_in, logfile, 'End of stimulating all outputs')
        stop(s);
    end
    %% --- stimulate random #1---
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
    logger(logfile, char(strcat('start time delay is', {' '}, num2str(toc))))
    logfing(logfile, orderlist, restdur, pTime, stimdur_total_fing);
    
    if sp_in ~=0
        fmri_trigger(sp_in, logfile, 'End of stimulating outputs in random order')
        stop(s);
    end
    %% --- stimulate random #2---
    randmat = createStimFingMat(nrOutputs, signal_fing2, orderlist, restdur, pTime);
    logger(logfile, 'INPUTS STIMULATE IN RANDOM ORDER #2 :', 0)
    logvars(logfile, nrOutputs, amplitude, frequency2, stimdur_fing_on, stimdur_fing_off, ...
        stimdur_total_fing, restdur, pDur, randlength);
    
    queueOutputData(s, randmat)
    
    if sp_in ~=0
        fmri_trigger(sp_in, logfile, 'Start stimulating outputs in random order')
    end
    
    tic
    s.startBackground
    logger(logfile, char(strcat('start time delay is', {' '}, num2str(toc))))
    logfing(logfile, orderlist, restdur, pTime, stimdur_total_fing);
    
    if sp_in ~=0
        fmri_trigger(sp_in, logfile, 'End of stimulating outputs in random order')
        stop(s);
    end
    
%     %% --- stimulate random #3---
    randmat = createStimFingMat(nrOutputs, signal_fing3, orderlist, restdur, pTime);
    logger(logfile, 'INPUTS STIMULATE IN RANDOM ORDER #3 :', 0)
    logvars(logfile, nrOutputs, amplitude, frequency3, stimdur_fing_on, stimdur_fing_off, ...
        stimdur_total_fing, restdur, pDur, randlength);
    
    queueOutputData(s, randmat)
    
    if sp_in ~=0
        fmri_trigger(sp_in, logfile, 'Start stimulating outputs in random order')
    end
    
    tic
    s.startBackground
    logger(logfile, char(strcat('start time delay is', {' '}, num2str(toc))))
    logfing(logfile, orderlist, restdur, pTime, stimdur_total_fing);
    
    if sp_in ~=0
        fmri_trigger(sp_in, logfile, 'End of stimulating outputs in random order')
        stop(s);
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

function logvars(logfile, nrOutputs, amplitude, frequency, stimdur_on, stimdur_off, stimdur_total, restdur, pTime, reps)
if nargin < 8
    fprintf(logfile, '\n%s: %f\n%s: %f\n%s: %f\n%s: %f\n%s: %f\n%s: %f\n\n',...
        'number of outputs: ', nrOutputs,...
        'amplitude: ', amplitude, ...
        'frequency: ', frequency, ...
        'duration of stimulation ON in seconds: ', stimdur_on, ...
        'duration of stimulation OFF in seconds: ', stimdur_off, ...
        'total stimulation duration: ', stimdur_total);
else
    fprintf(logfile, '\n%s: %f\n%s: %f\n%s: %f\n%s: %f\n%s: %f\n%s: %f\n%s: %f\n%s: %f\n%s: %f\n\n',...
        'number of outputs: ', nrOutputs,...
        'amplitude: ', amplitude, ...
        'frequency: ', frequency, ...
        'duration of stimulation ON in seconds: ', stimdur_on, ...
        'duration of stimulation OFF in seconds: ', stimdur_off, ...
        'duration between blocks in seconds: ', restdur,...
        'duration between stimulation in seconds: ', pTime,...
        'total stimulation duration: ', stimdur_total, ... 
        'number of repetitions: ', reps);
end
end
