function Background = CreateBackgroundAverage(VideoMat, N, Mean)

%{
This function creates a 3 dim matrix, representing an image.
Each pixel of this image is the average pixel background of 'N' frames,
so the whole image is a background average of N frames.

VideoMat - The frames matrix (4 dimensions: height, width, # color channels, frame #)
N - the number of frames to take into consideration (N >= 0)
Mean - boolean which points how to calculate the acerage. 1 is 'mean' function, 0 is 'median' function
%}

MatDimension = size(VideoMat);

%This line is needed? result is not defined:
result = zeros(MatDimension(1), MatDimension(2), MatDimension(3));


%If we calculate the starting background as Mean then for each pixel we
%will check the mean across N frames
if (Mean == 1)
    
    result = mean(VideoMat(:, :, :, 1:N), 4);
    
    %If we calculate the starting background as Median then for each pixel we
    %will check the median across N frames
else
    
    result = median(VideoMat(:, :, :, 1:N), 4);
end

Background = int16(result);