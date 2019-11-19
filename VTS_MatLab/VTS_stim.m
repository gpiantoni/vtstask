clear;clc
%% NOTES on SERIALPORTS 
%fclose(instrfind): closing all serial ports manually 
%instrfind: see which serial ports are closed and open
%seriallist: see all serialports that are connected

%% Variables 

% Fill subject number and log directory. 
subject = 'TEST_Dryrun_19_11';
logdir = 'C:\Users\mthio.LA020080\Documents\GitHub\vtstask\logfiles\';
logfile = fopen(strcat(logdir, 'log_subject_', subject, '.txt'), 'a');
logger(logfile, char(strcat('Initiate logging for subject', {' '}, subject))); 

% Each device has 10 outputs, specify here if you only want to use: 
% - 10 outputs or less: nrOutputs = 10, nrOutputs1 = 0, nrOutputs2 = 10
% - more than 10 outputs:  nrOutputs = 20, nrOuputs1 = 10, nrOutputs2 = 10
nrOutputs = 20;
nrOutputs1 = 10;
nrOutputs2 = 10;

% register the amplifier
devices = daq.getDevices;  % register DAQ devices
s = daq.createSession('ni'); % Create session with NI devices

% serial ports
PORT_OUT_ECOG = "COM10"; % only for ECoG
begin_task = 100;

PORT_IN_MR = seriallist;  % only for MR

% One daq device can hold 10 stimulators. If more than 10
% stimulators are needed, use two DAQ devices. 
daq2 = 'cDAQ1mod2';
daq1 = 'cDAQ1mod1';

%% --- Load files for experiment ---
% File with experiment design loaded. Values are seperated by semicolons, 
% top of 10 lines of the file contain comments. 

fname = 'design_rand.txt';
file = fopen(fname);
cells = textscan(file, '%f %s %d %d %f %f %f', ...
    'delimiter', ';', 'headerlines', 10);

onsets = cell2mat(cells(1))';
outputlist = cells{2};
amplitude = cell2mat(cells(3))';
frequency = cell2mat(cells(4))';
ondur = cell2mat(cells(5))';
offdur = cell2mat(cells(6))';
stimdur = cell2mat(cells(7))';
last_stimdur = stimdur(length(stimdur));
fclose(file);

%% logs design used

 fprintf(logfile, '\n%s: %s\n', ... 
     'design filename: ', fname); 
 
%% add all the channels to the session

addChannels(s, nrOutputs2, daq2);
if nrOutputs > 10
addChannels(s, nrOutputs1, daq1);
end

%% --- Open serial ports if available ---
try
    sp_out = serial(PORT_OUT_ECOG);
    fopen(sp_out);
    disp(strcat('opening serial port:', {' '}, PORT_OUT_ECOG));
catch ME
    warning('no ecog output serial port found. output serial port set to 0');
    sp_out = 0;
end

try
    sp_in = serial(PORT_IN_MR);
    fopen(sp_in);
    disp(strcat('opening serial port:', {' '}, PORT_IN_MR));
    sp_in.Timeout = inf;
catch ME
    warning('no MR input serial port found. input serial port set to 0');
    sp_in = 0;
end

try
%% --- stimulate all ---
    % All fingers are stimulated at certain intervals. The matrix is generated 
    % using the 'createStimMat' function. Start time delay between command
    % and actual stimulation is logged
    
    stimMat = createStimMat(nrOutputs, onsets, outputlist, frequency,... 
    amplitude, ondur, offdur, stimdur);

    stimMat2 = stimMat(:, 1:nrOutputs2);
    if nrOutputs > 10
        stimMat1 = stimMat(:, 11:nrOutputs);
    end

    if nrOutputs > 10
        queueOutputData(s, [stimMat2, stimMat1])
    else
        queueOutputData(s, stimMat2)
    end
    
    if sp_in ~=0
        fmri_trigger(sp_in, logfile, 'Start stimulating all outputs')
    else
        disp('No MR trigger box detected, press any key to manually start experiment')
        pause;
    end
    
    disp("TASK STARTED")
    task_start = tic;
    delay = tic;
    s.startBackground
    start_time_delay = num2str(toc(delay)); 
    
    %use log to test new  designs...
    %loglr(logfile, onsets, outputlist, sp_out);
    
    % Send trigger to ecog serial port for start experiment
    if sp_out ~= 0
        fprintf(sp_out, '%c', begin_task);
        ecog_trigger(onsets, outputlist, last_stimdur, sp_out);
    end
    
    task_busy = true;
    if sp_in ~=0
        while task_busy
            if toc(task_start) >= onsets(length(onsets)) + stimdur(length(stimdur)) + 2
            task_busy = ~task_busy;
            fmri_trigger(sp_in, logfile, 'End of stimulating all outputs')
            stop(s);
            end
        end
    end
    
    if sp_in == 0 && sp_out == 0
        while task_busy
            if toc(task_start) >= onsets(length(onsets)) + stimdur(length(stimdur)) + 2 %arbitrary number for start time delay
                disp(toc(task_start))
                task_busy = ~task_busy;
                disp('End of stimulation, press any key to continue')
                pause
                stop(s) 
            end
        end
    end
    
     logger(logfile, char(strcat('Start time delay was', {' '}, num2str(start_time_delay))))
     
    %% --- Close serial ports ---
    % Serial ports should be closed, otherwise it will not remain open and
    % the serialport cannot be registered again as 'sp_in' or 'sp_out'.
    % This could distort the process.
    
    if sp_out ~= 0
        disp(strcat('closing serial port:',{' '}, PORT_OUT_ECOG));
        fclose(sp_out);
    end
    
    if sp_in ~= 0
        fclose(sp_in);
        disp(strcat('closing serial port:',{' '}, PORT_IN_MR));
    end
    fclose(logfile);
    
catch e
    if sp_out ~= 0
        fclose(sp_out);
        disp(strcat('closing serial port:',{' '}, PORT_OUT_ECOG));
    end
    
    if sp_in ~= 0
        fclose(sp_in);
        disp(strcat('closing serial port:',{' '}, PORT_IN_MR));
    end
    fclose(logfile);
    fprintf(2, e.message);
end



