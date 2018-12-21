clear
devices = daq.getDevices;  % register DAQ devices
%global session nrOutputs outputSignal finger randomindexer order
%%
s = daq.createSession('ni'); % Create session with NI devices
nrOutputs = 5;
finger = 1;
randomindexer = 1;
% randlist = [1 4 2 3 5; 3 4 2 5 1];
% serial ports
PORT_OUT = "COM5";
PORT_IN = "COM7";

% DAQ devices
daq1 = 'cDAQ1mod1';
daq2 = 'cDAQ1mod2';
%Create output signal
Amplitude = 1; %TODO: Find out what the output amplitude is (in voltage)
Frequency = 30 ; %Hz

outputSignal = createOutput(Frequency, Amplitude, 4, 3, 2, 3);
s.DurationInSeconds = length(outputSignal)/1000;
%
%Register one output for testing
addChannels(s, nrOutputs, daq2)

stimOne(s, outputSignal, finger, nrOutputs)
