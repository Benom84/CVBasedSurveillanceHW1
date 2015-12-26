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
                 'size', {});

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

%frames_num = orig_video_size(4);
frames_num = 30;

new_video_size = [orig_video_size(1)/2 orig_video_size(2)/2 orig_video_size(3) orig_video_size(4)];
new_video = zeros([new_video_size(1), new_video_size(2), new_video_size(3), frames_num], 'uint8');
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Algorithm beginning. Extract the histograms of the tracked obejcts
% according to their loaction (given manually above)
%--------------------------------------------------------------------------

prev_frame = imresize(uint8(orig_video(:,:,:,1)), 0.5);

%make histogram for every model
for o = 1:numel(objects)
    model_area = prev_frame(objects(o).coords(2):objects(o).coords(4), objects(o).coords(1):objects(o).coords(3),:);
    objects(o).histogram = histcounts(model_area, NUM_OF_BINS);
    objects(o).size = size(model_area);
end

%--------------------------------------------------------------------------
% From the 2nd frame and on, perform an exhaustive search for the model,
% and update it with the closest model we found during this search.
%--------------------------------------------------------------------------

for i = 2:frames_num
    fprintf('processing frame #%d / %d\n', i, frames_num);
    cur_frame = imresize(uint8(orig_video(:,:,:,i)), 0.5);
    
    %when inserting a shape to the frame, we don't want that our
    %inserted-shape will affect the histogram. So, the search is performed
    %on 'cur_frame', but the shapes are inserted to 'cur_frame_painted'.
    cur_frame_painted = cur_frame;

    for o = 1:numel(objects)
        
        %Do not process the histogram if the object we track shouldnt
        %appear there. Therefore, the search for the object will be done
        %only between its frames range.
        if (i < objects(o).frames.start || i >= objects(o).frames.end)
            new_video(:,:,:,i) = cur_frame;
            continue;
        end
        
        %define where in the next frame to search for the model.
        search_region_left = 2*objects(o).coords(1) - objects(o).coords(3);
        search_region_top = 2*objects(o).coords(2) - objects(o).coords(4);
        search_region_right = min(2*objects(o).coords(3) - objects(o).coords(1), new_video_size(2));
        search_region_bottom = min(2*objects(o).coords(4) - objects(o).coords(2), new_video_size(1)); 
        
        %[left top right bottom]
        search_region_box = [search_region_left, search_region_top, search_region_right, search_region_bottom];
        
        %extract the integral histogram for the region
        search_region_area = cur_frame(search_region_box(2):search_region_box(4), search_region_box(1):search_region_box(3), :);
        search_region_ih = getIntegralHistogram(search_region_area, NUM_OF_BINS);
        
        %find the new model in the new frame (the closest match to the model)
        [cur_model_histogram, cur_coords] = findBestIhModel(search_region_ih, objects(o).size, objects(o).histogram, NUM_OF_BINS);
        cur_coords = [search_region_box(1)+cur_coords(1) ...
                         search_region_box(2)+cur_coords(2) ...
                         search_region_box(1)+cur_coords(3) ...
                         search_region_box(2)+cur_coords(4)];
                     
        %draw the frame
        bbox = [cur_coords(1) cur_coords(2) cur_coords(3)-cur_coords(1) cur_coords(4)-cur_coords(2)];
        cur_frame_painted = insertShape(cur_frame_painted, 'Rectangle', bbox, 'LineWidth', 2,'color', objects(o).color);
        
        %update the model to track on.
        objects(o).histogram = cur_model_histogram;
        objects(o).coords = cur_coords;
    end
    
    new_video(:,:,:,i) = cur_frame_painted;
end