function [new_model_histogram, new_model_box, min_difference] = findBestIhModel(search_region_ih, orig_model_size, orig_model_histogram, NUM_OF_BINS)
%{
By comparing integral-histograms, the function finds the model in the new
frame (actually finds the closest match to the original model).
%}

search_region_size = size(search_region_ih);
search_region_box = [1 1 search_region_size(2) search_region_size(1)];

%[left top right bottom]
new_model_box = [1 1 orig_model_size(2) orig_model_size(1)];

new_model_histogram = search_region_ih(new_model_box(4),new_model_box(3),:) - search_region_ih(new_model_box(4),new_model_box(1),:) - search_region_ih(new_model_box(2),new_model_box(3),:) + search_region_ih(new_model_box(2), new_model_box(1),:);
new_model_histogram = reshape(new_model_histogram, [1,NUM_OF_BINS]);

min_difference = 9999999999999999;

search_region_width = orig_model_size(2);
search_region_height = orig_model_size(1);

scales = [1 1.25 0.75];

for s = 1:numel(scales)
    
    search_region_width = ceil(search_region_width * scales(s));
    search_region_height = ceil(search_region_height * scales(s));
    
    for i = search_region_box(1):search_region_box(3) - search_region_width
        for j = search_region_box(2):search_region_box(4) - search_region_height
            %[i, j] the left-top corner of the candidate.
            %candidate_model_box = [left top right bottom]
            candidate_model_box = [i j i+search_region_width-1 j+search_region_height-1];

            candidate_model_histogram = search_region_ih(candidate_model_box(4),candidate_model_box(3),:) - search_region_ih(candidate_model_box(4),candidate_model_box(1),:) - search_region_ih(candidate_model_box(2),candidate_model_box(3),:) + search_region_ih(candidate_model_box(2), candidate_model_box(1),:);
            candidate_model_histogram = reshape(candidate_model_histogram, [1,NUM_OF_BINS]);

            %If the difference is a new low, update the values.
            candidate_min_difference = sqrt(sum((candidate_model_histogram/norm(candidate_model_histogram) - orig_model_histogram/norm(orig_model_histogram)).^2));

            if (candidate_min_difference < min_difference)
                new_model_histogram = candidate_model_histogram;
                new_model_box = candidate_model_box;
                min_difference = candidate_min_difference;
            end
        end
    end 
end

end