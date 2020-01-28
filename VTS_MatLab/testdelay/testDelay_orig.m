% add path to the folder containing the low latency scripts
addpath C:\Users\mthio.LA020080\Documents\GitHub\vtstask\VTS_MatLab\low-latency-startForeground\

% create a structure to hold all stimulus parameters
stimParams = struct;

% output rate of the NIdaq device
stimParams.NIdaqRate = 1000;
% name of the daq module (in the first slot of the main device)
stimParams.NIdaqName = 'cDAQ1mod1';
% name of the digital module (in the second slot)
stimParams.NIdaqName2 = 'cDAQ1mod2';
% analog output channels for the tactile device
stimParams.noAnalogOutputChannels = 2;
% digital output channels for the trigger
stimParams.noDigitalOutputChannels = 2;

% frequency of the tactile signal
stimParams.signalFrequency = 5; %in Hz
% duration of the tactile signal
stimParams.signalDuration = 2; %in seconds
% calculate the samples per pulse for the tactile signal
stimParams.samplesPerPulse = stimParams.signalDuration * stimParams.NIdaqRate;
% create square wave ranging from 0 to 2 (max output allowed with VTS)
stimParams.pulse = (1 + square(linspace(0, ...
    (2*pi*stimParams.signalFrequency/stimParams.NIdaqRate * stimParams.samplesPerPulse), ...
    stimParams.samplesPerPulse)'))*.5;
% make sure that the pin goes back into its default position after the
% stimulus is over (otherwise there will be an additional tactile
% sensation)
stimParams.pulse(end)=0;

% Initialize session and parameters
NiDaqDevice = daq.createSession('ni');
NiDaqDevice.Rate = stimParams.NIdaqRate;


% add analog output channels to the session
for ii = 0:(stimParams.noAnalogOutputChannels - 1)
    %create name for the channel depending on stimulator number
    stimName = sprintf('ao%d', ii);
    %add channel
    addAnalogOutputChannel(NiDaqDevice, stimParams.NIdaqName, stimName, 'Voltage');
end

% add two digital channels
%digitalChannel = addDigitalChannel(NiDaqDevice, stimParams.NIdaqName2, 'Port0/Line0:1', 'OutputOnly');

% initialize current output matrix
currentOutput = zeros(stimParams.noAnalogOutputChannels + stimParams.noDigitalOutputChannels, stimParams.samplesPerPulse);

% add pulse at current output channel to output matrix
currentOutput(:,1:length(stimParams.pulse)) = repmat(stimParams.pulse, 1, stimParams.noAnalogOutputChannels + stimParams.noDigitalOutputChannels)';

% matlab official version
% %% iterate through repetitions %%
% for repetition = 1:10
%
%     % Queue the data
%     queueOutputData(NiDaqDevice, currentOutput');
%
%     % slightly improve timing
%     prepare(NiDaqDevice);
%
%     % make sure everything is cued
%     pause(1)
%
%     %start timing
%     tic
%     %start output
%     startBackground(NiDaqDevice)
%     %end timing
%     toc
%
%     % make very sure the queuing is not the problem
%     pause(stimParams.signalDuration + 1);
% end
%

% create separate handles for analog and digital lines
aoCh(1) = NiDaqDevice.Channels(1);
%aoCh(2) = NiDaqDevice.Channels(3);


% repeat signal to access variability of the delay
for repetition = 1:5
    
    % pause between repetitions
    pause(1);
    
    % create separate handles for analog and digital lines
    aoTaskHandle(1) = aoCh(1).TaskHandle;
   % aoTaskHandle(2) = aoCh(2).TaskHandle;
    
    
    % Configure handles (rate, number of scans)
    NI_DAQmxCfgSampClkTiming(aoTaskHandle(1), NiDaqDevice.Rate, size(currentOutput', 1));
    %NI_DAQmxCfgSampClkTiming(aoTaskHandle(2), NiDaqDevice.Rate, size(currentOutput', 1));
    
    % needed for digital low latency to work (no idea why)
    %NI_DAQmxExportSignal(aoTaskHandle(2), '/cDAQ1Mod2/PFI0')
    
    % queue output data
    NI_DAQmxWriteAnalogF64(aoTaskHandle(1), currentOutput(1:2,:)');
    %NI_DAQmxWriteDigital(aoTaskHandle(2), currentOutput');
    
    % start the task of outputting either signal
    tic
    NI_DAQmxStartTask(aoTaskHandle(1));
    %NI_DAQmxStartTask(aoTaskHandle(2));
    toc
    
    % wait shortly
    pause(0.1);
    
    % wait until signal generation is finished
    NI_DAQmxWaitUntilTaskDone(aoTaskHandle(1), 10);
    %NI_DAQmxWaitUntilTaskDone(aoTaskHandle(2), 10);
    
    % stop the task
    NI_DAQmxStopTask(aoTaskHandle(1));
    %NI_DAQmxStopTask(aoTaskHandle(2));
    
    %pause shortly
    pause(1 + rand());
    
end

%release the device
release(NiDaqDevice)

