function result = track_nbs(VideoMat, BlobSize, VideoMatBinary)

MatDim = size(VideoMat);
result = zeros(MatDim(1), MatDim(2), MatDim(3), MatDim(4), 'uint8');
blobAnalyzer = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', true, 'CentroidOutputPort', true, ...
    'MinimumBlobArea', BlobSize);

fprintf('Drawing rectangels\n');

%'ColorsMatrix' purpose is to store different colors for up to 20 blobs
%while tracking. Each row is in the form of [R G B], the bounding=box color.
ColorsMatrix = [unique(perms([0 0 255]), 'rows'); unique(perms([0 255 255]), 'rows'); [255 255 255]; unique(perms([127 0 0]), 'rows');...
    unique(perms([127 127 0]), 'rows');[127 127 127];unique(perms([50 100 200]), 'rows');];


%'ColoredBoundingBoxMatrix' stores an additional column, comparing to
%'ColorsMatrix'. The column is 'blob number'. The purpose of this matrix is
%to keep for each blob the same bounding-box color while tracking.
[~, ~, bboxes] = blobAnalyzer.step(VideoMatBinary(:,:,1));
ColoredBoundingBoxMatrix = zeros([size(bboxes, 1) 6], 'int32');
ColoredBoundingBoxMatrix(:,1:4) = bboxes;
ColoredBoundingBoxMatrix(:,6) = (1 : size(bboxes, 1))';
%ColoredBoundingBoxMatrix = ColoredBoundingBoxes(bboxes, ColorsMatrix);

%For each frame, draw a bounding-box around tracked blobs.
for i=1 : MatDim(4)
    [~, ~, bboxes] = blobAnalyzer.step(VideoMatBinary(:,:,i));

    %'ColoredBoundingBoxes' function keeps the same color for the same
    %blob.
    currentFoundBB = zeros([size(bboxes, 1) 6], 'int32');
    currentFoundBB(:,1:4) = bboxes(:,:);
    ColoredBoundingBoxMatrix = AssociateToExistingBB(currentFoundBB, ColoredBoundingBoxMatrix, size(ColorsMatrix, 1));
    
    %For each blob, draw the bbox around it.
    framebox = VideoMat(:,:,:,i);
    for j = 1 : size(ColoredBoundingBoxMatrix, 1)
        color = ColorsMatrix(ColoredBoundingBoxMatrix(j,6), :);
        framebox = insertShape(framebox, 'Rectangle', ColoredBoundingBoxMatrix(j,(1 : 4)), 'LineWidth', 2,'color', color);
    end
    result(:,:,:,i) = framebox;
    
end


end