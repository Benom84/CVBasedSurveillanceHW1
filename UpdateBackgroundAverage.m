function Background = UpdateBackgroundAverage(VideoMat, CurrentBackground, CurrentFrameNum,LearningRate, Mean, Selective, FrameChanges, N)
%{
Updates appearance of the background. Higher learning rate == the latest
frames are affecting faster.

- VideoMat : the newest frames.
- CurrentBackground : the current background that we are about to update.
- CurrentFrameNum : the current frame we are going to update the backgound
for.
- LearningRate : how strong the new frames are going to affect the
background. '0' is no effect, '1' is replacing the whole current background
with the new frames.
- Mean : 1 to use the learning rate update mechanism. 0 to use the median
system
- Selective :
- FrameChanges :
%}
if (nargin < 3)
    error('Must pass VideoMat, BackgroundAverage and CurrentFrameNum');
end
if (nargin < 4)
    LearningRate = 0.1;
end
if (nargin < 5)
    Mean = 1;
end
if (nargin < 6)
    Selective = 0;
end
if (nargin < 7 && Selective == 1)
    error('Cannot set Selective to true without FrameChanges');
end
if (nargin < 8 && Mean == 0)
    N = 30;
end

if (Mean == 1)
    if (Selective == 0)
        %If the update type is average we use learning rate
        result = squeeze(VideoMat(:,:,:,CurrentFrameNum)) * LearningRate...
            + CurrentBackground * (1 - LearningRate);
    else
        currentBackgroundLocation = (FrameChanges == 0);
        currentFrame = squeeze(VideoMat(:,:,:,CurrentFrameNum));
        result = CurrentBackground;
        result(currentBackgroundLocation) = currentFrame(currentBackgroundLocation) * LearningRate...
            + CurrentBackground(currentBackgroundLocation) * (1 - LearningRate);
    end
else
    if (Selective == 0)
        %If the update type is median we recalculate the median for the last N
        %frames
        StartingFrame = max(0, CurrentFrameNum - N);
        result = median(VideoMat(:,:,:,StartingFrame:CurrentFrameNum),4);
    else
        error('Must implement');
    end
end

Background = result;

