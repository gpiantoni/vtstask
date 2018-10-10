function stimSeq(session, outputSignal, nrOutputs, serialport, reversals, pTime)
% Function that stimulates the outputs in sequence
% 
% - session: DAQ session
% - outputSignal: The output signal
% - nrOutputs: Number of stimulators
% - serialport: Serial port
% - reversals: At what point stimulators should vibrate in reverse order
%   (should be a divisor of the nrOutput), will probably be equal to
%   fingers
% - pTime: Pause between stimulation (default= 200 ms)

switch nargin
    case 3
        serialport = 0;
        reversals = nrOutputs;
        pTime = .2;
    case 4
        reversals = nrOutputs;
        pTime = .2;
    case 5
        pTime = .2;
end

lenOutSig = length(outputSignal);
out = 1;
reps = reversals;

if mod(nrOutputs, reversals) == 0
    while reps <= nrOutputs
        for i = out:reps
            allOutputs = zeros(lenOutSig, nrOutputs);
            allOutputs(:, i) = outputSignal;
            queueOutputData(session, repmat(allOutputs, 1, 1));
            disp(strcat('stimulator nr. ', int2str(i)));
            
            % send signal through serial port if available
            if serialport ~= 0 
                fprintf(serialport, '%c', 10 + i);
            end
            % stimulate
            session.startForeground;
            if serialport ~= 0
                fprintf(serialport, '%c', 150);
            end
            pause(pTime);
        end

        for i = 0 : reversals-1
            allOutputs = zeros(lenOutSig, nrOutputs);
            allOutputs(:, reps - i) = outputSignal;
            queueOutputData(session, repmat(allOutputs, 1, 1));
            disp(strcat('stimulator nr. ', int2str(reps-i)));
            
            % send signal through serial port if available
            if serialport ~= 0
                fprintf(serialport, '%c', 10 + reps - i);
            end
            % stimulate
            session.startForeground;
            if serialport ~= 0
                fprintf(serialport, '%c', 150);
            end
            pause(pTime);
        end
        out = out + reversals;
        reps = reps + reversals;
    end
else
    msg = 'Number of outputs is not divisible by number of reversals';
    error(msg);
end