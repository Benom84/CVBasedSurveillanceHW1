origVideo = readImagesDir('./data/highway/input');
%origVideo = imresize(origVideo, 0.75);

C = 0;
O = 1;
N = 100;
Mean = 1;
Threshold = 45;
LearningRate = 0.0001;
blobSize = 300;

nbs = NaiveBS(origVideo,C,O,N,Mean,Threshold,LearningRate);
fprintf('filling holes, reducing noise\n');
nbs_binary = bwareaopen(imfill(nbs, 'holes'), 50, 8);

nbs_clean = track_nbs2(origVideo, blobSize, nbs_binary);
implay(nbs_clean);