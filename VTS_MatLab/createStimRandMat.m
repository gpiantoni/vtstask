function stimRandMat = createStimRandMat(nrOutputs, signal, orderlist, restDur, pTime, serialport)

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
        rest = zeros((restDur-stimDur)*1000,1);
    end
    
    allSignals = [];
    order = orderlist(rep,:);
    for output = 1:nrOutputs
        pos = find(order==output);
        before = (pos-1)*pTime;
        after = (5-pos)*pTime;
        tbs = zeros(int64(before*1000),1);
        tas = zeros(int64(after*1000), 1);
        sigVector = [rest;tbs;signal;tas];
        allSignals = [allSignals sigVector];
    end
    stimRandMat = [stimRandMat;allSignals];
end
end