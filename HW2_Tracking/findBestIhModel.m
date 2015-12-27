function [new_model_histogram, new_model_coords, min_difference] = findBestIhModel(search_region_ih, orig_model_size, orig_model_histogram, NUM_OF_BINS)
%{
By comparing integral-histograms, the function finds the model in the new
frame (actually finds the closest match to the original model).
input:
    - search_region_ih : The region around the model, to exhaustively seach
    in
    - orig_model_size : the size of the model. Used for building
    candidate-models.
    - orig_model_histogram : the histogram we will match the
    candidate-models against.
    - NUM_OF_BINS : number of bins of the histograms
output:
    - new_model_histogram : the best candidate-model's histogram.
    - new_model_coords : the new-model coords in the region
    - min_difference : the gap from the original histogram. If the gap is
    too high for X consecutive frames, the object should not be tracked.
%}

search_region_size = size(search_region_ih);

%[left top right bottom]
search_region_coords = [1 1 search_region_size(2) search_region_size(1)];
new_model_coords = [1 1 orig_model_size(2) orig_model_size(1)];

new_model_histogram = search_region_ih(new_model_coords(4),new_model_coords(3),:) - search_region_ih(new_model_coords(4),new_model_coords(1),:) - search_region_ih(new_model_coords(2),new_model_coords(3),:) + search_region_ih(new_model_coords(2), new_model_coords(1),:);
new_model_histogram = reshape(new_model_histogram, [1,NUM_OF_BINS]);

%just a very high number, in order that the first comparison will pass
min_difference = 9999999999999999;

search_region_width = orig_model_size(2);
search_region_height = orig_model_size(1);

scales = [1 1.25 0.75];

%The exhaustive search, for each scale.
for s = 1:numel(scales)
    
    search_region_width = ceil(search_region_width * scales(s));
    search_region_height = ceil(search_region_height * scales(s));
    
    for i = search_region_coords(1):search_region_coords(3) - search_region_width
        for j = search_region_coords(2):search_region_coords(4) - search_region_height
            
            %[i, j] the left-top corner of the candidate.
            %candidate_model_box = [left top right bottom]
            candidate_model_coords = [i j i+search_region_width-1 j+search_region_height-1];

            candidate_model_histogram = search_region_ih(candidate_model_coords(4),candidate_model_coords(3),:) - search_region_ih(candidate_model_coords(4),candidate_model_coords(1),:) - search_region_ih(candidate_model_coords(2),candidate_model_coords(3),:) + search_region_ih(candidate_model_coords(2), candidate_model_coords(1),:);
            candidate_model_histogram = reshape(candidate_model_histogram, [1,NUM_OF_BINS]);

            %If the difference is a new low, update the values.
            candidate_min_difference = sqrt(sum((candidate_model_histogram/norm(candidate_model_histogram) - orig_model_histogram/norm(orig_model_histogram)).^2));

            if (candidate_min_difference < min_difference)
                new_model_histogram = candidate_model_histogram;
                new_model_coords = candidate_model_coords;
                min_difference = candidate_min_difference;
            end
        end
    end 
end

end