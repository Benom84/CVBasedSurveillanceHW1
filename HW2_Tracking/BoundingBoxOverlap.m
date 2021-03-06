function result = BoundingBoxOverlap(BBox1, BBox2)
%BoundingBoxOverlap(BBox1, BBox2) Checks whether 2 bounding boxes overlap
%at all


    BBox1XMin = BBox1(1);
    BBox1XMax = BBox1XMin + BBox1(3);
    BBox1YMin = BBox1(2);
    BBox1YMax = BBox1YMin + BBox1(4);
    
    BBox2XMin = BBox2(1);
    BBox2XMax = BBox2XMin + BBox2(3);
    BBox2YMin = BBox2(2);
    BBox2YMax = BBox2YMin + BBox2(4);

    result = 0;
    if ~((BBox1XMax < BBox2XMin) || (BBox1XMin > BBox2XMax))
        if ~((BBox1YMax < BBox2YMin) || (BBox1YMin > BBox2YMax))
            result = 1;
        end
    end
end