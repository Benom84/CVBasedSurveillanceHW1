
function [truePosRate, trueNegRate, falsePosRate, falseNegRate] = compareResults2GroundTruth(forBackResultIm, groundTruthIm)
% Compare a binary result image to a ground truth image from dataset
% www.changedetection.net
% Input: forBackResultIm - a binary result image, where 1 represents
%        foreground and 0 represents background
%    	 groundTruthIm - a ground truth image from the dataset
%    	 www.changedetection.net. Multiple foreground values are possible,
%    	 but we keep only the "real" foreground objects (value 255)
% Output: truePosRate - true positives rate (TPR = true positives / (true positives + false negatives), 0 to 1)
%         trueNegRate - true negatives rate (TNR = true negatives / (true negatives + false positives), 0 to 1)
%        Precision rate (Precision = true positive / (false positives + true positive), 0 to 1)
%        negative predictive value  -  (NPV= true negatives / (false negatives + true negative), 0 to 1)
    
    % get only the real foreground from ground truth
    realGroundTruthIm = (groundTruthIm == 255);
    sumGroundTruthPos = sum(sum(realGroundTruthIm == 1));
    sumGroundTruthNeg = sum(sum(realGroundTruthIm == 0));
    % get all entries with both 1
    truePosRate = sum(sum(forBackResultIm.*realGroundTruthIm))./sumGroundTruthPos;
    % get all entries with both 0
    trueNegRate = sum(sum((~forBackResultIm).*(~realGroundTruthIm)))./sumGroundTruthNeg;
    % get all entries with forBackResultIm == 1 and groundTruthIm == 0
    Precision= sum(sum(forBackResultIm.*(~realGroundTruthIm)))./sum(sum(forBackResultIm==1));
    % get all entries with forBackResultIm == 0 and groundTruthIm == 1
    NPV = sum(sum((~forBackResultIm).*realGroundTruthIm))./sum(sum(forBackResultIm==0));
    
end