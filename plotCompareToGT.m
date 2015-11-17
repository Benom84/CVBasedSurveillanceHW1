function [FalsePositives,FalseNegatives] = plotCompareToGT(actualBinMatrix, expectedBinMatrix)
%The function runs through all the frames, and plots on a graph the
%falsePositives and falseNegatives, as function of time (= frames)

matSize = size(actualBinMatrix);
framesNum = matSize(4);

comparisonData = zeros(framesNum,6);

for i = 1:framesNum
    actual = actualBinMatrix(:,:,i);
    expected = expectedBinMatrix(:,:,i);
    
    %[truePosRate, trueNegRate, Precision, NPV, FPR, FNR]
    comparisonData(i) = compareResults2GroundTruth(actual, expected);
end

FalsePositives = comparisonData(:,5);
FalseNegatives = comparisonData(:,6);
plot(1:framesNum, FalsePositives);

end

