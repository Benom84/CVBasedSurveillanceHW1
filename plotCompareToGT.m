function [fprs, fnrs] = plotNaiveGT(resultVideo, gtVideo)
%Given a binary video and its grount-truth, will plot a graph of FPRs and
%FNRs as function of the frames progress.


framesNum = size(resultVideo,3);

fprs = zeros(framesNum);
fnrs = zeros(framesNum);

for i=1 : framesNum
    [~, ~, ~, ~, fpr, fnr] = compareResults2GroundTruth(resultVideo(:,:,i), gtVideo(:,:,i));
    fprs(i) = fpr;
    fnrs(i) = fnr;
end

plot(1:framesNum, fprs, 1:framesNum, fnrs);

end

