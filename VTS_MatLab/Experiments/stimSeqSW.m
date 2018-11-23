function stimSeqSW(session, outputSignal, nrOutputs, reversed, restDur, pTime, serialport)

switch nargin
    case 3
        reversed = false;
        restDur = 3;
        pTime = 3;
        serialport = 0;
    case 4
        restDur = 3;
        pTime = 3;
        serialport = 0;
    case 5
        pTime = 3;
        serialport = 0;
    case 6
        serialport = 0;
end

if reversed
    finger = nrOutputs;
    running = 1;
    while running
        if round(toc, 5) == restDur
            toc
            stimOne(session, outputSignal, finger, nrOutputs, serialport)
            restDur = restDur + pTime;
            finger = finger - 1;
        end
        if finger == 0 
            running = ~running;
        end
    end
else
    finger = 1;
    running = 1;
    while running
        if round(toc, 5) == restDur
            toc
            stimOne(session, outputSignal, finger, nrOutputs, serialport)
            restDur = restDur + pTime;
            finger = finger + 1;
        end
        if finger > nrOutputs
            running = ~running;
        end
    end
end
        
