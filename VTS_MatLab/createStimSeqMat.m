function seqMat = createStimSeqMat(nrOutputs, signal, reps, restDur, pTime, reversed, serialport)

switch nargin
    case 2
        reps = 2;
        restDur = 5;
        pTime = 3;
        reversed = false;
        serialport = 0;
    case 3
        restDur = 5;
        pTime = 3;
        reversed = false;
        serialport = 0;
    case 4
        pTime = 3;
        reversed = false;
        serialport = 0;
    case 5
        reversed = false;
        serialport = 0;
    case 6
        serialport = 0;
end

stimDur = length(signal)/1000;
seqMat = [];
for rep = 1:reps
    if rep == 1
        rest = zeros(restDur*1000,1);
    else
        rest = zeros((restDur-stimDur)*1000,1);
    end
    
    if ~reversed
        allSignals = [];
        for finger = 1:nrOutputs
            before = (finger-1)*pTime;
            after = (nrOutputs-finger)*pTime;
            tbs = zeros(int64(before*1000),1);
            tas = zeros(int64(after*1000), 1);
            sigVector = [rest;tbs;signal;tas];
            allSignals = [allSignals sigVector];
        end
        seqMat = [seqMat; allSignals];
        reversed = ~reversed;
    else
        allSignalsRev = [];
        for finger = 1:nrOutputs
            before = (nrOutputs-finger)*pTime;
            after = (finger-1)*pTime;
            tbs = zeros(int64(before*1000),1);
            tas = zeros(int64(after*1000), 1);
            sigVector = [rest;tbs;signal;tas];
            allSignalsRev = [allSignalsRev sigVector];
        end
        seqMat = [seqMat; allSignalsRev];
        reversed = ~reversed;
    end
end
end