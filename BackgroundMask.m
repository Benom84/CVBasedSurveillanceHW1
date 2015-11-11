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
result = zeros(MatDimension(1), MatDimension(2));

CurrentFrameImage = squeeze(VideoMat(:,:,:,FrameNumber));


if (MatDimension(3) ~= 1)
    thresholdSqr = Threshold^2;
    differenceMatrix = CurrentFrameImage - BackgroundAverage;
    differenceMatrixSqr = uint16(differenceMatrix) .* uint16(differenceMatrix);
    differenceMatrixSqrSum = sum(differenceMatrixSqr,3);
    result(differenceMatrixSqrSum >= thresholdSqr | differenceMatrixSqrSum <= -thresholdSqr) = 255;
else
    differenceMatrix = CurrentFrameImage - BackgroundAverage;
    result(differenceMatrix >= Threshold | differenceMatrix <= -Threshold) = 255;
end

Mask = result;