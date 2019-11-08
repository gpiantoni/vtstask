j = 17; %change according to which stimulator you want to find out
stimOutput = stimMat(:,j);

rows_stim = [];
for i = 1:length(stimMat)
    if stimOutput(i) ~= 0
    rows_stim = [rows_stim i];
    end
end