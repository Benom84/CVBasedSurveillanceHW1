function res = BackgroundMaskKDE(Video, NumberOfFrames, currentFrameIndex, Threshold, PixelValuesHistory, PixelValuesIndex)

if (nargin < 5)
    error('Must pass Video, NumberOfFrames, currentFrameIndex, Threshold, and PixelValues\n');
end
if (nargin < 6)
    Selective = 0;
else
    Selective = 1;
end
MatDimension = size(Video);
Mask = zeros(MatDimension(1), MatDimension(2));
if (Selective == 0)
    %fprintf('Preparing DifferenceMatrix\n');
    DifferenceMatrix = double(repmat(squeeze(Video(:,:,currentFrameIndex)),[1,1,NumberOfFrames]) - PixelValuesHistory);
    %fprintf('Calculating PreMedianMatrix\n');
    %PreMedianMatrix = abs(PixelValuesHistory - circshift(PixelValuesHistory, 1, 3));
    %fprintf('Calculating Median Matrix\n');
    %MedianMatrix = median(PreMedianMatrix, 3);
    %fprintf('Calculating Variance Matrix\n');
    %VarianceMatrix = (MedianMatrix ./ (0.68*2^0.5)).^2;
    VarianceMatrix = (var(DifferenceMatrix, 0, 3));
    %VarianceMatrix = repmat(VarianceMatrix, 1 ,1 , NumberOfFrames);
    %fprintf('Calculating Probability Matrix\n');
    %ProbabilityMatrix = arrayfun(@(difference, variance) KDEProbabiliyCalc(difference, variance, NumberOfFrames)...
    %    , DifferenceMatrix, VarianceMatrix);
    ProbabilityMatrix = double(zeros(MatDimension(1), MatDimension(2), NumberOfFrames));
    for i = 1: MatDimension(1)
        for j = 1: MatDimension(2)
            variance = double(VarianceMatrix(i,j));
            Divisor = (2.0*pi*variance)^0.5;
            for frame = 1 : NumberOfFrames
                difference = double(DifferenceMatrix(i,j,frame));
                Exponent = -0.5 * (difference^2) / variance;
                ProbabilityMatrix(i, j, frame) = (1/NumberOfFrames) * (exp(Exponent))/Divisor;
                
            end
        end
    end
    
    %fprintf('Calculating Sum Probability Matrix\n');
    SumProbabilityMatrix = sum(ProbabilityMatrix, 3);
    if (currentFrameIndex == 60)
        SumProbabilityMatrix(5,5)
        SumProbabilityMatrix
    end
    %fprintf('Creating Mask\n');
    Mask(SumProbabilityMatrix < Threshold) = 1;
    
end

res = Mask;