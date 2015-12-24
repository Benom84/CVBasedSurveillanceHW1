function result = DeleteOverlappingResults(CalculatedCurrentBB)


CalculatedCurrentBB = sortrows(CalculatedCurrentBB,-5);
screenedNewResults = CalculatedCurrentBB;

for i = 1 : size(CalculatedCurrentBB, 1)
    currOldResult = CalculatedCurrentBB(i,:);
    for j = i + 1 : size(CalculatedCurrentBB, 1)
        currNewResult = CalculatedCurrentBB(j,:);
        if (BoundingBoxOverlap(currOldResult, currNewResult))
            screenedNewResults(j,:) = [0 0 0 0 0 0];
        end
    end
end

screenedNewResults = screenedNewResults(screenedNewResults(:,1) > 0,:);
result = screenedNewResults;

end

