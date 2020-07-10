function Distances = rearrangeDistances(Data,Distance,simname,grpname,indeces,i)
%% Rearrange Distances in a way that's easy to compute statistics from

%Some identifying infromation
Distances.groupname=grpname;
Distances.simulation=simname;
Distances.particlename=getName(Data,Data.methodB{i});
Distances.methB=Data.methodB{i};
Distances.name=[Distances.simulation '-' Distances.groupname '-' Distances.particlename];
%For each type of distance save all Observations and compute liliefors test
for d=1:numel(Data.distfields)
    distances=[];
    for ind=1:numel(indeces)        % For all images belonging to the respective group
        distances=[distances, Distance{i}{indeces(ind)}.(Data.distfields{d})'];
    end
    Distances.(Data.distfields{d})=distances;
    try
        [~, L]=lillietest(distances);
    catch
        L=NaN;      %Not enough observations
    end
    Distances.([Data.distfields{d} '_lil'])=L;
end
end

