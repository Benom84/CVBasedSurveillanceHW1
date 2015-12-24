function BoundingBoxes = CalculateBB( FoundBB, PredictedBB)
%CalculateBB (FoundBB, PredictedBB) - For each BB that we found and have a
%prediction for we create an average based on a ratio. For BB that appears
%in one case we add but increase the weakness factor

AverageRatio = 0.6;
BoundingBoxes = zeros(size(FoundBB), 'int32');

% Add all the found BB.
for i = 1 : size(FoundBB, 1)
    currFoundBB = FoundBB(i,:);
    currPredictedBB = PredictedBB(PredictedBB(:,6) == currFoundBB(6),:);
    if (size(currPredictedBB, 1) > 0)
        PredictedBB(PredictedBB(:,6) == currFoundBB(6),:) = [];
        averagedBB = int32(floor(currFoundBB(1:4) * AverageRatio)) + ...
            int32(floor(currPredictedBB(1:4) * (1 - AverageRatio)));
        BoundingBoxes(i,1:4) = averagedBB;
        BoundingBoxes(i,5) = 0;
        BoundingBoxes(i,6) = currPredictedBB(6);
    else
        BoundingBoxes(i,:) = currFoundBB;
        BoundingBoxes(i,5) = 1;
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

