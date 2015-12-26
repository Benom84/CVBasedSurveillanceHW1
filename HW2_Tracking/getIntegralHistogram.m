function integral_histogram = getIntegralHistogram(region, NUM_OF_BINS)


%region histogram
[bins, edges] = histcounts(region, NUM_OF_BINS);

region_size = size(region);

%for each bin, create an integral image
integral_histogram = zeros([region_size(1), region_size(2), NUM_OF_BINS]);
for i = 1:NUM_OF_BINS
    %the edges are the values range we will sum
    edge_low = edges(i);
    edge_high = edges(i+1);
    
    bin_count_matrix = ((region >= edge_low) & (region < edge_high));
    
    %build and insert the bin integral image to the integral histogram.
    integral_histogram(:,:,i) = cumsum(cumsum(sum(bin_count_matrix, 3), 2), 1);
end

end