function [timing] =  stimSeq(session, outputSignal, nrOutputs, blocks, reversed, restDur, pTime, serialport)
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
    case 4
        reversed = false;
        restDur = 3.2;
        pTime = 7;
        serialport = 0;
    case 5
        restDur = 3.2;
        pTime = 7;
        serialport = 0;
    case 6
        pTime = 7;
        serialport = 0;
    case 7
        serialport = 0;
end
timing = [];
time = restDur;
tic
run = 1;
disp('start run 1')
while run <= blocks
    if reversed
        finger = nrOutputs;
        running = 1;
        disp(strcat('pause:',{' '}, num2str(restDur), {' '}, 'second(s)'));
        while running
            if round(toc, 2) == round(time, 2)
                stimOne(session, outputSignal, finger, nrOutputs, serialport)
                timing = [timing toc];
                pause(length(outputSignal)/1000);
                finger = finger - 1;
                if finger ~= 0
                    time = time + pTime;                   
                    disp(strcat('pause:',{' '}, num2str(pTime), {' '}, 'second(s)'));
                end
            end
            if finger == 0 
                time = time + restDur;
                reversed = ~reversed;
                run = run + 1;
                if run ~= blocks
                    disp(strcat('end run', {' '}, num2str(run-1),', start run',{' '}, num2str(run)))
                end
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
                pause(length(outputSignal)/1000);
                finger = finger + 1;
                if finger <= nrOutputs
                    time = time + pTime;
                    disp(strcat('pause:',{' '}, num2str(pTime), {' '}, 'second(s)'));
                end
            end
            if finger > nrOutputs 
                time = time + restDur;
                disp(time)
                reversed = ~reversed;
                run = run + 1;
                if run ~= blocks
                    disp(strcat('end run', {' '}, num2str(run-1),', start run',{' '}, num2str(run)))
                end
                running = ~running;
            end
        end
    end
end
        
