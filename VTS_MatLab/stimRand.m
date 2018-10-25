function [randomlist] = stimRand(session, outputSignal, nrOutputs, serialport, pTime, randomlist)
% Function that stimulates the outputs in sequence
% 
% - session: DAQ session
% - outputSignal: The output signal
% - nrOutputs: Number of stimulators
% - serialport: Serial port
% - pTime: Pause between stimulation (default= 200 ms)

switch nargin
    case 3
        serialport = 0;
        pTime = .2;
        randomlist = randperm(nrOutputs);
    case 4
        pTime = .2;
        randomlist = randperm(nrOutputs);
    case 5
        randomlist = randperm(nrOutputs);
end

lenOutSig = length(outputSignal);

for i = 1: length(randomlist)
    allOutputs = zeros(lenOutSig, nrOutputs);
    allOutputs(:, randomlist(i)) = outputSignal;
    queueOutputData(session, repmat(allOutputs, 1, 1));
    disp(strcat('stimulator nr. ', int2str(randomlist(i))));

    % send signal through serial port if available
    if serialport ~= 0 
        fprintf(serialport, '%c', 10 + randomlist(i));
    end
    % stimulate
    session.startForeground;
    if serialport ~= 0
        fprintf(serialport, '%c', 150);
    end
    pause(pTime);
end