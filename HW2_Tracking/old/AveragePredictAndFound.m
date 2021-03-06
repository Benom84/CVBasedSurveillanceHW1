function BoundingBoxes = AveragePredictAndFound( FoundBB, PredictedBB)
%AVERAGEPREDICTANDFOUND Summary of this function goes here
%   Detailed explanation goes here
AverageRatio = 0.8;
ColoredFoundBB = zeros([size(FoundBB, 1) 6], 'int32') ;
ColoredFoundBB(:,1:4) = FoundBB;
BoundingBoxes = zeros(size(ColoredFoundBB), 'int32');

% Add all the found BB. If they exist in the predicted color them the same
for i = 1 : size(ColoredFoundBB, 1)
    currFoundBB = ColoredFoundBB(i,:);
    added = 0;
    for j = 1 : size(PredictedBB, 1)
        currPredictedBB = PredictedBB(j,:);
        
        if (BoundingBoxOverlap(currFoundBB, currPredictedBB))
            averagedBB = int32(floor(currFoundBB(1:4) * AverageRatio)) + ...
                int32(floor(currPredictedBB(1:4) * (1 - AverageRatio)));
            BoundingBoxes(i,1:4) = averagedBB;
            BoundingBoxes(i,5) = 0;
            BoundingBoxes(i,6) = currPredictedBB(6);
            PredictedBB(j,:) = [];
            added = 1;
            break;
        end
    end
    if (added == 0)
        BoundingBoxes(i,:) = currFoundBB;
        BoundingBoxes(i,5) = 1;
        BoundingBoxes(i,6) = -1;
    end
end

% Add all the prediction with no match, but add 1 to their weakness
if (size(PredictedBB, 1) > 0)
    oldBBSize = size(BoundingBoxes, 1);
    for i = 1 : size(PredictedBB, 1)
        oldBBSize = oldBBSize + 1;
        BoundingBoxes(oldBBSize, :) = PredictedBB(i, :);
        BoundingBoxes(oldBBSize, 5) = PredictedBB(i, 5) + 1;
    end
end


end

