function logger(logfile, logmessage, display)
% Logs to the logfile. Needs following parameters:
% - logfile = path to logfile
% - logmessage = message that should be logged
% - display = binary value, 1 indicating message should be displayed on the
%               command line and 0 meaning it should not. 

if nargin < 3
    display = 1;
end

if ~ischar(logmessage)
    error('message is not a string')
end

if display
    disp(logmessage);
end

fprintf(logfile, '%s: %s\n', datestr(now), logmessage);