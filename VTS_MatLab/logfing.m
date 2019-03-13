function logfing(logfile, orderlist, restdur, pTime, stimdur)
tic
switch nargin
    case 2
        restdur = 14.4;
        pTime = 7;
        stimdur = 4;
    case 3
        pTime = 7;
        stimdur = 4;
    case 4
        stimdur = 3;
end
timing = restdur;
dims = size(orderlist);
blocks = dims(1);
logger(logfile, char(strcat('rest for', {' '}, num2str(restdur), {' '}, 'seconds'))); 

for i = 1:blocks
    running = 1;
    output = 1;
    order = orderlist(i,:);
    while running
        if round(toc, 2) == round(timing, 2)
            if output == length(order)
                logger(logfile, char(strcat('STIMULATING OUTPUT', {' '}, num2str(order(output)),...
                    {': '}, num2str(round(toc, 2)), {' '},...
                    'seconds after start of experiment')));
            else    
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
end