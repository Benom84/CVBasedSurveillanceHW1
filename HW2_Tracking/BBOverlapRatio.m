function result = BBOverlapRatio(BBox1, BBox2)
%BoundingBoxOverlap(BBox1, BBox2) Checks how much 2 bounding boxes overlap
%0 = not at all, 1 - perfect overlap

    BBox1XMin = BBox1(1);
    BBox1XMax = BBox1XMin + BBox1(3);
    BBox1YMin = BBox1(2);
    BBox1YMax = BBox1YMin + BBox1(4);
    
    BBox2XMin = BBox2(1);
    BBox2XMax = BBox2XMin + BBox2(3);
    BBox2YMin = BBox2(2);
    BBox2YMax = BBox2YMin + BBox2(4);
    
    sumOfBB = BBox1(3) * BBox1(4) + BBox2(3) * BBox2(4);
    xOverlap = max(0, min(BBox1XMax, BBox2XMax) - max(BBox1XMin, BBox2XMin));
    yOverlap = max(0, min(BBox1YMax, BBox2YMax) - max(BBox1YMin, BBox2YMin));
    sharedArea = xOverlap * yOverlap;
    if (sharedArea <= 0)
        result = 0;
    else
       result =  2*double(sharedArea) / double(sumOfBB);
    end
end