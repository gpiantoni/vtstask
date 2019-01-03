function logger(logfile, logmessage, display)

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