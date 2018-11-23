function stimRandSW(session, outputSignal, nrOutputs, order, restDur, pTime, serialport)

switch nargin
    case 4
        restDur = 3;
        pTime = 3;
        serialport = 0;
    case 5
        restDur = 3;
        pTime = 3;
        serialport = 0;
end

index = 1;
running = 1;
while running
    if round(toc, 5) == restDur
        toc
        stimOne(session, outputSignal, order(index), nrOutputs, serialport)
        restDur = restDur + pTime;
        index = index + 1;
    end
    if index > nrOutputs
        running = ~running;
    end
end
