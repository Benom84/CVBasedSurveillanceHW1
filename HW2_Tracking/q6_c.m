NUM_OF_BINS = 4;

objects = struct('coords', {}, ...
                 'histogram', {}, ...
                 'color', {}, ...
                 'size', {}, ...
                 'search_region_bounding_box', {}, ...
                 'offline_count', {}, ...
                 'avg_difference', {}, ...
                 'is_offline', {});

%location of the model [left top right bottom]
objects(1).coords = [193 148 210 165];
objects(1).color = 'red';
objects(1).offline_count = 0;
objects(1).avg_difference = 0;
objects(1).is_offline = 0;

objects(2).coords = [84 44 129 75];
objects(2).color = 'blue';
objects(2).offline_count = 0;
objects(2).avg_difference = 0;
objects(2).is_offline = 0;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% preparing the video we will work on
%--------------------------------------------------------------------------
fprintf('reading video...\n');
reader = VideoReader('./data/Walk2.mpeg');
orig_video = reader.read();
orig_video_size = size(orig_video);

processed_frames = [360 460];

check_proximity = 1;
gap_limit = 0.4;
offline_count_limit = 3;

new_video = integralHistogramTracking(NUM_OF_BINS, objects, processed_frames, orig_video, check_proximity, gap_limit, offline_count_limit);