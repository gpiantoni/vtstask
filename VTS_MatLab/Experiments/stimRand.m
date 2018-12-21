function [timing] =  stimRand(session, outputSignal, nrOutputs, orderlist, restDur, pTime, serialport)
tic
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
time = restDur;
disp(strcat('rest for', {' '}, num2str(restDur), {' '}, 'seconds'));
timing = []; 
blocks = size(orderlist);
blocks = blocks(1);

for i = 1:blocks
    running = 1;
    finger = 1;
    order = orderlist(i,:);
    while running
        if round(toc, 2) == round(time, 2)
            stimOne(session, outputSignal, order(finger), nrOutputs, serialport)
            timing = [timing round(toc,2)];
            pause(length(outputSignal)/1000); % so startBackground won't fail
            finger = finger + 1;
            if finger <= length(order)
                time = time + pTime;
                disp(strcat('rest for', {' '}, num2str(pTime), {' '}, 'seconds'));
            else 
                time = time + restDur;
                running = ~running;
                disp(strcat('end  of block', {' '}, num2str(i)));
            end
        end
    end
end
