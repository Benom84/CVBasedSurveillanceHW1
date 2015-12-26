reader = VideoReader('./data/Walk2.mpeg');
origVideo = reader.read();

C = 0;
O = 1;
N = 100;
Mean = 1;
Threshold = 45;
LearningRate = 0.0001;
blobSize = 100;

nbs = NaiveBS(origVideo,C,O,N,Mean,Threshold,LearningRate);
fprintf('filling holes, reducing noise\n');
nbs_binary = bwareaopen(imfill(nbs, 'holes'), 30, 8);

nbs_clean = track_nbs4(origVideo, blobSize, nbs_binary, 1);
implay(nbs_clean);