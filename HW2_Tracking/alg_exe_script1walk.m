reader = VideoReader('./data/Walk2.mpeg');
origVideo = reader.read();
C = 0; O = 1; N = 100; Mean = 1; Threshold = 50; LearningRate = 0.0001;
blobSize = 100;

%'nbs' is a mtrix which holds the naive background subtraction from HW1.
nbs = NaiveBS(origVideo,C,O,N,Mean,Threshold,LearningRate);

fprintf('filling holes, reducing noise\n');
%'nbs_binary' holds the 'nbs' matrix, with some matlab magic of filliing
%holes in blobs, and ignoring small blobs.
nbs_binary = bwareaopen(imfill(nbs, 'holes'), 30, 8);

nbs_clean = track_nbs(origVideo, blobSize, nbs_binary);
implay(nbs_clean);