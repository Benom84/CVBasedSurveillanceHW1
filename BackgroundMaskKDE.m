function res = BackgroundMaskKDE(Video, NumberOfFrames, currentFrameIndex, Threshold, PixelValues, PixelValuesIndex)

if (nargs < 5)
    error('Must pass Video, NumberOfFrames, currentFrameIndex, Threshold, and PixelValues');
end
if (nargs < 6)
    Selective = 0;
else
    Selective = 1;
end

if (Selective == 0)
    UpdatedIndex = mod(currentFrameIndex, NumberOfFrames);
    differenceMatrix = PixelValues - repmat(squeeze(Video(:,:,currentFrameIndex)),[1,1,NumberOfFrames]);
end