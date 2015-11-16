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
%result = zeros(MatDimension(1), MatDimension(2), MatDimension(3), 'uint8');

if (Mean == 1)
    for i = 1:MatDimension(1)
        for j = 1:MatDimension(2)
            for colors = 1:MatDimension(3)
                result(i,j,colors) = mean(VideoMat(i, j, colors, 1:N+1));
            end
        end
    end
else
    for i = 1:MatDimension(1)
        for j = 1:MatDimension(2)
            for colors = 1:MatDimension(3)
                result(i,j,colors) = median(VideoMat(i, j, colors, 1:N+1));
            end
        end
    end
end

Background = uint8(result);