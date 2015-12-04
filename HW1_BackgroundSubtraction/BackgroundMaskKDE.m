function [SelectiveMask, BackgroundMask] = BackgroundMaskKDE(Video, NumberOfFrames, currentFrameIndex, Threshold, PixelValuesHistory)

if (nargin < 5)
    error('Must pass Video, NumberOfFrames, currentFrameIndex, Threshold, and PixelValues\n');
end

% Check if the threshold passed has one or two values
DoubleThreshold = false;
if (size(Threshold,2) == 2)
    DoubleThreshold = true;
    Threshold2 = Threshold(1,2);
    Threshold = Threshold(1,1);
end

MatDimension = size(Video);

% Prepare the selective mask and the background mask
BackgroundMask = false(MatDimension(1), MatDimension(2));
SelectiveMask = false(MatDimension(1), MatDimension(2));

% Create a matrix with the difference between X(t) - X(i)
DifferenceMatrix = double(repmat(squeeze(Video(:,:,currentFrameIndex)),[1,1,NumberOfFrames]) - PixelValuesHistory);
% Create a matrix with the difference in the history X(i+1) - X(i)
PreMedianMatrix = double(abs(PixelValuesHistory - circshift(PixelValuesHistory, 1, 3)));
% Get the median for each history difference of pixel
MedianMatrix = median(PreMedianMatrix, 3);
% If the median is 0 than put 1 to avoid Nan values
MedianMatrix(MedianMatrix == 0) = 1;

% Calculate the sigma according to M/(0.68*2^0.5) and raise by power of 2
% for the variance. Duplicate the values to allow dimension matching
VarianceMatrix = (MedianMatrix ./ (0.68*2^0.5)).^2;
VarianceMatrix = repmat(VarianceMatrix, 1 ,1 , NumberOfFrames);

% Calculate the probability for each pixel according to the history and sum
% it and divide by the number of frames
ProbabilityMatrix = 1./sqrt(2*pi*VarianceMatrix).*exp(-0.5*DifferenceMatrix.^2 ./ VarianceMatrix);
SumProbabilityMatrix = (sum(ProbabilityMatrix, 3));
SumProbabilityMatrix = SumProbabilityMatrix/NumberOfFrames;

% Create a mask for the foreground based on the threshold
BackgroundMask(SumProbabilityMatrix < Threshold) = true;

% If there is a double threshold calculate the selective mask by that
% threshold, otherwise it is the same mask as before
if (DoubleThreshold)
    SelectiveMask(SumProbabilityMatrix < Threshold2) = true;
else
    SelectiveMask = BackgroundMask;
end