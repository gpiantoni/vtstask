function ecog_trigger(onsets, outputlist, last_stimdur, serialport)
% Function that logs the timing of the stimulate_all experiment. It is
% based on the internal stopwatch function, so not 100% accurate. 
switch nargin
    case 3
        serialport = 0;
end
    
tic
end_trigger_sending = true;
logging = true;
i = 1;

while logging
    
    if i > length(onsets)
        logging = ~logging;
    elseif round(toc, 2) == round(onsets(i), 2)
        if i ~= length(onsets)
            if serialport ~=0
               output_send = str2num(outputlist{i});
               %disp(output_send)
               fprintf(serialport, '%c', output_send);
            end
        else
            if serialport ~=0
               output_send = str2num(outputlist{i});
               %disp(output_send)
               fprintf(serialport, '%c', output_send);
            end
        end
        i = i+1;
    end
end

while end_trigger_sending   
    if round(toc, 2) == (round(onsets(length(onsets)),2) + last_stimdur)
        end_task = 200;
        %disp(end_task)
        fprintf(serialport, '%c', end_task);
        end_trigger_sending = ~end_trigger_sending;
    end
end

end
        
                
            
    