function result = UniteOverlappingBB( coloredBB )
%UniteOverlappingBB( coloredBB ) Unit BB with high overlapping under the
%premise that it is noise

threshold = 0.05;

for i = 1 : size(coloredBB, 1)
    currentBB = coloredBB(i,:);
    for j = i + 1: size(coloredBB, 1)
        checkedBB = coloredBB(j, :);
        overlapRatio = BBOverlapRatio(currentBB, checkedBB);
        if (overlapRatio > threshold)
            minX = min(currentBB(1), checkedBB(1));
            minY = min(currentBB(2), checkedBB(2));

            xLength = max(currentBB(1) + currentBB(3), checkedBB(1) + checkedBB(3)) - minX;
            yLength = max(currentBB(2) + currentBB(4), checkedBB(2) + checkedBB(4)) - minY;
            
            currentBB = [minX minY xLength yLength currentBB(5) currentBB(6)];
            coloredBB(j,:) = [0 0 0 0 0 -1];
        end
    end
    coloredBB(i,:) = currentBB;
end
coloredBB = coloredBB(coloredBB(:,6) ~= -1, :);
result = coloredBB;

end

