function randMat = createRandMat(nrOutputs, reps)
nrOutputs = 5;
reps = 8;
prev = 0;
fingmat = zeros(nrOutputs, 1);
mat = [];
i = 1; 
while i <= nrOutputs*reps
    finger  = randi(nrOutputs);
    if finger == prev
        continue
    elseif fingmat(finger)>=reps
        continue
    else
        mat = [mat finger];
        fingmat(finger) = fingmat(finger) + 1;
        i = i+1;     
        prev = finger;
    end
end

randMat = int32(transpose(reshape(mat, [nrOutputs, reps])));
rfile = fopen('randmaaat.txt', 'w');
fwrite(rfile, randMat, 'integer*1');
fclose(rfile)
% mat3 = createStimFingMat(nrOutputs, sig, mat2);