function signal = createSignal(frequency, amplitude, duration)
values = linspace(0,2*pi * frequency *duration,...
    duration*1000)';
signal = amplitude.*sin(values);
end