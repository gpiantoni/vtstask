function fmri_trigger(serialport, logfile, message)
% Pauses the program until a trigger is received from the serialport.

if nargin < 2 || ~ischar(message) 
    message = 'trigger';
end
disp('Waiting for trigger from scanner...')

while 1
    %To know the trigger number the serialport is sending
    %disp(fread(serialport, 1))
    if fread(serialport, 1) == 49
        logger(logfile, message);
        break
    end
end