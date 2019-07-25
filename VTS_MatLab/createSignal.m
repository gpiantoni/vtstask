function signal = createSignal(frequency, amplitude, on_duration, off_duration, reps)
% Function creating the signal for the experiments. This signal is
% subsequently used to generate a stimulation matrix. It requires the
% following parameters:
% - frequency = vibrational frequency of the stimulus
% - amplitude = amplitude of the stimulus
% - on_duration = time the stimulation is on
% - off_duration = time the stimulation is off. A continuous stimulus means
%                   off_duration = 0. 
% - reps = how many times the on/off duration should be repeated. As an
%           example, if you want a stimulus of 4 seconds where the stimulus
%           is on for .4s and off for .1 you need reps = 8. 

switch nargin
    case 3
        off_duration = 0;
        reps = 1;
    case 4
        reps = 1;
end
signal = [];
values = linspace(0,2*pi * frequency *on_duration,...
    on_duration*1000)';
signal_on = amplitude.*sin(values);
signal_off = zeros(off_duration*1000, 1);

for rep = 1:reps
        signal = [signal;signal_on;signal_off];
end

end