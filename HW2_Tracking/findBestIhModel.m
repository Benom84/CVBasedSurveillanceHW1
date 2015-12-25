function [new_model_histogram, new_model_box, min_difference] = findBestIhModel(search_region_ih, prev_model_size, prev_model_histogram)
%{
By comparing integral-histograms, the function finds the model in the new
frame (actually finds the closest match to the original model).
%}

search_region_size = size(search_region_ih);
search_region_box = [1 1 search_region_size(2) search_region_size(1)];

%[left top right bottom]
new_model_box = [1 1 prev_model_size(2) prev_model_size(1)];

new_model_histogram = search_region_ih(new_model_box(4),new_model_box(3),:) - search_region_ih(new_model_box(4),new_model_box(1),:) - search_region_ih(new_model_box(2),new_model_box(3),:) + search_region_ih(new_model_box(2), new_model_box(1),:);
new_model_histogram = reshape(new_model_histogram, [1,10]);

min_difference = sqrt(sum((new_model_histogram/norm(new_model_histogram) - prev_model_histogram/norm(prev_model_histogram)).^2));

for i = search_region_box(1):search_region_box(3)-prev_model_size(2)
    for j = search_region_box(2):search_region_box(4)-prev_model_size(1)
        %[i, j] the left-top corner of the candidate.
        %candidate_model_box = [left top right bottom]
        candidate_model_box = [i j i+prev_model_size(2)-1 j+prev_model_size(1)-1];
        
        candidate_model_histogram = search_region_ih(candidate_model_box(4),candidate_model_box(3),:) - search_region_ih(candidate_model_box(4),candidate_model_box(1),:) - search_region_ih(candidate_model_box(2),candidate_model_box(3),:) + search_region_ih(candidate_model_box(2), candidate_model_box(1),:);
        candidate_model_histogram = reshape(candidate_model_histogram, [1,10]);
        
        %If the difference is a new low, update the values.
        candidate_min_difference = sqrt(sum((candidate_model_histogram/norm(candidate_model_histogram) - prev_model_histogram/norm(prev_model_histogram)).^2));
        
        if (candidate_min_difference < min_difference)
            new_model_histogram = candidate_model_histogram;
            new_model_box = candidate_model_box;
            min_difference = candidate_min_difference;
        end
    end
end

end