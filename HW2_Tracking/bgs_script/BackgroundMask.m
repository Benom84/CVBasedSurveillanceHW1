function Mask = BackgroundMask(VideoMat, BackgroundAverage, FrameNumber, Threshold)
%{
Creates a 'black & white' image represented by a matrix.
after subtracting the background-average from the original image, each
pixel will hold a certain value. If the value is below the threshold, the
pixel belongs to the background (with 0 value), otherwise to the foreground (value 255).

The result is a black & white matrix representing background & foreground.
%}
if (nargin < 3)
    error('Must pass VideoMat, BackgroundAverage and FrameNumber');
end
if (nargin < 4)
    Threshold = 20;
end

MatDimension = size(VideoMat);
result = false(MatDimension(1), MatDimension(2));

CurrentFrameImage = squeeze(VideoMat(:,:,:,FrameNumber));


if (MatDimension(3) ~= 1)
    differenceMatrix = abs(CurrentFrameImage - BackgroundAverage);
    differenceMatrixSum = sum(differenceMatrix,3);
    result(differenceMatrixSum >= 3*Threshold) = true;
else
    differenceMatrix = abs(CurrentFrameImage - BackgroundAverage);
    result(differenceMatrix >= Threshold) = true;
end

Mask = result;