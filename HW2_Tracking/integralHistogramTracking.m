function [new_video] = integralHistogramTracking(NUM_OF_BINS, objects, processed_frames, scaled_orig_video, check_proximity)

scaled_orig_video_size = size(scaled_orig_video);
new_video = zeros([scaled_orig_video_size(1), scaled_orig_video_size(2), scaled_orig_video_size(3), processed_frames(2)-processed_frames(2)+1], 'uint8');
new_video_size = size(new_video);

%--------------------------------------------------------------------------
% Algorithm beginning. Extract the histograms of the tracked obejcts
% according to their loaction (given manually above)
%--------------------------------------------------------------------------

prev_frame = scaled_orig_video(:,:,:,processed_frames(1));
prev_frame_painted = prev_frame;

fprintf('processing frame #1 / %d\n', processed_frames(2)-processed_frames(1)+1);
%make histogram for every model
for o = 1:numel(objects)
    model_area = prev_frame(objects(o).coords(2):objects(o).coords(4), objects(o).coords(1):objects(o).coords(3),:);
    objects(o).histogram = histcounts(model_area, NUM_OF_BINS);
    objects(o).size = size(model_area);
    
    %draw the frame
    bbox = [objects(o).coords(1) objects(o).coords(2) objects(o).coords(3)-objects(o).coords(1) objects(o).coords(4)-objects(o).coords(2)];
    prev_frame_painted = insertShape(prev_frame_painted, 'Rectangle', bbox, 'LineWidth', 2,'color', objects(o).color);
end
new_video(:,:,:,1) = prev_frame_painted;

%--------------------------------------------------------------------------
% From the 2nd frame and on, perform an exhaustive search for the model,
% and update it with the closest model we found during this search.
%--------------------------------------------------------------------------

for i = 1+processed_frames(1):processed_frames(2)
    fprintf('processing frame #%d / %d\n', i-processed_frames(1)+1, processed_frames(2)-processed_frames(1)+1);
    cur_frame = scaled_orig_video(:,:,:,i);
    
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
        search_region_left = max(1, 2*objects(o).coords(1) - objects(o).coords(3));
        search_region_top = max(1, 2*objects(o).coords(2) - objects(o).coords(4));
        search_region_right = min(2*objects(o).coords(3) - objects(o).coords(1), new_video_size(2));
        search_region_bottom = min(2*objects(o).coords(4) - objects(o).coords(2), new_video_size(1)); 
        
        %[left top right bottom]
        search_region_box = [search_region_left, search_region_top, search_region_right, search_region_bottom];
        objects(o).search_region_bounding_box = [search_region_box(1) search_region_box(2) search_region_box(3)-search_region_box(1) search_region_box(4)-search_region_box(2)];
        
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
    
    if (check_proximity == 1 && BoundingBoxOverlap(objects(1).search_region_bounding_box, objects(2).search_region_bounding_box) == 1)
        x1 = ceil((objects(1).coords(1) + objects(1).coords(3)) / 2);
        y1 = ceil((objects(1).coords(2) + objects(1).coords(4)) / 2);
        x2 = ceil((objects(2).coords(1) + objects(2).coords(3)) / 2);
        y2 = ceil((objects(2).coords(2) + objects(2).coords(4)) / 2);
        cur_frame_painted = insertShape(cur_frame_painted, 'Line', [x1 y1 x2 y2], 'color', 'red');
    end
    
    new_video(:,:,:,i-processed_frames(1)+1) = cur_frame_painted;
    if (i == 380)
        i
    end
end

end