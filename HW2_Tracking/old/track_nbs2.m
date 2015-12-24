function result = track_nbs2(VideoMat, BlobSize)

MatDim = size(VideoMat);
result = zeros(MatDim(1), MatDim(2), MatDim(3), MatDim(4), 'int32');
C = 0;
O = 1;
N = 100;
Mean = 1;
Threshold = 45;
LearningRate = 0.0001;
blobAnalyzer = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', true, 'CentroidOutputPort', true, ...
    'MinimumBlobArea', BlobSize);

nbs = NaiveBS(VideoMat,C,O,N,Mean,Threshold,LearningRate);
fprintf('filling holes, reducing noise\n');
nbs_binary = bwareaopen(imfill(nbs, 'holes'), 30, 8);

fprintf('Drawing rectangels\n');
ColorsMatrix = [unique(perms([0 0 255]), 'rows'); unique(perms([0 255 255]), 'rows'); [255 255 255]; unique(perms([127 0 0]), 'rows');...
    unique(perms([127 127 0]), 'rows');[127 127 127];unique(perms([50 100 200]), 'rows');];


[~, ~, currentFoundBB] = blobAnalyzer.step(nbs_binary(:,:,1));
FoundColored = ColoredBoundingBoxes(currentFoundBB, ColorsMatrix);
BBHistory1 = zeros([size(FoundColored, 1) 6], 'int32');
BBHistory1(:,1:4) = FoundColored(:,1:4);
BBHistory1(:,6) = FoundColored(:,5);
BBHistory2 = BBHistory1;
ImageBounds = [size(nbs_binary,1) size(nbs_binary,2)];
WeaknessThresholdShow = 20;
WeaknessThresholdDel = 200;
for i = 1 : MatDim(4)
    if (i == 4)
        i
    end
    [~, ~, currentFoundBB] = blobAnalyzer.step(nbs_binary(:,:,i));

    % We will create a new BB representation x,y,sizeX,sizeY,Weakness,Color
    % Predict
    PredictedBB = predictBoundingBox(BBHistory2, BBHistory1, ImageBounds);
    CalculatedCurrentBB = AveragePredictAndFound(currentFoundBB, PredictedBB);
    CalculatedCurrentBB = DeleteOverlappingResults(CalculatedCurrentBB);
    CalculatedCurrentBB = ColorAllBoxes(CalculatedCurrentBB, BBHistory1, size(ColorsMatrix,1));
    CalculatedCurrentBB(CalculatedCurrentBB(:,5) > WeaknessThresholdDel, :) = [];
    BBHistory1(BBHistory1(:,5) > WeaknessThresholdDel - 1, :) = [];
    BBHistory2 = BBHistory1;
    BBHistory1 = CalculatedCurrentBB;
    
    framebox = VideoMat(:,:,:,i);
    for j = 1 : size(CalculatedCurrentBB, 1)
        if (CalculatedCurrentBB(j,5) < WeaknessThresholdShow)
            color = ColorsMatrix(CalculatedCurrentBB(j,6), :);
            framebox = insertShape(framebox, 'Rectangle', CalculatedCurrentBB(j,(1 : 4)), 'LineWidth', 2,'color', color);
        end
    end
    result(:,:,:,i) = framebox;
    
end
result = uint8(result);

end