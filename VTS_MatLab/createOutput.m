function output = createOutput(frequency, amplitude, restdur, pTime, signalTime, reps)

switch nargin
    case 5
        reps = 1;
end
       
output = [];
rest =  zeros(restdur*1000, 1);
stim = createSignal(frequency, amplitude, signalTime);
pausetime = zeros(pTime*1000, 1);
for rep = 1:reps
    output = [output;rest];
    for fing = 1:5
        output = [output;stim;pausetime];
    end
end
    
end
