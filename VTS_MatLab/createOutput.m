function output = createOutput(frequency, amplitude, restdur, pTime, signalTime, reps)

switch nargin
    case 5
        reps = 1;
end
       
output = [];
rest = createNoSignal(restdur);
stim = createSignal(frequency, amplitude, signalTime);
pausetime = createNoSignal(pTime);
for rep = 1:reps
    output = [output;rest];
    for fing = 1:5
        output = [output;stim;pausetime];
    end
end
    
end

function signal = createSignal(frequency, amplitude, duration)

values = linspace(0,2*pi * frequency *duration,...
    duration*1000)';
signal = amplitude.*sin(values);
end

function noSignal = createNoSignal(duration)

noSignal = zeros(duration*1000, 1);
end