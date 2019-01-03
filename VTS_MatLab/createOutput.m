function output = createOutput(frequency, amplitude, signalTime, pTime, reps)

switch nargin
    case 4
        reps = 1;
end
       
output = [];
stim = createSignal(frequency, amplitude, signalTime);
pausetime = zeros(pTime*1000, 1);
for rep = 1:reps
    for fing = 1:5
        output = [output;stim;pausetime];
    end
end
    
end
