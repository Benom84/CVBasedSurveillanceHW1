function result = track_nbs(VideoMat, BlobSize)

MatDim = size(VideoMat);
result = zeros(MatDim(1), MatDim(2), MatDim(3), MatDim(4), 'uint8');
C = 0;
O = 1;
N = 100;
Mean = 1;
Threshold = 50;
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


[~, ~, bboxes] = blobAnalyzer.step(nbs_binary(:,:,1));
ColoredBoundingBoxMatrix = ColoredBoundingBoxes(bboxes, ColorsMatrix);


for i=1 : MatDim(4)
    [~, ~, bboxes] = blobAnalyzer.step(nbs_binary(:,:,i));
    ColoredBoundingBoxMatrix = ColoredBoundingBoxes(bboxes, ColorsMatrix, ColoredBoundingBoxMatrix);
    if (i == 77 || i == 78)
        fprintf('On frame:%d\n',i);
        fprintf('boxes:\n');
        bboxes
        fprintf('\nColoredBoundingBoxes\n');
        ColoredBoundingBoxMatrix
        
    end
    framebox = VideoMat(:,:,:,i);
    for j = 1 : size(ColoredBoundingBoxMatrix, 1)
        color = ColorsMatrix(ColoredBoundingBoxMatrix(j,5), :);
        if (i == 77 || i == 78)
            fprintf('On frame:%d\n',i);
            fprintf('\nColoredBoundingBox\n');
            ColoredBoundingBoxMatrix(j,(1 : 5))
            fprintf('Color:\n');
            color
        end
        framebox = insertShape(framebox, 'Rectangle', ColoredBoundingBoxMatrix(j,(1 : 4)), 'LineWidth', 2,'color', color);
    end
    result(:,:,:,i) = framebox;
    
end


end