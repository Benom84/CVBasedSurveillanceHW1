function matchRatio = BBMatchRatio( BB1NormHist, BB2NormHist )
%BBMATCHRATIO ( BB1NormHist, BB2NormHist ) Calculate the match ratio
%between two normalized histograms of bounding boxes in a frame

SSDWeight = 0.4;
angleWeight = 0.6;
BhattaWeight = 1 - angleWeight - SSDWeight;

SSD = 1 - norm(BB1NormHist - BB2NormHist);
angleBetweenBB = sum(BB1NormHist .* BB2NormHist);
Bhattacharyya = sum(sqrt(BB1NormHist) .* sqrt(BB2NormHist));


matchRatio = SSD * SSDWeight + angleBetweenBB * angleWeight + Bhattacharyya * BhattaWeight;

end

