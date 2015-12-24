function weakness = CheckWeakness( WeakBB, BB )
%CHECKWEAKNESS Summary of this function goes here
%   Detailed explanation goes here

weakness = 0;
if (isempty(WeakBB))
    return;
end



for i = 1 : size(WeakBB, 1)
    currWeakBB = WeakBB(i, :);
    if (BoundingBoxOverlap(currWeakBB, BB))
        weakness = currWeakBB(6);
        return;
    end
end

end

