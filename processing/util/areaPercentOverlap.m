function percentOverlap=areaPercentOverlap(polyA,polyB)
% Computes the percentage of the Area of polygon polyA that is occupied by polygon polyB
% Returns NaN any input polygon has less than 3 points
overlap=areaOverlap(polyA,polyB);   %gets the Area of the overlapping polygon
if isnan(overlap)
    percentOverlap=NaN;
else
    chA=convhull(polyA(:,1),polyA(:,2));
    areaA=polyarea(polyA(chA,1),polyA(chA,2));      %Computes the Area of polygon A
    percentOverlap=(overlap/areaA);                 %Gets the percentage
end