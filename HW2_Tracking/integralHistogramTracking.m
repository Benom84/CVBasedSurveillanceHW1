function [new_video] = integralHistogramTracking(NUM_OF_BINS, objects, processed_frames, scaled_orig_video, check_proximity, gap_limit, offline_count_limit)

%{
This function tracks given objects in a sequence of video frames, using
histogram comparison. Obtaining the histogram of the model in the first
frame, the algorithm performs exhaustive search for the model in its
neighboorhood, and draws a box around the object. The function is also
capable of determining if the objects are about to get close to each other.

input:
    - NUM_OF_BINS : the bins number for building histograms
    - objects : struct-array of objects to track
    - processed_frames : in which frames to process the video
    - scaled_orig_video : the true-color video to process AFTER it was
    scaled to the desired dimensions.
    - check_proximity : if set to 1, when two objects are about to get close to
    each other, a red line is drawn between them.
    - gap_limit : the permitted difference between candidate-model
    histgoram to the model's. If the result gap is higher for <offline_count_limit> frames,
    the object is at risk of being untracked.
    - offline_count_limit : if an object is invisible for
    <offline_count_limit> frames, the algorithm will no longer track it.

output:
    - new_video : the new video, with boxsx around objects.
%}

scaled_orig_video_size = size(scaled_orig_video);
new_video = zeros([scaled_orig_video_size(1), scaled_orig_video_size(2), scaled_orig_video_size(3), processed_frames(2)-processed_frames(2)+1], 'uint8');
new_video_size = size(new_video);

%--------------------------------------------------------------------------
% Algorithm beginning. Extract the histograms of the tracked obejcts
% according to their loaction (given manually above)
%--------------------------------------------------------------------------

%the prev_frame is the actual model that we will exhaustively search for
%and we don't want to draw rectangles in it. This is the purpose of
%prev_frame_painted to be drawn with rectangles around the object.
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
% From the 2nd frame and on, perform an exhaustive search for the model.
%--------------------------------------------------------------------------
avg = 0;
for i = 1+processed_frames(1):processed_frames(2)
    fprintf('processing frame #%d / %d\n', i-processed_frames(1)+1, processed_frames(2)-processed_frames(1)+1);
    cur_frame = scaled_orig_video(:,:,:,i);
    
    %when inserting a shape to the frame, we don't want that our
    %inserted-shape will affect the histogram. So, the search is performed
    %on 'cur_frame', but the shapes are inserted to 'cur_frame_painted'.
    cur_frame_painted = cur_frame;

    for o = 1:numel(objects)
        
        %Do not process the histogram of the object if he is no longer
        %tracked.
        if (objects(o).is_offline == 1)
            new_video(:,:,:,i-processed_frames(1)+1) = cur_frame;
            continue;
        end
        
        %define where in the next frame to search for the model.
        search_region_left = max(1, 2*objects(o).coords(1) - objects(o).coords(3));
        search_region_top = max(1, 2*objects(o).coords(2) - objects(o).coords(4));
        search_region_right = min(2*objects(o).coords(3) - objects(o).coords(1), new_video_size(2));
        search_region_bottom = min(2*objects(o).coords(4) - objects(o).coords(2), new_video_size(1)); 
        
        %[left top right bottom]
        search_region_coords = [search_region_left, search_region_top, search_region_right, search_region_bottom];
        objects(o).search_region_bounding_box = [search_region_coords(1) search_region_coords(2) search_region_coords(3)-search_region_coords(1) search_region_coords(4)-search_region_coords(2)];
        
        %extract the integral histogram for the region
        search_region_area = cur_frame(search_region_coords(2):search_region_coords(4), search_region_coords(1):search_region_coords(3), :);
        search_region_ih = getIntegralHistogram(search_region_area, NUM_OF_BINS);
        
        %find the new model in the new frame (the closest match to the model)
        [cur_model_histogram, cur_coords, difference] = findBestIhModel(search_region_ih, objects(o).size, objects(o).histogram, NUM_OF_BINS);
        
        %Check if we lost track of this object.
        %Each frame that we don't track the object we increase it's
        %offline_count property. When it reaches the limit, it is no longer
        %tracked (is_offline = 1).
        if (objects(o).avg_difference ~= 0)
            gap = difference - objects(o).avg_difference;
            objects(o).avg_difference = objects(o).avg_difference*0.95 + difference*0.05;
            if (gap >= gap_limit)
                objects(o).offline_count = objects(o).offline_count + 1;
                if (objects(o).offline_count >= offline_count_limit)
                    objects(o).is_offline = 1;
                end
            else
                objects(o).offline_count = max(objects(o).offline_count - 1, 0);
            end
        else
            objects(o).avg_difference = difference;
        end
        
        cur_coords = [search_region_coords(1)+cur_coords(1) ...
                         search_region_coords(2)+cur_coords(2) ...
                         search_region_coords(1)+cur_coords(3) ...
                         search_region_coords(2)+cur_coords(4)];
                     
        %draw the frame
        bbox = [cur_coords(1) cur_coords(2) cur_coords(3)-cur_coords(1) cur_coords(4)-cur_coords(2)];
        cur_frame_painted = insertShape(cur_frame_painted, 'Rectangle', bbox, 'LineWidth', 2,'color', objects(o).color);
        
        %update the model coords
        objects(o).coords = cur_coords;
    end
    
    %Alert on proximity between objects
    if (check_proximity == 1)
        for o1 = 1:numel(objects)
            for o2 = o1+1:numel(objects)
                if (BoundingBoxOverlap(objects(o1).search_region_bounding_box, objects(o2).search_region_bounding_box) == 1 && ...
                        objects(o1).is_offline == 0 && objects(o2).is_offline == 0)
                    x1 = ceil((objects(o1).coords(1) + objects(o1).coords(3)) / 2);
                    y1 = ceil((objects(o1).coords(2) + objects(o1).coords(4)) / 2);
                    x2 = ceil((objects(o2).coords(1) + objects(o2).coords(3)) / 2);
                    y2 = ceil((objects(o2).coords(2) + objects(o2).coords(4)) / 2);
                    cur_frame_painted = insertShape(cur_frame_painted, 'Line', [x1 y1 x2 y2], 'color', 'red');
                end
            end
        end
    end
    
    new_video(:,:,:,i-processed_frames(1)+1) = cur_frame_painted;
end

end