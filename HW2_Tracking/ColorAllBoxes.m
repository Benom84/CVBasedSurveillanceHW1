function result = ColorAllBoxes( calculatedCurrentBB, BBHistory1, range )
%COLORALLBOXES Summary of this function goes here
%   Detailed explanation goes here

ColorRangeVector = (1 : range);
ColorRangeVector(ismember(ColorRangeVector, calculatedCurrentBB(:,6))) = [];
ColorRangeVector(ismember(ColorRangeVector, BBHistory1(:,6))) = [];
for i = 1 : size(calculatedCurrentBB, 1)
   if (calculatedCurrentBB(i,6) > 0)
       continue;
   end
   calculatedCurrentBB(i,6) = ColorRangeVector(1);
   ColorRangeVector(1) = [];
end

result = calculatedCurrentBB;

end

