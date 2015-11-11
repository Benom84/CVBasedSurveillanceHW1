function Background = UpdateBackgroundAverage(VideoMat, CurrentBackground, CurrentFrame,LearningRate, Selective, FrameChanges)
%{
Updates appearance of the background. Higher learning rate == the latest
frames are affecting faster.

- VideoMat : the newest frames.
- CurrentBackground : the current background that we are about to update.
- CurrentFrame : the current frame we are going to update the backgound
for.
- LearningRate : how strong the new frames are going to affect the
background. '0' is no effect, '1' is replacing the whole current background
with the new frames.
- Selective : 
- FrameChanges : 
%}
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
    
    