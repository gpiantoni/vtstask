function signal = createSignal(frequency, amplitude, on_duration, off_duration, reps)
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