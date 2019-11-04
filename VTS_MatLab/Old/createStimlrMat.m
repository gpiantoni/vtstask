function stimlrMat = createStimlrMat(nrOutputs, signal, onsets, outputlist, serialport)
% Function that creates a stimulation matrix for the left to right (and vice versa) 
%wave experiment. 
% It requires the following parameters:
% - nrOutputs = number of outputs that are used
% - signal = the stimulation signal used in the experiment
% - onsets = list describing the onsets of stimulations
% - outputlist = array of which outputs need to be used at each onset
% - serialport = not yet used...

switch nargin
    case 4
        serialport = 0;
end

% declare variables
stimlrMat = [];
stimdur = length(signal)/1000;


for n_onsets = 1:length(onsets)
    
    onset = onsets(n_onsets);  
    outputs = outputlist(n_onsets, :);

    if n_onsets == 1
        rest_output = zeros((onset + stimdur)*1000,1);
        stim_output = zeros(onset*1000, 1);

    else
        tbs =int64((onsets(n_onsets) - onsets(n_onsets-1) - stimdur) *1000);
        stim_output = zeros(tbs, 1);
        
        resting_output = int64((onsets(n_onsets) - onsets(n_onsets-1)) *1000);
        rest_output = zeros(resting_output, 1);
    end

    part_of_task = [];
    for nr_Output = 1:nrOutputs   
        if any(nr_Output == outputs) %CHECKKK  
            part_of_task(:, nr_Output) = [stim_output; signal];
        else
            part_of_task(:, nr_Output) = rest_output;
        end
    end
  stimlrMat = [stimlrMat; part_of_task];
end   

end
