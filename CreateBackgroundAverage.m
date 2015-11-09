function Background = CreateBackgroundAverage(VideoMat, N, Mean)

MatDimension = size(VideoMat);

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