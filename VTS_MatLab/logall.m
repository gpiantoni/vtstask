function logall(logfile, onsets)
tic
logging = true;
i = 1;
logger(logfile, char(strcat('rest for', {' '}, num2str(onsets(1)), {' '}, 'seconds')))

while logging
    if i > length(onsets)
        logging = ~logging;
    elseif round(toc, 2) == round(onsets(i), 2)
        if i ~= length(onsets)
            logger(logfile, char(strcat('ALL OUPUTS STIMULATION', {' '}, num2str(i), {': '},...
            num2str(round(toc, 2)), {' '}, 'seconds after start of experiment, rest for', ...
            {' '}, num2str(onsets(i+1) - onsets(i)),{' '}, 'seconds')));
        else
            logger(logfile, char(strcat('ALL OUPUTS STIMULATION', {' '}, num2str(i), {': '},...
            num2str(round(toc, 2)), {' '}, 'seconds after start of experiment')));
        end
        i = i+1;
    end
end
end
        
                
            
    