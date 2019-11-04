function loglr(logfile, onsets, outputlist, serialport)
% Function that logs the timing of the stimulate_all experiment. It is
% based on the internal stopwatch function, so not 100% accurate. 
switch nargin
    case 3
        stimdur = 1;
        serialport = 0;
    case 4
        serialport = 0;
end
    
tic
logging = true;
i = 1;
logger(logfile, char(strcat('rest for', {' '}, num2str(onsets(1)), {' '}, 'seconds')))

while logging
    if i > length(onsets)
        logging = ~logging;
    elseif round(toc, 2) == round(onsets(i), 2)
        if i ~= length(onsets)
            if serialport ~=0
               fprintf(serialport, '%c', 15);
            end
            logger(logfile, char(strcat('OUTPUTS', '(', num2str(outputlist{i}),')',' STIMULATION', {' '}, num2str(i), {': '},...
            num2str(round(toc, 2)), {' '}, 'seconds after start of experiment, next stimulation in', ...
            {' '}, num2str(onsets(i+1) - onsets(i)),{' '}, 'seconds')));
        else
            if serialport ~=0
               fprintf(serialport, '%c', 15);
            end
            logger(logfile, char(strcat('OUTPUTS', '(', num2str(outputlist{i}),')', ' STIMULATION', {' '}, num2str(i), {': '},...
            num2str(round(toc, 2)), {' '}, 'seconds after start of experiment')));
        end
        i = i+1;
    end
end

if serialport ~=0
    pause(stimdur)
    fprintf(serialport, '%c', 30);
end
end
        
                
            
    