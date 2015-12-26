function result = AssociateToExistingBBHistogram( foundBB, existingBB, colorRange, existingFrame, currentFrame, bins)
%ASSOCIATETOEXISTINGBB associate found BB to existing BB by finding the
%existing BB with the max histogram matching. If no existing BB fits then
%the found BB is colored in a new color
% AssociateToExistingBBHistogram( foundBB, existingBB, colorRange, existingFrame, currentFrame )
availableColors = 1 : colorRange;
availableColors(ismember(availableColors, existingBB(:,6))) = [];
coloredFoundBB = zeros([size(foundBB, 1) 6], 'int32');
coloredFoundBB(:,1:4) = foundBB(:,1:4);
for i = 1 : size(coloredFoundBB, 1)
    currColFoundBB = coloredFoundBB(i,:);
    currFoundBBNormHist = NormalizedHistogramBB(currColFoundBB, currentFrame, bins);
    maxMatchRatio = 0;
    matchIndex = -1;
    for j = 1 : size(existingBB, 1)
        currExistingBB = existingBB(j,:);
        currExistingBBNormHist = NormalizedHistogramBB(currExistingBB, existingFrame, bins);
        matchRatio = BBMatchRatio(currFoundBBNormHist, currExistingBBNormHist);
        if (matchRatio > maxMatchRatio)
            matchIndex = j;
            maxMatchRatio = matchRatio;
        end
    end
    
    if (matchIndex == -1)
        coloredFoundBB(i,6) = availableColors(1);
        availableColors(1) = [];
    else
        coloredFoundBB(i,6) = existingBB(matchIndex,6);
    end
end

result = coloredFoundBB;

% Unite BB with same index
if (size(coloredFoundBB, 1) > 0)
    maxColorIndex = max(coloredFoundBB(:,6));
    
    for i = 1 : maxColorIndex
        sameColorBB = coloredFoundBB(coloredFoundBB(:,6) == i, :);
        numberOfItems = size(sameColorBB);
        % If there is more than 1 BB we will check for the best fit
        if (numberOfItems > 1)
            coloredFoundBB(coloredFoundBB(:,6) == i, :) = [];
            unitedColoredBB = UniteOverlappingBB(sameColorBB);
            if (size(unitedColoredBB, 1) > 1)
                maxRatio = 0;
                maxRatioIndex = 1;
                comparedBB = existingBB(existingBB(:,6) == i, :);
                for j = 1 : size(unitedColoredBB, 1)
                    currentRatio = BBOverlapRatio(unitedColoredBB(j,:), comparedBB);
                    if (currentRatio > maxRatio)
                        maxRatioIndex = j;
                        maxRatio = currentRatio;
                    end
                end
                bestResult = unitedColoredBB(maxRatioIndex,:);
                unitedColoredBB(maxRatioIndex,:) = [];
                coloredFoundBB = vertcat(coloredFoundBB, bestResult);
                unmatchedExistingBB = existingBB(~ismember(existingBB(:,6), coloredFoundBB(:,6)),:);
                for j = 1 : size(unitedColoredBB, 1)
                    unitedColoredBB(j, 6) = -1;
                    maxRatioOverlap = 0;
                    for k = 1 : size(unmatchedExistingBB,1)
                        ratioOverlap = BBOverlapRatio(unmatchedExistingBB(k,:), unitedColoredBB(j, :));
                        if (ratioOverlap > maxRatioOverlap)
                            unitedColoredBB(j, 6) = unmatchedExistingBB(k, 6);
                            unmatchedExistingBB(k, 6) = -1;
                            maxRatioOverlap = ratioOverlap;
                        end
                    end
                    if (unitedColoredBB(j, 6) == -1)
                        unitedColoredBB(j, 6) = availableColors(1);
                        availableColors(1) = [];
                    end
                end
            end
            coloredFoundBB = vertcat(coloredFoundBB, unitedColoredBB);
        end
        
    end
    
    
    result = coloredFoundBB;
end
end

