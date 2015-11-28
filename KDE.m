function Res = KDE(VideoMat,O,N,Threshold, Selective)
%NaiveBS(VideoMat,C,O,N,Mean,Threshold, Selective, LearningRate)
%This functino does the Naive Background Subtraction.
%input:
%- VideoMat : 4 dimension matrix of the form (height, width, # of color channels, frame #)
%- O : Define if output is the Mask (1) or frames(0)
%- N : Number of frames to do CreateBackgoundAverage on. (N >= 0)
%- Threshold : x or [x y]. x - The sensitivity factor for deciding if a pixel is 
% background or foreground. If y is present selective update uses that
% threshold.
%- Selective : 0 - Non 1 - Selective
%
%Usage exaple:
%
if (mod(N, 2) == 0)
    N = N + 1; %Median is 30 times faster for odd numbers
end
MatDimension = size(VideoMat);
%If we choose color images the dimensions are the same, otherwise only gray level.
%We will preallocate memory to increase performance.
fprintf('Starting...\n');
fprintf('Preparing gray result matrix\n');
result = zeros(MatDimension(1), MatDimension(2), 1, MatDimension(4), 'uint8');

%Transform the entire video to gray levels
updatedVideo = zeros(MatDimension(1), MatDimension(2), 1, MatDimension(4), 'int16');
fprintf('Modifying the movie to gray levels\n');
for i = 1:MatDimension(4)
    grayFrame = rgb2gray(squeeze(VideoMat(:,:,:,i)));
    updatedVideo(:,:,:,i) = grayFrame(:,:,:);
end


fprintf('Preparing mask sequence matrix\n');
MaskSequence = false(MatDimension(1), MatDimension(2), MatDimension(4));

fprintf('Generating pixel values matrix\n');
PixelValuesShortHistory = updatedVideo(:,:,1:N);

if (Selective ~= 0)
    fprintf('Generating pixel values index matrix\n');
    PixelValuesIndex = ones(MatDimension(1), MatDimension(2));
end


fprintf('Generating mask for each frame\n');
for i = N + 1 : MatDimension(4)
    
    [BackgroundMask, CurrentMask] = BackgroundMaskKDE(updatedVideo, N, i, Threshold, PixelValuesShortHistory);
    
    if (Selective == 1)
        UpdateIndices = find(~BackgroundMask);
        CurrentFrame = squeeze(updatedVideo(:,:,i));
        PixelValuesIndex(UpdateIndices);
        DimensionValues = PixelValuesIndex(UpdateIndices);
        
        % Calculate the indices of the values to update in the history
        % matrix
        IndicesInHistoryMatrix = UpdateIndices + (DimensionValues - 1)...
            * (MatDimension(1) * MatDimension(2));
        
        % Update the history matrix with values from the current frame
        PixelValuesShortHistory(IndicesInHistoryMatrix) = CurrentFrame(UpdateIndices);
        
        % Advance the indices in the relevant places
        
        PixelValuesIndex(UpdateIndices) = mod(PixelValuesIndex(UpdateIndices), N) + 1;
    else
        
        PixelValuesShortHistory = updatedVideo(:,:,i - N + 1:i);
        
        
    end
    
    MaskSequence(:,:,i) = CurrentMask(:,:);
end
%PixelValuesIndex


fprintf('Preparing Output\n');
if (O == 1)
    fprintf('Output is mask\n');
    %the result is all frames in MaskSequence which are white (= foreground)
    result = MaskSequence;
else
    fprintf('Output is frames\n');
    result(MaskSequence) = updatedVideo(MaskSequence);
    
end
fprintf('Finished!\n');
Res = result;
