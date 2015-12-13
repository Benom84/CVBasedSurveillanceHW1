function result = ColoredBoundingBoxes(BoundingBoxes, ColorsMatrix, oldBoundingBoxesWithColors)
%COLOREDBOUNDINGBOXES Summary of this function goes here
%   Detailed explanation goes here

BoundingBoxesWithColors = zeros(size(BoundingBoxes, 1), 5);

if (nargin <= 2)
    for i= 1:size(BoundingBoxes, 1)
        BoundingBoxesWithColors(i,:) = horzcat(BoundingBoxes(i,:), i);
    end
else
    for i= 1:size(BoundingBoxes, 1)
        colorIndex = -1;
        %If there exist an overlapping bbox in the prev we use it color
        for j = 1:size(oldBoundingBoxesWithColors, 1)
            comparedBoundingBox = oldBoundingBoxesWithColors(j, 1:4);
            if (BoundingBoxOverlap(BoundingBoxes(i,:), comparedBoundingBox) == 1)
                colorIndex = oldBoundingBoxesWithColors(j, 5);
            end
        end
        BoundingBoxesWithColors(i,:) = horzcat(BoundingBoxes(i,:), colorIndex);
    end
    AllColorsIndices = (1 : size(ColorsMatrix, 1));
    UsedColors =  BoundingBoxesWithColors(:,5)';
    UsedColors = UsedColors(UsedColors~=-1);
    AvailableColors = AllColorsIndices(setdiff(1:length(AllColorsIndices),UsedColors));
    % Add color to uncolored bounding boxes
    for i= 1:size(BoundingBoxesWithColors, 1)
        if (BoundingBoxesWithColors(i, 5) == -1)
            colorIndex = AvailableColors(1);
            AvailableColors(1) = [];
            BoundingBoxesWithColors(i, :) = horzcat(BoundingBoxesWithColors(i, 1:4), colorIndex);
        end
    end
    
    %Make sure there are no duplicate colors
    MaxColorIndex = max(BoundingBoxesWithColors(:, 5));
    for currentColorIndex = 1 : MaxColorIndex
        numberOfSimilarColorBoxes = ...
            size(BoundingBoxesWithColors(BoundingBoxesWithColors(:,5) == currentColorIndex,:), 1);
        if numberOfSimilarColorBoxes > 1
            for bboxIndex = 2: size(BoundingBoxesWithColors, 1)
                if (BoundingBoxesWithColors(bboxIndex, 5) == currentColorIndex)
                    colorIndex = AvailableColors(1);
                    AvailableColors(1) = [];
                    BoundingBoxesWithColors(bboxIndex, :) = ...
                        horzcat(BoundingBoxesWithColors(i, 1:4), colorIndex);
                end
            end
        end
    end
        
end

result = BoundingBoxesWithColors;


end

