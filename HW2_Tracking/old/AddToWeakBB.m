function WeakBB = AddToWeakBB( oldWeakBB, BB )
%ADDTOWEAKBB Summary of this function goes here
%   Detailed explanation goes here
WeakBB = oldWeakBB;
if isempty(oldWeakBB)
    WeakBB(1,:) = [BB(1:5) 1];
    return;
end

sameIndexBB = oldWeakBB(oldWeakBB(:,5) == BB(5),:);

%If the BB exists in the matrix
if ~isempty(sameIndexBB) 
    for i = 1 : size(sameIndexBB, 1)
        sameIndexToCheck = sameIndexBB(i,:);
        if (BoundingBoxOverlap(sameIndexToCheck, BB))
            oldWeakBB(oldWeakBB(:,5) == BB(5),:) = [BB(1:5) sameIndexToCheck(6) + 1];
            WeakBB = oldWeakBB;
            return;
        end
    end
else
    % Check all the bounding boxes
    for i = 1 : size(oldWeakBB, 1)
        BBtoCheck = oldWeakBB(i, :);
        if (BoundingBoxOverlap(BBtoCheck, BB))
            oldWeakBB(i, :) = [BB(1:5) BBtoCheck(6) + 1];
            WeakBB = oldWeakBB;
            return;
        end
    end
    
    oldWeakBB(size(oldWeakBB, 1) + 1,:) = [BB(1:5) 1];
    WeakBB = oldWeakBB;
end

