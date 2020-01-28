clear;clc
%% NOTES on SERIALPORTS 
%fclose(instrfind): closing all serial ports manually 
%instrfind: see which  serial ports are closed and open
%seriallist: see all serial ports that are connected
%stop(NiDaqDevice) stops the amplifier
%addpath(genpath('low-latency-startForeground/'))
addpath C:\Users\mthio.LA020080\Documents\GitHub\vtstask\VTS_MatLab\low-latency-startForeground\
%% Variables 
% Fill subject number and log directory. 
subject = 'ecogPilot';
logdir = 'C:\Users\mthio.LA020080\Documents\GitHub\vtstask\logfiles\';
logfile = fopen(strcat(logdir, 'log_subject_', subject, '.txt'), 'a');
logger(logfile, char(strcat('Initiate logging for subject', {' '}, subject))); 

% Each device has 10 outputs, specify here if you only want to use: 
% - 10 outputs or less: nrOutputs = 10, nrOutputs1 = 0, nrOutputs2 = 10
% - more than 10 outputs:  nrOutputs = 20, nrOuputs1 = 10, nrOutputs2 = 10
nrOutputs = 10;
nrOutputs1 = 0;
nrOutputs2 = 10;

% register the amplifier
devices = daq.getDevices;  % register DAQ devices
NiDaqDevice = daq.createSession('ni'); % Create session with NI devices

% serial ports
PORT_OUT_ECOG = "COM13"; % only for ECoG
begin_task = 100;

% One daq device can hold 10 stimulators. If more than 10
% stimulators are needed, use two DAQ devices. 
daq2 = 'cDAQ1mod2';

%% --- Load files for experiment ---
% File with experiment design loaded. Values are seperated by semicolons, 
% top of 10 lines of the file contain comments. 

fname = 'design_ecog_pretest.txt';
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

addChannels(NiDaqDevice, nrOutputs2, daq2);

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
%% --- stimulate all ---
    % All fingers are stimulated at certain intervals. The matrix is generated 
    % using the 'createStimMat' function. Start time delay between command
    % and actual stimulation is logged
    
    stimMat = createStimMat(nrOutputs, onsets, outputlist, frequency,... 
    amplitude, ondur, offdur, stimdur)';

    disp('Press any key to manually start experiment')
    
    pause;
    
        %%%%%%% CUSTOM MATLAB CODE TO REPLACE s.startBackground %%%%%%% 
        
    % create separate handles for analog lines
    % NOTE run maybe not for every tactile stimulus?
    aoCh(1) = NiDaqDevice.Channels(1);

    % create separate handles for analog and digital lines
    aoTaskHandle(1) = aoCh(1).TaskHandle;

    % Configure handles (rate, number of scans)
    NI_DAQmxCfgSampClkTiming(aoTaskHandle(1), NiDaqDevice.Rate, size(stimMat', 1));

    % queue output data
    NI_DAQmxWriteAnalogF64(aoTaskHandle(1), stimMat');

    disp("TASK STARTED")
    % start the task of outputting either signal
    
    NI_DAQmxStartTask(aoTaskHandle(1)); %%%
    
    % Send trigger to ecog serial port for start experiment 
    if sp_out ~= 0
        %disp(begin_task)
        fprintf(sp_out, '%c', begin_task);
        ecog_trigger(onsets, outputlist, last_stimdur, sp_out);
    end
    
    %disp(begin_task)
    %ecog_trigger(onsets, outputlist, last_stimdur);
    
    % wait until signal generation is finished
    % chech whether 10 ms works with your system
    NI_DAQmxWaitUntilTaskDone(aoTaskHandle(1), 100);

    % stop the task
    NI_DAQmxStopTask(aoTaskHandle(1));
    %%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%% %%%%%%%
    
    
    %use log to test new  designs...
    %loglr(logfile, onsets, outputlist, sp_out);
    
    
     
    %% --- Close serial ports ---
    % Serial ports should be closed, otherwise it will not remain open and
    % the serialport cannot be registered again as 'sp_in' or 'sp_out'.
    % This could distort the process.
    
    if sp_out ~= 0
        disp(strcat('closing serial port:',{' '}, PORT_OUT_ECOG));
        fclose(sp_out);
    end

    fclose(logfile);
    
catch e
    if sp_out ~= 0
        fclose(sp_out);
        disp(strcat('closing serial port:',{' '}, PORT_OUT_ECOG));
    end
    
    fclose(logfile);
    fprintf(2, e.message);
end



