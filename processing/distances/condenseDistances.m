function distances=condenseDistances(infoImages, distArray,distfields)
%%Condenses many structs of the type infoDistances into one, by copying all the NNDs and allDistances
%All other values except for the Distances will be copied from the first struct in the Array.

distances=distArray{1};


numImages = size(infoImages, 1);
for i=2:numel(distArray)
    for j=1:numImages
        for f=1:numel(distfields)
            distances{j}.(distfields{f})=[distances{j}.(distfields{f}); distArray{i}{j}.(distfields{f})];
        end
    end
end

