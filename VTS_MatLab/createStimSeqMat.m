function seqMat = createStimSeqMat(nrOutputs, signal, blocks, restDur, pTime, reversed, serialport)

switch nargin
    case 2
        blocks = 2;
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

sigVect = [];
for i = 1:blocks
    order = [];
    if ~reversed
        for output = 1:nrOutputs
            order = [order, output];
        end
    else
        for output = 1:nrOutputs
            order = [order, (nrOutputs+1)-output];
        end
    end
    sigVect = [sigVect;order];
    reversed = ~reversed;
end

seqMat = createStimRandMat(nrOutputs, signal, sigVect, restDur, pTime, serialport);
end