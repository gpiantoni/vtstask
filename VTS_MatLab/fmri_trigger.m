function fmri_trigger(serialport, message)

if nargin < 2 || ~ischar(message) 
    message = 'trigger';
end
disp('Waiting for trigger from scanner...')

while 1
    if fread(serialport, 1) ==49
        disp(message);
        break
    end
end