function stimAllMat = createStimAllMat(nrOutputs, signal, onsets, serialport)
% Function that creates a stimulation matrix for the individual fingers
% experiment. It requires the following parameters:
% - nrOutputs = number of outputs that are used
% - signal = the stimulation signal used in the experiment
% - onsets = list describing the onsets of stimulations
% - serialport = not yet used...

switch nargin
    case 3
        serialport = 0;
end
stimAllMat = [];
stimulations = length(onsets);
stimdur = length(signal)/1000;
task = [zeros(onsets(1)*1000, 1); signal];

for stim = 2:stimulations
    tbs =int64((onsets(stim) - onsets(stim-1) - stimdur) *1000);
    rest = zeros(tbs, 1);
    task = [task; rest; signal];
end

for output = 1:nrOutputs
    stimAllMat = [stimAllMat task];
end
