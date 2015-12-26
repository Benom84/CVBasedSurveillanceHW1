fprintf('reading video...\n');
reader = VideoReader('./data/PETS2014-0101-3.avi');
origVideo = reader.read();

fprintf('running the tracking algorithm...\n');
nbs_clean = track_nbs(origVideo, 500);

fprintf('done tracking_nbs!');
implay(nbs_clean);