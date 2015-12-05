function Res = NaiveBS(VideoMat,C,O,N,Mean,Threshold, LearningRate)
%NaiveBS(VideoMat,C,O,N,Mean,Threshold, Selective, LearningRate)
%This functino does the Naive Background Subtraction.
%input:
%- VideoMat : 4 dimension matrix of the form (height, width, # of color channels, frame #)
%- C : Can be 0 or 1. 1 means that the result will be truecolor, 0 means graystyle.
%- O : Define if output is the Mask (1) or frames(0)
%- N : Number of frames to do CreateBackgoundAverage on. (N >= 0)
%- Mean : 1 To use a mean to create the background and 0 to use median
%- Threshold : A number. The sensitivity factor for deciding if a pixel is background or foreground.
%- LearningRate : determine the weight-ratio between the lastest frames and
%former frames. LearningRate > 0.5 meanes higher weight to new frames, where
%< 0.5 means lower.
%

if (mod(N, 2) == 0)
    N = N + 1; %Median is 30 times faster for odd numbers
end
MatDimension = size(VideoMat);
%If we choose color images the dimensions are the same, otherwise only gray level.
%We will preallocate memory to increase performance.
fprintf('Starting Naive Background Subtraction...\n');
if (C == 1)
    fprintf('Preparing color result matrix\n');
    result = zeros(MatDimension(1), MatDimension(2), 3, MatDimension(4), 'uint8');
    
    %This is important one: on one side, the video itself is in the "uint8"
    %range. On the other, we can't perform subtraction correctly on uint8
    %because there are no negative values, and when performing 50 - 90, the
    %result is 0 and not -40. And we need the absolute value. Therefore we
    %are using INT16 representation which can hold both all the color range
    %and negative values.
    updatedVideo = int16(VideoMat);
else
    fprintf('Preparing gray result matrix\n');
    result = zeros(MatDimension(1), MatDimension(2), 1, MatDimension(4), 'uint8');
    
    %Transform the entire video to gray levels
    updatedVideo = zeros(MatDimension(1), MatDimension(2), 1, MatDimension(4), 'int16');
    fprintf('Modifying the movie to gray levels\n');
    for i = 1:MatDimension(4)
        grayFrame = rgb2gray(squeeze(VideoMat(:,:,:,i)));
        updatedVideo(:,:,:,i) = grayFrame(:,:,:);
    end
end

fprintf('Creating background average\n');
BackgroundAverage = CreateBackgroundAverage(updatedVideo, N, Mean);
fprintf('Preparing mask sequence matrix\n');
MaskSequence = false(MatDimension(1), MatDimension(2), MatDimension(4));

fprintf('Generating mask for each frame\n');
for i = 1 : MatDimension(4)
    CurrentMask = BackgroundMask(updatedVideo, BackgroundAverage, i, Threshold);
    MaskSequence(:,:,i) = CurrentMask(:,:);
    if (i > N)
        BackgroundAverage = UpdateBackgroundAverage(updatedVideo, BackgroundAverage, i, LearningRate, Mean, N);
    end
end

fprintf('Preparing Output\n');
if (O == 1)
    fprintf('Output is mask\n');
    %the result is all frames in MaskSequence which are white (= foreground)
    %result = reshape(MaskSequence == true, [MatDimension(1) MatDimension(2) 1 MatDimension(4)]);
    result = MaskSequence;
else
    fprintf('Output is frames\n');
    if (C == 1)
        %If it is a color output we need to take the mask and duplicate the
        %3rd dimension 3 times. We do this by creating a vector from the
        %matrix and then refolding it to a matrix
        ColorMaskSequence = reshape(MaskSequence, MatDimension(1) * MatDimension(2), []);
        ColorMaskSequence = reshape(repmat(ColorMaskSequence,3,1),...
            [MatDimension(1) MatDimension(2) 3 MatDimension(4)]);
        result(ColorMaskSequence > 0) = updatedVideo(ColorMaskSequence > 0);

    else
        result(MaskSequence) = updatedVideo(MaskSequence);
    end
end
fprintf('Finished!\n');
Res = result;
