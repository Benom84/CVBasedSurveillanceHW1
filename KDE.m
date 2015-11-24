function Res = KDE(VideoMat,O,N,Threshold, Selective)
%NaiveBS(VideoMat,C,O,N,Mean,Threshold, Selective, LearningRate)
%This functino does the Naive Background Subtraction.
%input:
%- VideoMat : 4 dimension matrix of the form (height, width, # of color channels, frame #)
%- C : Can be 0 or 1. 1 means that the result will be truecolor, 0 means graystyle.
%- O : Define if output is the Mask (1) or frames(0)
%- N : Number of frames to do CreateBackgoundAverage on. (N >= 0)
%- Mean : 1 To use a mean to create the background and 0 to use median
%- Threshold : A number. The sensitivity factor for deciding if a pixel is background or foreground.
%- Selective :
%- LearningRate : determine the weight-ratio between the lastest frames and
%former frames. LearningRate > 0.5 meanes higher weight to new frames, where
%< 0.5 means lower.
%
%Usage exaple:
%

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
MaskSequence = zeros(MatDimension(1), MatDimension(2), MatDimension(4));

fprintf('Generating pixel values matrix\n');
PixelValues = updatedVideo(:,:,1:N);

if (Selective == 1)
    fprintf('Generating pixel values index matrix');
    PixelValuesIndex = ones(MatDimension(1), MatDimension(2));
end


fprintf('Generating mask for each frame\n');
for i = N + 1 : MatDimension(4)
    if (Selective == 1)
        CurrentMask = BackgroundMaskKDE(updatedVideo, N, i, Threshold, PixelValues, PixelValuesIndex);
    else
        CurrentMask = BackgroundMaskKDE(updatedVideo, N, i, Threshold, PixelValues);
    end
    MaskSequence(:,:,i) = CurrentMask(:,:);
end

fprintf('Preparing Output\n');
if (O == 1)
    fprintf('Output is mask\n');
    %the result is all frames in MaskSequence which are white (= foreground)
    result = reshape(MaskSequence == 255, [MatDimension(1) MatDimension(2) 1 MatDimension(4)]);
else
    fprintf('Output is frames\n'); 
    result(MaskSequence > 0) = updatedVideo(MaskSequence > 0);
    
end
fprintf('Finished!\n');
Res = result;
