function distances = allDistances2Sets(set1, set2, varargin)
%Computes distances between all pairs of particles made up of one particle of set1 and one particle of set2.
%Returns NaN, if no such pair exists


if size(set1,1)==0 || size(set2,1)==0
    distances=NaN;
    return
end

distmatrix=pdist2(set1,set2);
distances=nonzeros(distmatrix);

end

