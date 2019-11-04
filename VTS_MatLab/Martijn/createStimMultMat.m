function stimMultMat = createStimMultMat(nrOutputs, signal, stimmat, pTime, serialport)
% Function that creates a stimulation matrix for the multiple fingers
% experiment. It requires the following parameters:
% - nrOutputs = number of outputs that are used
% - signal = the stimulation signal used in the experiment
% - stimmat = stimulation matrix containing which fingers should be
%               stimulated together.
% - pTime = rest time in seconds between stimulations
% - serialport = not used...

switch nargin
    case 3
        pTime = 3;
        serialport = 0;
    case 4
        serialport = 0;
end

nStims = size(stimmat);
reps = nStims(2);
stimDur = length(signal);
rest = [];
for o = 1:nrOutputs
    rest = [rest, zeros(pTime*1000,1)];
end
stimMultMat  = rest;
for r = 1:reps
    allSignals = [];
    stims = stimmat{r};
    for out = 1:nrOutputs
        if ismember(out, stims)
            allSignals = [allSignals, signal];
        else
            allSignals = [allSignals, zeros(stimDur,1)];
        end
    end
    stimMultMat = [stimMultMat; allSignals];
    stimMultMat = [stimMultMat; rest];
end


        
        