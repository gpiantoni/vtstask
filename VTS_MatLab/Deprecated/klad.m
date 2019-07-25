% nrOutputs = 5;
% pMat = zeros(nrOutputs, 1);
% p = 1/nrOutputs;
% pMat (:,1) = p;
% fingmat = zeros(nrOutputs, 1);
% reps = 2;
% minval = p/reps;
% stims = reps*nrOutputs;
% fingleft = nrOutputs;
% %%
% for rep = 1:reps
%     for i = 1:nrOutputs
%         x = rand;
%         if x < sum(pMat(1:1))
%             fing = 1;
%         elseif x < sum(pMat(1:2))
%             fing = 2;
%         elseif x < sum(pMat(1:3))
%             fing = 3;
%         elseif x < sum(pMat(1:4))
%             fing = 4;
%         elseif x < 1
%             fing = 5;
%         end
%         disp(fing);
%         pMat(fing) = pMat(fing) - minval;
%         fingmat(fing) = fingmat(fing) + 1;
%         
%         for output = 1:nrOutputs
%             if output ~= fing && fingmat(output)<reps
%                 plusval = pMat(output)+minval/(fingleft-1);
%                 pMat(output) = plusval;
%             end
%         end
%         if fingmat(fing) == reps
%             fingleft = fingleft-1;
%         end
%         
%         minval = 1/(stims-(((rep-1)*nrOutputs)+i))
%         disp(pMat)
%         disp(sum(pMat))
%     end   
% end
% 

sp_out = serial("COM6");
fopen(sp_out);
for i = 1:10
    fprintf(sp_out, '%c', 20);
    pause(2)
end
fclose(sp_out);