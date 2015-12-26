function result = track_nbs4(VideoMat, BlobSize, VideoMatBinary, usePrediction)

MatDim = size(VideoMat);
result = zeros(MatDim(1), MatDim(2), MatDim(3), MatDim(4), 'int32');

blobAnalyzer = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', true, 'CentroidOutputPort', true, ...
    'MinimumBlobArea', BlobSize);

fprintf('Drawing rectangels\n');
ColorsMatrix = [unique(perms([0 0 255]), 'rows'); unique(perms([0 255 255]), 'rows'); [255 255 255]; unique(perms([127 0 0]), 'rows');...
    unique(perms([127 127 0]), 'rows');[127 127 127];unique(perms([50 100 200]),...
    'rows');unique(perms([25 50 100]), 'rows');unique(perms([25 75 200]), 'rows');];

trackedBBNormalizedHist = zeros([size(ColorsMatrix, 1) 48], 'double');

[~, ~, currentFoundBB] = blobAnalyzer.step(VideoMatBinary(:,:,1));
FoundColored = ColoredBoundingBoxes(currentFoundBB, ColorsMatrix);
BBHistory1 = zeros([size(FoundColored, 1) 6], 'int32');
BBHistory1(:,1:4) = FoundColored(:,1:4);
BBHistory1(:,6) = FoundColored(:,5);
BBHistory2 = BBHistory1;
imageBounds = [size(VideoMat,2) size(VideoMat,1)];
WeaknessThresholdShow = 10;
WeaknessThresholdDel = 20;
bins = 96;
for i = 1 : MatDim(4)
    [~, ~, currentFoundBB] = blobAnalyzer.step(VideoMatBinary(:,:,i));
    i
    if (i == 350)
        i
    end
    % We will create a new BB representation x,y,sizeX,sizeY,Weakness,Color
    % Predict
    if (usePrediction)
        predictedBB = PredictBB(BBHistory2, BBHistory1, size(ColorsMatrix, 1), imageBounds);
        predictedFrame = VideoMat(:,:,:,i);
    else
        predictedBB = BBHistory1;
        if (i > 1)
            predictedFrame = VideoMat(:,:,:,i - 1);
        else
            predictedFrame = VideoMat(:,:,:,i);
        end;
    end
    currentFrame = VideoMat(:,:,:,i);
    
    coloredCurrentFoundBB = AssociateToExistingBBHistogram(currentFoundBB, predictedBB, size(ColorsMatrix, 1), predictedFrame, currentFrame, bins);
    if (usePrediction)
        calculatedCurrentBB = CalculateBB(coloredCurrentFoundBB, predictedBB);
        calculatedCurrentBB(calculatedCurrentBB(:,5) > WeaknessThresholdDel, :) = [];
    else
        calculatedCurrentBB = coloredCurrentFoundBB;
    end
    BBHistory1(BBHistory1(:,5) > WeaknessThresholdDel - 1, :) = [];
    BBHistory2 = BBHistory1;
    BBHistory1 = calculatedCurrentBB;
    
    for j = 1 : size(calculatedCurrentBB, 1)
        if (calculatedCurrentBB(j,5) < WeaknessThresholdShow)
            
            color = ColorsMatrix(calculatedCurrentBB(j,6), :);
            currentFrame = insertShape(currentFrame, 'Rectangle', calculatedCurrentBB(j,(1 : 4)), 'LineWidth', 2,'color', color);
        end
    end
    result(:,:,:,i) = currentFrame;
    
end
result = uint8(result);

end