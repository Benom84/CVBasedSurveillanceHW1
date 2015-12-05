reader = VideoReader('./data/PETS2014-0101-3.avi');

%Calculate frames numbers.
%(reader.Duration * reader.FrameRate) is the amount of frames.
%It can also be non-integer. In order to make it integer,
%we add 0.5 and floor the whole thing
framesNum = floor(reader.Duration * reader.FrameRate + 0.5);
origVideo = zeros(480,640 , 3, framesNum, 'uint8');
C = 0;
O = 1;
N = 100;
Mean = 1;
Threshold = 50;
LearningRate = 0.0001;

fprintf('Reading video frames');
for i=1 : framesNum
    frame = imresize(reader.readFrame(), [480 640]);
    origVideo(:,:,:,i) = frame;
end

blobAnalyzer = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
            'AreaOutputPort', true, 'CentroidOutputPort', true, ...
            'MinimumBlobArea', 400);

nbs = NaiveBS(origVideo,C,O,N,Mean,Threshold,LearningRate);
fprintf('filling holes, reducing noise\n');
nbs_clean = bwareaopen(imfill(nbs, 'holes'), 30, 8);

fprintf('Drawing rectangels\n');
for i=1 : framesNum
    [~, bboxes] = blobAnalyzer.step(nbs_clean(:,:,i));
    %'insertObjectAnnotation' functio must receive non-logical frame.
    origVideo(:,:,:,i) = insertObjectAnnotation(origVideo(:,:,:,i), 'rectangle', bboxes, 'BLAT');
end

implay(nbs_clean);