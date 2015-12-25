function predictedBoundingBoxes = predictBoundingBox(FromBB, ToBB, ImageBounds)
%PREDICTBOUNDINGBOX Summary of this function goes here
%   Detailed explanation goes here

predictedBoundingBoxes = zeros(size(ToBB), 'int32');
for i = 1 : size(ToBB, 1)
    currToBB = ToBB(i,:);
    currentWeakness = currToBB(5);
    currFromBB = FromBB(FromBB(:,6)==currToBB(6),:);
    
    % If the From and To BB are not on the same region
    if (isempty(currFromBB) || ~BoundingBoxOverlap(currToBB, currFromBB))
        predictedBoundingBoxes(i,:) = currToBB;
        % We add 1 to the weakness
        predictedBoundingBoxes(i,5) = currentWeakness + 1;
    else
        FromBB(FromBB(:,6)==currToBB(6),:) = [];
        centroidFrom = BBToCentroid(currFromBB);
        centroidTo = BBToCentroid(currToBB);
        
        % Calculating the new center
        newCenteroidX = centroidTo(1)*2 - centroidFrom(1);
        newCenteroidY = centroidTo(2)*2 - centroidFrom(2);
        
        % Making sure the quardinates are legal
        newCenteroidX = min(newCenteroidX, ImageBounds(1));
        newCenteroidX = max(newCenteroidX, 1);
        newCenteroidY = min(newCenteroidY, ImageBounds(2));
        newCenteroidY = max(newCenteroidY, 1);
        
        % Calculating the new size
        newXsize = currToBB(3)*2 - currFromBB(3);
        newYsize = currToBB(4)*2 - currFromBB(4);
        
        % Calculate the left upper corner of the box
        newXpos = newCenteroidX - floor(newXsize / 2);
        newYpos = newCenteroidY - floor(newYsize / 2);
        
        % Check the bounding box do not exceed the image
        newXpos = max(newXpos, 1);
        newYpos = max(newYpos, 1);
        if (newXpos + newXsize) > ImageBounds(1)
            newXsize = ImageBounds(1) - newXpos;
        end
        if (newYpos + newYsize) > ImageBounds(2)
            newYsize = ImageBounds(2) - newYpos;
        end
        
        % If the size is not illegal we add the prediction
        if (newXsize > 0) && (newYsize > 0)
            predictedBoundingBoxes(i,:) = [newXpos newYpos newXsize newYsize currentWeakness currToBB(6)];
        else
            % Indicates that the motion tells us the object is out of sight
            predictedBoundingBoxes(i,:) = [newXpos newYpos 1 1 (currentWeakness + 1) currToBB(6)];
        end
    end
end

%Every old BB without a match we add to the history
%threshold
if (size(FromBB, 1) > 0)
    oldBBSize = size(predictedBoundingBoxes, 1);
    for i = 1 : size(FromBB, 1)
        oldBBSize = oldBBSize + 1;
        predictedBoundingBoxes(oldBBSize,:) = FromBB(i, :);
        predictedBoundingBoxes(oldBBSize,5) = FromBB(i, 5) + 1;
    end
    
end

