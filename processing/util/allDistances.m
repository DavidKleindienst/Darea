function distances = allDistances(points)
%% Computes pairwise Distances between all points.
%Returns a vector distances, which length is equal to the possible pairs of points.
%Returns NaN, if there are less than 2 points

if size(points,1) <=1
    distances = NaN;
    return
end

distmatrix=dist(points');       %Resulting distance matrix is symmetrical
distmatrix=triu(distmatrix);    %Only take upper triangle, because otherwise each distance would be counted twice
distances=nonzeros(distmatrix); %Take all non-zero elements (0 corresponds to comparison of each particle with itself)



end

