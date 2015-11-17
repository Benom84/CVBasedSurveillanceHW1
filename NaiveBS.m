function Res = NaiveBS(VideoMat,C,O,N,Mean,Threshold, Selective, LearningRate)

%{
This functino does the Naive Background Subtraction.
input:
- VideoMat : 4 dimension matrix of the form (height, width, # of color channels, frame #)
- C : Can be 0 or 1. 1 means that the result will be truecolor, 0 means graystyle.
- O : Define if output is the Binary (1) or color-dependent(0)
- N : Number of frames to do CreateBackgoundAverage on. (N >= 0)
- Mean : 
- Threshold : A number. The sensitivity factor for deciding if a pixel is background or foreground.
- Selective : 
- LearningRate : determine the weight-ratio between the lastest frames and
former frames. LearningRate > 0.5 meanes higher weight to new frames, where
< 0.5 means lower.

Usage exaple:
%}

MatDimension = size(VideoMat);
%If we choose color images the dimensions are the same, otherwise only gray level.
%We will preallocate memory to increase performance.
fprintf('Starting...\n');
if (C == 1)
    fprintf('Preparing color result matrix\n');
    result = uint8(zeros(MatDimension(1), MatDimension(2), 3, MatDimension(4)));
    updatedVideo = VideoMat;
else
    fprintf('Preparing gray result matrix\n');
    result = uint8(zeros(MatDimension(1), MatDimension(2), 1, MatDimension(4)));
    
    %Transform the entire video to gray levels
    updatedVideo = uint8(zeros(MatDimension(1), MatDimension(2), 1, MatDimension(4)));
    fprintf('Modifying the movie to gray levels\n');
    for i = 1:MatDimension(4)
        grayFrame = rgb2gray(squeeze(VideoMat(:,:,:,i)));
        updatedVideo(:,:,:,i) = grayFrame(:,:,:);
    end
end

fprintf('Creating background average\n');
%Create background average from the first N frames.
BackgroundAverage = CreateBackgroundAverage(updatedVideo, N, Mean);
fprintf('Preparing mask sequence matrix\n');
MaskSequence = uint8(zeros(MatDimension(1), MatDimension(2), MatDimension(4)));

fprintf('Generating mask for each frame\n');
for i = 1 : MatDimension(4)
    %Create mask for every frame.
    CurrentMask = BackgroundMask(updatedVideo, BackgroundAverage, i, Threshold);
    MaskSequence(:,:,i) = CurrentMask(:,:);
    
    %For the frames after the Nth, we need to update background, by the
    %formula given in the lectures.
    if (i > N)
        BackgroundAverage = UpdateBackgroundAverage(updatedVideo, BackgroundAverage, i, LearningRate, Mean, Selective, squeeze(MaskSequence(:,:,i)), N);
    end
end

fprintf('Preparing Output\n');
if (O == 1)
    fprintf('Output is mask\n');
    %the result is all frames in MaskSequence which are white (= foreground)
    result = reshape(MaskSequence == 255, [MatDimension(1) MatDimension(2) 1 MatDimension(4)]);
else
    fprintf('Output is frames\n');
    if (C == 1)
        %If it is a color output we need to take the mask and duplicate the
        %3rd dimension 3 times. We do this by creating a vector from the
        %matrix and then refolding it to a matrix
        ColorMaskSequence = reshape(MaskSequence, MatDimension(1)*MatDimension(2), []);
        ColorMaskSequence = reshape(repmat(ColorMaskSequence,3,1),...
            [MatDimension(1) MatDimension(2) 3 MatDimension(4)]);
        result(ColorMaskSequence > 0) = updatedVideo(ColorMaskSequence > 0);

    else
        result(MaskSequence > 0) = updatedVideo(MaskSequence > 0);
    end
end
fprintf('Finished!\n');
Res = result;
