function matchRatio = BBMatchRatio( BB1NormHist, BB2NormHist )
%BBMATCHRATIO ( BB1NormHist, BB2NormHist ) Calculate the match ratio
%between two normalized histograms of bounding boxes in a frame

SSDWeight = 0.2;
angleWeight = 0.4;
BhattaWeight = 1 - angleWeight - SSDWeight;

SSD = 1 - norm(BB1NormHist - BB2NormHist);
angleBetweenBB = sum(BB1NormHist .* BB2NormHist);
BB1NormHistSum1 = BB1NormHist / sum(BB1NormHist);
BB1NormHistSum2 = BB2NormHist / sum(BB2NormHist);
Bhattacharyya = sum(sqrt(BB1NormHistSum1) .* sqrt(BB1NormHistSum2));


matchRatio = SSD * SSDWeight + angleBetweenBB * angleWeight + Bhattacharyya * BhattaWeight;

end

