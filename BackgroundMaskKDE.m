function [SelectiveMask, BackgroundMask] = BackgroundMaskKDE(Video, NumberOfFrames, currentFrameIndex, Threshold, PixelValuesHistory)

if (nargin < 5)
    error('Must pass Video, NumberOfFrames, currentFrameIndex, Threshold, and PixelValues\n');
end

DoubleThreshold = false;
if (size(Threshold,2) == 2)
    DoubleThreshold = true;
    Threshold2 = Threshold(1,2);
    Threshold = Threshold(1,1);
end
MatDimension = size(Video);
BackgroundMask = false(MatDimension(1), MatDimension(2));
SelectiveMask = false(MatDimension(1), MatDimension(2));

DifferenceMatrix = double(repmat(squeeze(Video(:,:,currentFrameIndex)),[1,1,NumberOfFrames]) - PixelValuesHistory);
PreMedianMatrix = double(abs(PixelValuesHistory - circshift(PixelValuesHistory, 1, 3)));
MedianMatrix = median(PreMedianMatrix, 3);
MedianMatrix(MedianMatrix == 0) = 1;


VarianceMatrix = (MedianMatrix ./ (0.68*2^0.5)).^2;
VarianceMatrix = repmat(VarianceMatrix, 1 ,1 , NumberOfFrames);

ProbabilityMatrix = 1./sqrt(2*pi*VarianceMatrix).*exp(-0.5*DifferenceMatrix.^2 ./ VarianceMatrix);
SumProbabilityMatrix = (sum(ProbabilityMatrix, 3));

SumProbabilityMatrix = SumProbabilityMatrix/NumberOfFrames;

BackgroundMask(SumProbabilityMatrix < Threshold) = true;

if (DoubleThreshold)
    SelectiveMask(SumProbabilityMatrix < Threshold2) = true;
else
    SelectiveMask = BackgroundMask;
end