function intervalMat = createIntervalMat(nrOutputs, signal, pTime, restTime, signalReps, blocks)

blocksignal = createOutput(signal, pTime, signalReps);
intervalMat = [];
rest = zeros(restTime*1000, 1);

for output = 1:nrOutputs
    outputmat = blocksignal;
    for block = 2:blocks
        blockmat = [rest;blocksignal];
        outputmat = [outputmat; blockmat];
    end
    intervalMat = [intervalMat, outputmat];
end