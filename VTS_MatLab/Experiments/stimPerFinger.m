function stimPerFinger(session, outputSignal, nrOutputs, serialport, fingers, pTime)
% Function that stimulates all outputs per finger
% 
% - session: DAQ session
% - outputSignal: The output signal
% - nrOutput: Number of stimulators
% - serialport: Serial port
% - fingers: Number of fingers to be stimulated (default=5)
% - pTime: Pause between stimulation

switch nargin
    case 3
        serialport = 0;
        fingers = 5;
        pTime = 0;
    case 4
        fingers = 5;
        pTime = 0;
    case 5
        pTime = 0;
end

lenOutSig = length(outputSignal);

if mod(nrOutputs, fingers)==0
    for i = 1:fingers %iteration per finger
        out = 0;
        allOutputs = zeros(lenOutSig, nrOutputs);
        while out < nrOutputs
            loc = out + i;
            allOutputs(:, loc) = outputSignal;
            out = out + fingers;
        end
        queueOutputData(session, repmat(allOutputs, 1, 1));
        disp(strcat('stimulating finger ', int2str(i)));
        
        % send signal through serial port if available
        if serialport ~= 0
            fprintf(serialport, '%c', 30 + i);
        end
        % stimulate
        session.startForeground;
        if serialport ~= 0
            fprintf(serialport, '%c', 150);
        end
        pause(pTime);
    end
    
    for i = 0:fingers-1 %iteration per finger
        allOutputs = zeros(lenOutSig, nrOutputs);
        out = fingers;
        while out <= nrOutputs
            loc = out - i;
            allOutputs(:, loc) = outputSignal;
            out = out + fingers;
        end
        queueOutputData(session, repmat(allOutputs, 1, 1));
        disp(strcat('stimulating finger ', int2str(i)));
        
        % send signal through serial port if available
        if serialport ~= 0
            fprintf(serialport, '%c', 30 + i);
        end
        % stimulate
        session.startForeground;
        if serialport ~= 0
            fprintf(serialport, '%c', 150);
        end
        pause(pTime);
    end
else
    msg = 'Number of outputs is not divisible by number of fingers';
    disp(msg);
end