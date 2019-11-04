function logmult(logfile, orderlist, pTime, stimdur, serialport)
% Function that logs the timing of the multiple finger experiment. It is
% based on the internal stopwatch function, so not 100% accurate. You will
% need the following parameters:
% - logfile = path to logfile where the details should be logged to
% - orderlist = list describing the order of finger stimulations
% - pTime = rest time in seconds between stimulations
% - stimdur = duration of stimulation in seconds
% - serialport = output serialport to send trigger when experiment is over.
%                   No serialport is 0.
% TODO: STILL NEEDS SOME CLEANING

tic
switch nargin
    case 2
        pTime = 7;
        stimdur = 4;
        serialport = 0;
    case 3
        stimdur = 4;
        serialport = 0;
    case 4
        serialport = 0;
end
timing = pTime;

logger(logfile, char(strcat('rest for', {' '}, num2str(pTime), {' '}, 'seconds'))); 


running = 1;
output = 1;
order = orderlist(i,:);
while running
    if round(toc, 2) == round(timing, 2)
        if output == length(order)
            if serialport ~=0
               fprintf(serialport, '%c', num2str(order(output)));
            end
            logger(logfile, char(strcat('STIMULATING OUTPUT(S)', {' '}, num2str(order{output}),...
                {': '}, num2str(round(toc, 2)), {' '},...
                'seconds after start of experiment')));
        else    
            if serialport ~=0
               fprintf(serialport, '%c', num2str(order(output)));
            end
            logger(logfile, char(strcat('STIMULATING OUTPUT', {' '}, num2str(order(output)),...
                {': '}, num2str(round(toc, 2)), {' '},...
                'seconds after start of experiment, next stimulation in', {' '}, num2str(pTime), {' '},...
                    'seconds')));
        end
        output = output + 1;
        if output <= length(order)
            timing = timing + pTime;
        else 
            timing = timing + restdur + stimdur;
            running = ~running;
            if i == blocks
                pause(stimdur)
                logger(logfile, char(strcat('end of block', {' '}, num2str(i))));
            else
                pause(stimdur)
                logger(logfile, char(strcat('end of block', {' '}, num2str(i),...
                    ', rest for', {' '}, num2str(restdur), {' '}, 'seconds')));
            end
        end
    end
end
if serialport ~=0
   fprintf(serialport, '%c', 30);
end
end