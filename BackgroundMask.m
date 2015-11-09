function Mask = BackgroundMask(VideoMat, BackgroundAverage, FrameNumber, Threshold)
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