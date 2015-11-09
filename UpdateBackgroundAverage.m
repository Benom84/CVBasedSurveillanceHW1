function Background = UpdateBackgroundAverage(VideoMat, CurrentBackground, CurrentFrame,LearningRate, Selective, FrameChanges)

if (nargin < 3)
    error('Must pass VideoMat, BackgroundAverage and CurrentFrame');
end
if (nargin < 4)
    LearningRate = 0.1;
end
if (nargin < 5)
    Selective = 0;
end
if (nargin < 6 && Selective == 1)
    error('Cannot set Selective to true without FrameChanges');
end

if (Selective == 0)
    result = squeeze(VideoMat(:,:,:,CurrentFrame)) * LearningRate...
        + CurrentBackground * (1 - LearningRate);
else
    error('Must implement');
end

Background = result;
    
    