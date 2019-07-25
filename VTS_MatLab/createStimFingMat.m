function stimRandMat = createStimFingMat(nrOutputs, signal, orderlist, restDur, pTime, serialport)
% Function that creates a stimulation matrix for the individual fingers
% experiment. It requires the following parameters:
% - nrOutputs = number of outputs that are used
% - signal = the stimulation signal used in the experiment
% - orderlist = list describing the order of finger stimulations
% - restdur = rest time in seconds between blocks
% - pTime = rest time in seconds between stimulations
% - stimdur = duration of stimulation in seconds
% - serialport = not used...
% NOTE: This function can also be used to create a stimulation matrix where
% the order is fixed, just load in such an order as the orderlist. 

switch nargin
    case 3
        restDur = 5;
        pTime = 3;
        serialport = 0;
    case 4
        pTime = 3;
        serialport = 0;
    case 5
        serialport = 0;
end

dims = size(orderlist);
reps = dims(1);
stimDur = length(signal)/1000;
stimRandMat = [];
rest = zeros(restDur*1000,1);

for rep = 1:reps
    if rep == 1
        rest = zeros(restDur*1000,1);
    else
        rest = zeros((restDur)*1000,1);
    end
    allSignals = [];
    order = orderlist(rep,:);
    for output = 1:nrOutputs
        sigVector = 0;
        pos = find(order==output);
        if isempty(pos)
            nosig = stimDur+pTime*(nrOutputs-1);
            sigVector = [rest;zeros(int64(nosig*1000), 1)];
        else
            for p = 1:length(pos)
                before = (pos(p)-1)*pTime;
                after = (5-pos(p))*pTime;
                tbs = zeros(int64(before*1000),1);
                tas = zeros(int64(after*1000), 1);
                sigVector = sigVector + [rest;tbs;signal;tas];
            end
        end
        allSignals = [allSignals sigVector];
    end
    stimRandMat = [stimRandMat;allSignals];
end
end