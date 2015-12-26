reader = VideoReader('./data/PETS2014-0101-3.avi');
origVideo = reader.read();
origVideo = imresize(origVideo, 0.75);

C = 0;
O = 1;
N = 100;
Mean = 1;
Threshold = 45;
LearningRate = 0.01;
blobSize = 400;

nbs = NaiveBS(origVideo,C,O,N,Mean,Threshold,LearningRate);
fprintf('filling holes, reducing noise\n');
nbs_binary = bwareaopen(imfill(nbs, 'holes'), 100, 8);

nbs_clean = track_nbs4(origVideo, blobSize, nbs_binary, 0);
implay(nbs_clean);