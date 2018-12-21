function [timing] =  stimSeqSW(session, outputSignal, nrOutputs, reversed, restDur, pTime, serialport)
% Function that stimulates outpus in sequence, timed on a stopwatch. Starts
% after a duration in seconds given by restDur. After this, stimulation
% happens after pTime seconds. 
% 
% - session: DAQ session
% - outputSignal: The output signal
% - nrOutputs: Number of stimulators
% - reversed: indicates whether to stimulate 1:end or end:1
% - restDur: initial waiting period
% - pTime: period between stimuation
% - serialport: Serial port

switch nargin
    case 3
        reversed = false;
        restDur = 3.2;
        pTime = 7;
        serialport = 0;
    case 4
        restDur = 3.2;
        pTime = 7;
        serialport = 0;
    case 5
        pTime = 7;
        serialport = 0;
    case 6
        serialport = 0;
end
timing = [];
time = restDur;
tic
run = 1;
disp('start run 1')
if reversed
    finger = nrOutputs;
    running = 1;
    disp(strcat('pause:',{' '}, num2str(restDur), {' '}, 'second(s)'));
    while running
        if round(toc, 2) == round(time, 2)
            stimOne(session, outputSignal, finger, nrOutputs, serialport)
            timing = [timing toc];
            finger = finger - 1;
            if finger ~= 0
                time = time + pTime;                   
                disp(strcat('pause:',{' '}, num2str(pTime), {' '}, 'second(s)'));
            end
        end
        if finger == 0 
            disp(strcat('end run', {' '}, num2str(run-1),', start run',{' '}, num2str(run)))
            running = ~running;
        end
    end
else
    finger = 1;
    running = 1;
    disp(strcat('pause:',{' '}, num2str(restDur), {' '}, 'second(s)'));
    while running
        if round(toc, 2) == round(time, 2)
            stimOne(session, outputSignal, finger, nrOutputs, serialport)
            timing = [timing toc];
            time = time + pTime;
            finger = finger + 1;
            disp(strcat('pause:',{' '}, num2str(pTime), {' '}, 'second(s)'));
        end
        if finger > nrOutputs 
            disp(time)
            running = ~running;
        end
    end
end

        
