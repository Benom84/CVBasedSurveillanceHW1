function normalizedBBHist = NormalizedHistogramBB( BB,  frame, bins)
%NORMALIZEDHISTOGRAMBB( BB,  frame) Get the normalized histogram of a
%bounding box inside a colored image frame

currX = BB(1); currY = BB(2); currW = BB(3);
currH = BB(4);
BBImage = double(frame(currY : currY + currH - 1, currX : currX + currW - 1, :));
BBImage(:,:,2) = BBImage(:,:,2) + 256;
BBImage(:,:,3) = BBImage(:,:,3) + 512;
BBHist = hist(BBImage(:), bins);
normalizedBBHist = BBHist / norm(BBHist);

end

