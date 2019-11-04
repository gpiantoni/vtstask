clear
devices = daq.getDevices;  % register DAQ devices
nrOutputs = 5;
% serial ports
PORT_OUT = "COM5";
PORT_IN = "COM7";
daq1 = 'cDAQ1mod1';
daq2 = 'cDAQ1mod2';

% DAQ devices
s1 = daq.createSession('ni'); % Create session with NI devices

addChannels(s1, nrOutputs, daq2)
%%
%Create output signal
Amplitude = 1; %TODO: Find out what the output amplitude is (in voltage)
Frequency = 30 ; %Hz
Stimulation = 1.6;
% outputSignal = createOutputSignal(Frequency, Amplitude, session.DurationInSeconds);
signal = createSignal(Frequency, Amplitude, 1.6);

reversed = true;
randlist = [1 4 2 3 5; 3 4 2 5 1];
% session.DurationInSeconds = 1.6;  % duration of stimulus in seconds
onset = [5, 10, 15, 20];

seqmat = createStimSeqMat(nrOutputs, signal, 1);
stimAllMat = createStimAllMat(nrOutputs, signal, onset);
randmat = createStimRandMat(nrOutputs, signal, randlist);

queueOutputData(s1, seqmat);
s1
pause
s1.startForeground;
pause
queueOutputData(s1, stimAllMat);
s1
pause
s1.startForeground
pause
queueOutputData(s1, randmat);
s1
pause
s1.startForeground
disp('done')
% s2 = daq.createSession('ni');
% addChannels(s2, nrOutputs, daq2)

