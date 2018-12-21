function stimRandSW(session, outputSignal, nrOutputs, order, restDur, pTime, serialport)

switch nargin
    case 4
        restDur = 14.4;
        pTime = 7;
        serialport = 0;
    case 5
        pTime = 7;
        serialport = 0;
    case 6
        serialport = 0;
end

index = 1;
running = 1;
disp(strcat('rest for', {' '}, num2str(restDur), {' '}, 'seconds'));
tic
while running
    if round(toc, 2) == round(restDur, 2)
        toc
        stimOne(session, outputSignal, order(index), nrOutputs, serialport)
        restDur = restDur + pTime;
        index = index + 1;
        disp(strcat('rest for', {' '}, num2str(pTime), {' '}, 'seconds'));
    end
    if index > nrOutputs
        running = ~running;
    end
end

