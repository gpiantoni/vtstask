clear
subject = 'test_1';
logdir = 'C:\Users\mthio.LA020080\Documents\GitHub\vtstask\logfiles\';
logfile = fopen(strcat(logdir, 'log_subject_', subject, '.txt'), 'w');
logger(logfile, char(strcat('Initiate logging for subject', {' '}, subject))); 

devices = daq.getDevices;  % register DAQ devices
s = daq.createSession('ni'); % Create session with NI devices


% serial ports
PORT_OUT = "COM5";
PORT_IN = "COM9";

% DAQ devices
daq1 = 'cDAQ1mod1';
daq2 = 'cDAQ1mod2';

% Create output signal
nrOutputs = 5;
amplitude = 1; %TODO: Find out what the output amplitude is (in voltage)
frequency = 30 ; %Hz

% --- Onsets based on hrf_pattern ---
hrf_filename = 'sub-V7818_ses-UMC-7T_task-hrfpattern_run-1_20180306T170321.tsv';
hrf_tsv = tdfread(hrf_filename);
hrf_onsets =  hrf_tsv.onset;

% --- read file with randomised stimulations ---
rand_filename = 'randomlist_5_fingers.txt';
randFile = fopen(rand_filename);
randcell = textscan(randFile, '%d');
randomlist = cell2mat(randcell);
fclose(randFile);
randlength = length(randomlist)/nrOutputs;
orderlist = transpose(reshape(randomlist, [nrOutputs,randlength]));

%% log files
fprintf(logfile, '\n%s: %s\n%s: %s\n\n',...
    'hRF onsets file: ', hrf_filename, ...
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
    sp_in.Timeout = 300;
catch ME
    warning('no input serial port found. input serial port set to 0');
    sp_in = 0;
end

%% EXPERIMENTS
try
    
    % --- stimulate all ---
    stimdur = .4;
    signal = createSignal(frequency, amplitude, stimdur);
    logger(logfile, '\nINPUTS STIMULATE ALL', 0);
    logvars(logfile, nrOutputs, amplitude, frequency, stimdur);
    
    stimAllMat = createStimAllMat(nrOutputs, signal, hrf_onsets(1:1));

    queueOutputData(s, stimAllMat)
    if sp_in ~=0
        fmri_trigger(sp_in, logfile, 'Start stimulating all outputs')
    end
    tic
    s.startBackground
    logger(logfile, char(strcat('start time delay is', {' '}, num2str(toc))))
    if sp_in ~=0
        fmri_trigger(sp_in, logfile, 'End of stimulating all outputs')
        stop(s);
    end
    %% --- stimulate sequential ---
    restdur = 4.4;  
    pTime = 1.6;
    reps = 4;
    seqmat = createStimSeqMat(nrOutputs, signal, reps, restdur, pTime);
    
    logger(logfile, 'INPUTS STIMULATE IN SEQUENCE', 0)
    logvars(logfile, nrOutputs, amplitude, frequency, stimdur, restdur, pTime, reps);
    
    queueOutputData(s, seqmat)
   
    if sp_in ~=0
        fmri_trigger(sp_in, logfile, 'Start stimulating ouputs in sequence')
    end
    
    tic
    s.startBackground
    logger(logfile, char(strcat('start time delay is', {' '}, num2str(toc))))
    
    if sp_in ~=0
        fmri_trigger(sp_in, logfile, 'End of stimulating ouputs in sequence');
        stop(s);
    end
    %% --- stimulate random ---
    
    randmat = createStimRandMat(nrOutputs, signal, orderlist, restdur, pTime);
    logger(logfile, 'INPUTS STIMULATE IN RANDOM ORDER', 0)
    logvars(logfile, nrOutputs, amplitude, frequency, stimdur, restdur, pTime, reps);

    queueOutputData(s, randmat)
    
    if sp_in ~=0
        fmri_trigger(sp_in, logfile, 'Start stimulating outputs in random order')
    end
    
    tic
    s.startBackground
    logger(logfile, char(strcat('start time delay is', {' '}, num2str(toc))))
    
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

function logvars(logfile, nrOutputs, amplitude, frequency, stimdur, restdur, pTime, reps)
if nargin < 6
    fprintf(logfile, '\n%s: %f\n%s: %f\n%s: %f\n%s: %f\n\n',...
        'number of outputs: ', nrOutputs,...
        'amplitude: ', amplitude, ...
        'frequency: ', frequency, ...
        'duration of stimulation in seconds: ', stimdur);
else
    fprintf(logfile, '\n%s: %f\n%s: %f\n%s: %f\n%s: %f\n%s: %f\n%s: %f\n%s: %f\n\n',...
        'number of outputs: ', nrOutputs,...
        'amplitude: ', amplitude, ...
        'frequency: ', frequency, ...
        'duration of stimulation in seconds: ', stimdur, ...
        'duration between blocks in seconds: ', restdur,...
        'duration betweens stimulation in seconds: ', pTime,...
        'number of repetitions: ', reps);
end
end
