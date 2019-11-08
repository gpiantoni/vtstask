function stimMat = createStimMat(nrOutputs, onsets, outputlist, frequency,... 
amplitude, ondur, offdur, stimduration, serialport)
% Function that creates a stimulation matrix for the left to right (and vice versa) 
%wave experiment. 
% It requires the following parameters:
% - nrOutputs = number of outputs that are used
% - amplitude = list describing the amplitude per onset
% - frequency = list describing frequency per onset 
% - signal = one row corresponds to one onset and consists of: ondur,
% offdur, stimdur
% - onsets = list describing the onsets of stimulations
% - outputlist = array of which outputs need to be used at each onset
% - serialport = not yet used...

switch nargin
    case 8
        serialport = 0;
end

%% make signal matrix for all outputs
%
%stimduration = stimdur;
%nrOutputs = 2;
stimMat = [];
for n = 1:length(onsets)
    onset = onsets(n); 
    output_char = outputlist{n};
    outputs = str2num(output_char);

    %make signal for specific onset
    freq = double(frequency(n));
    ampl = double(amplitude(n)); 
    on = ondur(n);
    off = offdur(n); 
    stimdur = stimduration(n); 
    reps = round(stimdur/(on + off));
    signal = createSignal(freq, ampl, on, off, reps); %you need function createSignal.m
    
    if n == 1
        rest = zeros((onset + stimdur)*1000,1);
        stim = zeros(onset*1000, 1);

    else
        tbs =int64((onset - onsets(n-1)- stimdur) *1000);
        stim = zeros(tbs, 1);
        
        rest_time = int64((onset - onsets(n-1)) *1000);
        rest = zeros(rest_time, 1);
    end
    
    if n ~= 1 && ((onset - onsets(n-1)) < stimdur)
          for n_out = 1:nrOutputs 
            if any(n_out == outputs) 
                sig = signal;
                stimMat = [stimMat; zeros((int64(((onset - onsets(n-1)))*1000)),nrOutputs)];
                stimMat(int64((onset*1000)+1):int64((onset+stimdur)*1000),n_out)= sig;
            end
          end

    else
    part = [];
    for n_out = 1:nrOutputs 
        if any(n_out == outputs) 
            part(:, n_out) = [stim; signal];
        else
            part(:, n_out) = rest;
        end
    end   
        stimMat = [stimMat; part];
    end
end
end
