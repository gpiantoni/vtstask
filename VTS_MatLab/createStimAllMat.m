function stimAllMat = createStimAllMat(nrOutputs, signal, onsets, serialport)

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
    rest = zeros( tbs, 1);
    task = [task; rest; signal];
end

for output = 1:nrOutputs
    stimAllMat = [stimAllMat task];
end
