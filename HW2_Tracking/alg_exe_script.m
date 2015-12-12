reader = VideoReader('./data/PETS2014-0101-3.avi');
origVideo = reader.read();
nbs_clean = track_nbs(origVideo);
implay(nbs_clean);