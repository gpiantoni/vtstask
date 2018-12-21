

random_timing = [14.4 + timing_stim_random(1)-.2];
seq_timing = [14.4 + timing_stim_sequential(1)];

for i = 2:length(timing_stim_random)
    if mod(i-1, 5) == 0 && i ~= length(timing_stim_random)
        random_timing = [random_timing 14.4+timing_stim_random(i)];
        continue
    end
    random_timing = [random_timing (timing_stim_random(i)+ 4.8)];
end

for i = 2:length(timing_stim_sequential)
    if mod(i-1, 10) == 0 && i ~= length(timing_stim_sequential)
        seq_timing = [seq_timing 14.4+timing_stim_sequential(i)+.2];
        continue
    end
    seq_timing = [seq_timing (timing_stim_sequential(i)+ 4.8 +.2)];
end

random_stimulation = [round(random_timing(1),2)];
i=2;
while i < length(random_timing)-5
    random_stimulation = [random_stimulation round(sum(random_timing(1:i+4)),2)];
    i=i+5;
end

durrand=[]; 
for i = 1:length(random_stimulation)
    if i ~= length(random_stimulation)
       durrand = [durrand random_stimulation(i+1) - random_stimulation(i)];
    end
end
meandurrand = round(mean(durrand), 2);

actual_timing_rand = [round(random_timing(1))];
for i = 2:length(random_stimulation)+1
    actual_timing_rand = [actual_timing_rand actual_timing_rand(i-1)+meandurrand];
end

actual_timing_rand = [actual_timing_rand,0 , meandurrand];
dlmwrite('stimulation_random_pilot', actual_timing_rand, '\n')

seq_stimulation = [round(seq_timing(1),2)];
i=2;
while i < length(seq_timing)-11
    seq_stimulation = [seq_stimulation round(sum(seq_timing(1:i+9)),2)];
    i=i+10;
end

dur=[]; 
for i = 1:length(seq_stimulation)
    if i ~= length(seq_stimulation)
       dur = [dur seq_stimulation(i+1) - seq_stimulation(i)];
    end
end
meandurseq = round(mean(dur), 2);

actual_timing_seq = [round(seq_timing(1))];
for i = 2:length(seq_stimulation)
    actual_timing_seq = [actual_timing_seq actual_timing_seq(i-1)+meandurseq];
end

actual_timing_seq = [actual_timing_seq, 0, meandurseq];
dlmwrite('stimulation_sequential_pilot', actual_timing_seq, '\n')
    