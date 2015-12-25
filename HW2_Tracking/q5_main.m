NUM_OF_BINS = 10;

%creating the objects-to-track struct
objects = struct('model_box', {}, ...
                 'histogram', {}, ...
                 'frames', {}, ...
                 'color', {});

objects(1).model_box = [413 213 442 291];
objects(1).frames = struct('start', 1, 'end', 27);
objects(1).color = 'red';

fprintf('reading video...\n');
reader = VideoReader('./data/PETS2014-0101-3.avi');
orig_video = reader.read();
orig_video_size = size(orig_video);
new_video_size = [orig_video_size(1)/2 orig_video_size(2)/2 orig_video_size(3) orig_video_size(4)];
newVideo = zeros(new_video_size, 'uint8');

frames_num = orig_video_size(4);
    
%in the form of [left top right bottom]
prev_model_box = objects(1).model_box;

%make IH for the model
prev_frame = imresize(uint8(orig_video(:,:,:,1)), 0.5);
prev_model_area = prev_frame(prev_model_box(2):prev_model_box(4), prev_model_box(1):prev_model_box(3),:);
prev_model_histogram = histcounts(prev_model_area, NUM_OF_BINS);

for i = 2:50%frames_num
    fprintf('%d', i);
    cur_frame = imresize(uint8(orig_video(:,:,:,i)), 0.5);

    %define where in the next frame to search for the model.
    %[left top right bottom]
    search_region_left = 2*prev_model_box(1) - prev_model_box(3);
    search_region_top = 2*prev_model_box(2) - prev_model_box(4);
    search_region_right = min(2*prev_model_box(3) - prev_model_box(1), new_video_size(2));
    search_region_bottom = min(2*prev_model_box(4) - prev_model_box(2), new_video_size(1));

    search_region_box = [search_region_left, search_region_top, search_region_right, search_region_bottom];
    search_region_area = cur_frame(search_region_box(2):search_region_box(4), search_region_box(1):search_region_box(3), :);
    search_region_ih = getIntegralHistogram(search_region_area, NUM_OF_BINS);

    %find the new model in the new frame (the closest match to the model)
    [cur_model_histogram, cur_model_box] = findBestIhModel(search_region_ih, size(prev_model_area), prev_model_histogram);
    cur_model_box = [search_region_box(1)+cur_model_box(1) ...
                     search_region_box(2)+cur_model_box(2) ...
                     search_region_box(1)+cur_model_box(3) ...
                     search_region_box(2)+cur_model_box(4)];

    %draw the frame
    bbox = [cur_model_box(1) cur_model_box(2) cur_model_box(3)-cur_model_box(1) cur_model_box(4)-cur_model_box(2)];
    cur_frame = insertShape(cur_frame, 'Rectangle', bbox, 'LineWidth', 2,'color', 'red');
    newVideo(:,:,:,i) = cur_frame;

    %update for next loop
    prev_frame = cur_frame;
    prev_model_histogram = cur_model_histogram;
    prev_model_box = cur_model_box;
end