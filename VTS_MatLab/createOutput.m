function output = createOutput(signal, pTime, reps)

switch nargin
    case 2
        reps = 1;
end
       
output = [];
pausetime = zeros(pTime*1000, 1);
for rep = 1:reps
        output = [output;signal;pausetime];
end
    
end
