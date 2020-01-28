fname = 'design_ecog_pretest.txt';
file = fopen(fname);
cells = textscan(file, '%f %s %d %d %f %f %f', ...
    'delimiter', ';', 'headerlines', 10);
outputlist = cells{2};
onsets = cell2mat(cells(1))';
stimdur = cell2mat(cells(7))';
last_stimdur = stimdur(length(stimdur));
fclose(file);

PORT_OUT_ECOG = "COM13"; 

sp_out = serial(PORT_OUT_ECOG);
fopen(sp_out);

begin_task = 100;
disp(begin_task)
fprintf(sp_out, '%c', begin_task);

ecog_trigger(onsets, outputlist, last_stimdur, sp_out);

fclose(sp_out);