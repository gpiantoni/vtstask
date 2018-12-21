function stimOne(session, outputSignal, finger, nrOutputs, serialport)

switch nargin
    case 4
        serialport = 0;
end

lenOutSig = length(outputSignal);
allOutputs = zeros(lenOutSig, nrOutputs);
allOutputs(:, finger) = outputSignal;
queueOutputData(session, repmat(allOutputs, 1, 1));
disp(strcat('stimulator nr. ', {' '}, int2str(finger)));

% send signal through serial port if available
if serialport ~= 0 
    fprintf(serialport, '%c', 10 + finger);
end
% stimulate
session.startBackground;
toc
end