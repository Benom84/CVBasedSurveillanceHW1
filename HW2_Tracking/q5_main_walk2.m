NUM_OF_BINS = 4;

%--------------------------------------------------------------------------
% creating objects to track
% - coords = [left top right bottom]
% - histogram = 1xNUM_OF_BINS matrix
% - color = the color of the rectangle for each object
% - size = the object size, for the exhaustive research
% - search_region_bounding_box = [x y width height], the bounding box of the
% search region. Used for proximity detection.
% - offline_count = the number of times the obejct have disappeared from
% the screen.
% - avg_difference = the average difference of candidate-model histograms
% from the original model's histogram. If for X consecutive frames the
% best candidate gap is higher than the average, the object will no longer
% be tracked (is_offline == 1).
% - is_offline = 0 if the object is being tracked, 1 otherwise.
%--------------------------------------------------------------------------
objects = struct('coords', {}, ...
                 'histogram', {}, ...
                 'color', {}, ...
                 'size', {}, ...
                 'search_region_bounding_box', {}, ...
                 'offline_count', {}, ...
                 'avg_difference', {}, ...
                 'is_offline', {});

objects(1).coords = [191 146 212 167];
objects(1).color = 'red';
objects(1).offline_count = 0;
objects(1).avg_difference = 0;
objects(1).is_offline = 0;

objects(2).coords = [86 53 101 67];
objects(2).color = 'blue';
objects(2).offline_count = 0;
objects(2).avg_difference = 0;
objects(2).is_offline = 0;

objects(3).coords = [104 41 118 56];
objects(3).color = 'green';
objects(3).offline_count = 0;
objects(3).avg_difference = 0;
objects(3).is_offline = 0;

objects(4).coords = [74 244 92 249];
objects(4).color = 'yellow';
objects(4).offline_count = 0;
objects(4).avg_difference = 0;
objects(4).is_offline = 0;

%--------------------------------------------------------------------------
% preparing the video we will work on
%--------------------------------------------------------------------------
fprintf('reading video...\n');
reader = VideoReader('./data/Walk2.mpeg');
orig_video = reader.read();
orig_video_size = size(orig_video);

%The video will be processed for these given frames range.
processed_frames = [360 460];

%In this exercise we don't want the algorith, to check for proximity
%between object.
check_proximity = 0;

%The permitted difference size from the average difference, of the
%comparison between original model's histogram to other candidates'.
gap_limit = 0.4;

%The permitted amount of times for the object to be off-screen until it is
%declared as untracked.
offline_count_limit = 3;

new_video = integralHistogramTracking(NUM_OF_BINS, objects, processed_frames, orig_video, check_proximity, gap_limit, offline_count_limit);