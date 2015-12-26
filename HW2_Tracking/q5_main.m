NUM_OF_BINS = 6;

%--------------------------------------------------------------------------
% creating objects to track
% coords = [left top right bottom]
% histogram = 1xNUM_OF_BINS matrix
% frames = the range of frames to perform the search for the object on.
% color = the color of the rectangle for each object
% size = the object size, for the exhaustive research
%--------------------------------------------------------------------------
objects = struct('coords', {}, ...
                 'histogram', {}, ...
                 'frames', {}, ...
                 'color', {}, ...
                 'size', {}, ...
                 'search_region_bounding_box', {});

%location of the model [left top right bottom]
objects(1).coords = [413 213 442 291];
objects(1).frames = struct('start', 1, 'end', 27);
objects(1).color = 'red';

objects(2).coords = [344 232 347 244];
objects(2).frames = struct('start', 1, 'end', 19);
objects(2).color = 'blue';

objects(3).coords = [374 229 380 240];
objects(3).frames = struct('start', 1, 'end', 11);
objects(3).color = 'green';
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% preparing the video we will work on
%--------------------------------------------------------------------------
fprintf('reading video...\n');
reader = VideoReader('./data/PETS2014-0101-3.avi');
orig_video = reader.read();
orig_video_size = size(orig_video);

fprintf('scaling video...\n');
scaled_orig_video = zeros([orig_video_size(1)/2 orig_video_size(2)/2 orig_video_size(3) orig_video_size(4)], 'uint8');
for i = 1:orig_video_size(4)
    scaled_orig_video(:,:,:,i) = imresize(uint8(orig_video(:,:,:,i)), 0.5);
end

processed_frames = [1 30];

check_proximity = 0;

new_video = integralHistogramTracking(NUM_OF_BINS,objects,processed_frames,scaled_orig_video, check_proximity);
%--------------------------------------------------------------------------