function centroid = BBToCentroid( BB )
%BBCENTROID Summary of this function goes here
%   Detailed explanation goes here

    centerX = BB(1) + floor(BB(3)/2);
    centerY = BB(2) + floor(BB(4)/2);
    centroid = [centerX centerY];
end

