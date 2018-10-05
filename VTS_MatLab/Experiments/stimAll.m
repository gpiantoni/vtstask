function stimAll(session, outputSignal, nrOutputs, serialport)
% Function that stimulates all the outputs
% 
% - session: DAQ session
% - outputSignal: The output signal
% - nrOutputs: Number of stimulators
% - serialport: Serial port

switch nargin
    case 3
        serialport = 0;
end

signals = outputSignal;

for out = 1 : nrOutputs-1
    signals = cat(2, signals, outputSignal);
end

queueOutputData(session, repmat(signals, 1, 1));
disp('stimulating all');

if serialport ~= 0
    fprintf(serialport, '%c', 10);
end

session.startForeground;

if serialport ~= 0
    fprintf(serialport, '%c', 150);
end

