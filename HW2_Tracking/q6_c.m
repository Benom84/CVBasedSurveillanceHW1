NUM_OF_BINS = 4;

objects = struct('coords', {}, ...
                 'histogram', {}, ...
                 'color', {}, ...
                 'size', {}, ...
                 'frames', {}, ...
                 'search_region_bounding_box', {});

%location of the model [left top right bottom]
objects(1).coords = [193 148 210 165];
objects(1).frames = struct('start', 1, 'end', 9999999);
objects(1).color = 'red';

objects(2).coords = [84 44 129 75];
objects(2).frames = struct('start', 1, 'end', 9999999);
objects(2).color = 'blue';
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% preparing the video we will work on
%--------------------------------------------------------------------------
fprintf('reading video...\n');
reader = VideoReader('./data/Walk2.mpeg');
orig_video = reader.read();
orig_video_size = size(orig_video);

processed_frames = [360 480];

check_proximity = 1;

new_video = integralHistogramTracking(NUM_OF_BINS,objects,processed_frames,orig_video,check_proximity);