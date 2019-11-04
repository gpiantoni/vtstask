clear;clc
subject = 'TEST_ROSA';
logdir = 'C:\Users\mthio.LA020080\Documents\GitHub\vtstask\logfiles\';
logfile = fopen(strcat(logdir, 'log_subject_', subject, '.txt'), 'a');
logger(logfile, char(strcat('Initiate logging for subject', {' '}, subject))); 

devices = daq.getDevices;  % register DAQ devices
s = daq.createSession('ni'); % Create session with NI devices

% serial ports
PORT_OUT = "COM5";
PORT_IN = "COM9";

% DAQ devices
daq1 = 'cDAQ1mod1';
daq2 = 'cDAQ1mod2';

%% Create output signal
nrOutputs = 3;
amplitude = 2;
frequency = 25;

stimdur_on = .4;
stimdur_off = .1;

stimdur_total = 12;
stimreps = stimdur_total/(stimdur_on+stimdur_off) ;

pDur = 16;
pTime = pDur + stimdur_total;
signal = createSignal(frequency, amplitude, stimdur_on, stimdur_off, stimreps);
stims = {[2], [2,3], [2,1],...
    [2, 1], [2, 3], [2], ...
    [2], [2, 3], [2, 1], ...
    [2, 1], [2, 3], [2], ...
    [2], [2, 3], [2, 1]};

stimMat = createStimMultMat(nrOutputs, signal, stims, pDur);

addChannels(s, nrOutputs, daq2);
%%
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

 %%
 logger(logfile, 'INPUTS STIMULATE IN RANDOM ORDER #1 :', 0)
%  logvars(logfile, nrOutputs, amplitude, frequency, stimdur_on, stimdur_off, ...
%      stimdur_total, pTime, pDur, 0);
queueOutputData(s, stimMat)
if sp_in ~=0
    fmri_trigger(sp_in, logfile, 'Start stimulating outputs in random order')
else
    pause
end

tic
s.startBackground
if sp_out ~= 0
    fprintf(sp_out, '%c', 20);
end
logger(logfile, char(strcat('start time delay is', {' '}, num2str(toc))))
