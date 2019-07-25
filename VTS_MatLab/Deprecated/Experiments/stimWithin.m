function stimWithin(session, outputSignal, nrOutputs, serialport, fingers, pTime)
% Function that stimulates the individual outputs per finger 
% 
% - session: DAQ session
% - outputSignal: The output signal
% - nrOutput: Number of stimulators
% - serialport: Serial port
% - fingers: Number of fingers to be stimulated (default=5)
% - pTime: Pause between stimulation (default= 200 ms)

switch nargin
    case 3
        serialport = 0;
        fingers = 5;
        pTime = .2;
    case 4
        fingers = 5;
        pTime = .2;
    case 5
        pTime = .2;
end

lenOutSig = length(outputSignal);

if mod(nrOutputs, fingers)==0
    for i = 1:fingers %iteration per finger
        out = 0;
        while out < nrOutputs
            allOutputs = zeros(lenOutSig, nrOutputs);
            loc = out + i;
            disp(strcat('stimulator nr. ', int2str(loc)));
            allOutputs(:, loc) = outputSignal;
            queueOutputData(session, repmat(allOutputs, 1, 1));
            
            % send signal through serial port if available
            if serialport ~= 0
                fprintf(serialport, '%c', 40 + loc);
            end
            % stimulate
            session.startForeground;
            if serialport ~= 0
                fprintf(serialport, '%c', 150);
            end
            out = out + fingers;
            pause(pTime);
        end
        out = 0; % reset out to run in opposite direction
        while out < nrOutputs
            allOutputs = zeros(lenOutSig, nrOutputs);
            loc = loc - out;
            disp(strcat('stimulator nr. ', int2str(loc)));
            allOutputs(:, loc) = outputSignal;
            queueOutputData(session, repmat(allOutputs, 1, 1));
            
            % send signal through serial port if available
            if serialport ~= 0
                fprintf(serialport, '%c', 40 + loc);
            end
            % stimulate
            session.startForeground;
            if serialport ~= 0
                fprintf(serialport, '%c', 150);
            end
            out = out + fingers;
            pause(pTime);
        end
    end
else
    msg = 'Number of outputs is not divisible by number of fingers';
    error(msg);
end