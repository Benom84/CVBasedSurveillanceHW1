function result = track_nbs(VideoMat)

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
    'MinimumBlobArea', 400);

nbs = NaiveBS(VideoMat,C,O,N,Mean,Threshold,LearningRate);
fprintf('filling holes, reducing noise\n');
nbs_binary = bwareaopen(imfill(nbs, 'holes'), 30, 8);

fprintf('Drawing rectangels\n');

for i=1 : MatDim(4)
    [~, ~, bboxes] = blobAnalyzer.step(nbs_binary(:,:,i));
    frame = VideoMat(:,:,:,i);
    framebox = insertShape(frame, 'Rectangle', bboxes, 'LineWidth', 2,'color', 'red');
    result(:,:,:,i) = framebox;
end


end