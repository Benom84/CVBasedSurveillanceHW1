function result = AssociateToExistingBB( foundBB, existingBB, colorRange )
%ASSOCIATETOEXISTINGBB associate found BB to existing BB by finding the
%existing BB with the max overlapping ratio. If no existing BB fits then
%the found BB is colored in a new color
%   AssociateToExistingBB( foundBB, existingBB, colorRange )
availableColors = 1 : colorRange;
availableColors(ismember(availableColors, existingBB(:,6))) = [];
coloredFoundBB = zeros([size(foundBB, 1) 6], 'int32');
coloredFoundBB(:,1:4) = foundBB(:,1:4);
for i = 1 : size(coloredFoundBB, 1)
    currColFoundBB = coloredFoundBB(i,:);
    maxOverlapRatio = 0;
    for j = 1 : size(existingBB, 1)
        currExistingBB = existingBB(j,:);
        overlapRatio = BBOverlapRatio(currColFoundBB, currExistingBB);
        if (overlapRatio > maxOverlapRatio)
            coloredFoundBB(i,6) = existingBB(j,6);
            maxOverlapRatio = overlapRatio;
        end
    end
    if (coloredFoundBB(i,6) == 0)
        coloredFoundBB(i,6) = availableColors(1);
        availableColors(1) = [];
    end
end

result = coloredFoundBB;

% Unite BB with same index
if (size(coloredFoundBB, 1) > 0)
    maxColorIndex = max(coloredFoundBB(:,6));
    
    for i = 1 : maxColorIndex
        sameColorBB = coloredFoundBB(coloredFoundBB(:,6) == i, :);
        numberOfItems = size(sameColorBB);
        if (numberOfItems > 1)
            coloredFoundBB(coloredFoundBB(:,6) == i, :) = [];
            unitedColoredBB = UniteOverlappingBB(sameColorBB);
            if (size(unitedColoredBB, 1) > 1)
                for j = 2 : size(unitedColoredBB, 1)
                    unitedColoredBB(j, 6) = availableColors(1);
                    availableColors(1) = [];
                end
            end
            coloredFoundBB = vertcat(coloredFoundBB, unitedColoredBB);
        end
        
        
        result = coloredFoundBB;
    end
end

