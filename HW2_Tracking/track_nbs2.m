function result = track_nbs2(VideoMat, BlobSize, VideoNatBinary)

MatDim = size(VideoMat);
result = zeros(MatDim(1), MatDim(2), MatDim(3), MatDim(4), 'int32');

 blobAnalyzer = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
        'AreaOutputPort', true, 'CentroidOutputPort', true, ...
        'MinimumBlobArea', BlobSize);
    
fprintf('Drawing rectangels\n');
ColorsMatrix = [unique(perms([0 0 255]), 'rows'); unique(perms([0 255 255]), 'rows'); [255 255 255]; unique(perms([127 0 0]), 'rows');...
    unique(perms([127 127 0]), 'rows');[127 127 127];unique(perms([50 100 200]),...
    'rows');unique(perms([25 50 100]), 'rows');unique(perms([25 75 200]), 'rows');];


[~, ~, currentFoundBB] = blobAnalyzer.step(VideoNatBinary(:,:,1));
FoundColored = ColoredBoundingBoxes(currentFoundBB, ColorsMatrix);
BBHistory1 = zeros([size(FoundColored, 1) 6], 'int32');
BBHistory1(:,1:4) = FoundColored(:,1:4);
BBHistory1(:,6) = FoundColored(:,5);
BBHistory2 = BBHistory1;
WeaknessThresholdShow = 10;
WeaknessThresholdDel = 20;
for i = 1 : MatDim(4)
    [~, ~, currentFoundBB] = blobAnalyzer.step(VideoNatBinary(:,:,i));
    if (i == 191)
        i
    end
    % We will create a new BB representation x,y,sizeX,sizeY,Weakness,Color
    % Predict
    predictedBB = PredictBB(BBHistory2, BBHistory1, size(ColorsMatrix, 1));
    %coloredCurrentFoundBB = AssociateToExistingBB(currentFoundBB, BBHistory1, size(ColorsMatrix, 1));
    %coloredCurrentFoundBB = AssociateToExistingBB(coloredCurrentFoundBB, BBHistory1, size(ColorsMatrix, 1));
    coloredCurrentFoundBB = AssociateToExistingBB(currentFoundBB, predictedBB, size(ColorsMatrix, 1));
    %predictedBB = PredictBB(BBHistory2, BBHistory1, coloredCurrentFoundBB, size(ColorsMatrix, 1));
    calculatedCurrentBB = CalculateBB(coloredCurrentFoundBB, predictedBB);
    calculatedCurrentBB(calculatedCurrentBB(:,5) > WeaknessThresholdDel, :) = [];
    BBHistory1(BBHistory1(:,5) > WeaknessThresholdDel - 1, :) = [];
    BBHistory2 = BBHistory1;
    BBHistory1 = calculatedCurrentBB;
    framebox = VideoMat(:,:,:,i);
    for j = 1 : size(calculatedCurrentBB, 1)
        if (calculatedCurrentBB(j,5) < WeaknessThresholdShow)
            
            color = ColorsMatrix(calculatedCurrentBB(j,6), :);
            framebox = insertShape(framebox, 'Rectangle', calculatedCurrentBB(j,(1 : 4)), 'LineWidth', 2,'color', color);
        end
    end
    result(:,:,:,i) = framebox;
    
end
result = uint8(result);

end