function seqMat = createSeqMat(nrOutputs, blocks, reversed)

switch nargin
    case 2
        reversed = 0;
end

seqMat = [];
for i = 1:blocks
    order = [];
    if ~reversed
        for output = 1:nrOutputs
            order = [order, output];
        end
    else
        for output = 1:nrOutputs
            order = [order, (nrOutputs+1)-output];
        end
    end
    seqMat = [seqMat;order];
    reversed = ~reversed;
end
end