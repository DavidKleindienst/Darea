function thresholdDistance = computeClusteringThreshold(infoImages,infoDistance,infoGroups,methodA,methodB,settings)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if strcmp(settings.maxDist{1}, 'SD')    %Compute and save Clustering threshold
    switch settings.ClusterOptions.Clustering
        case 1      %All together
            AllparticleDistances=getInfoDistances(infoImages, 'all', NaN, false, false);    
            statsDistances = nearestParticleStats(AllparticleDistances);
            thresholdDistance = statsDistances(3) + statsDistances(4)*settings.maxDist{2};
        case 2      %Particles individually
            thresholdDistance=cell(1,numel(methodA));
            for i=1:numel(methodA)
                searchcell={methodA{i}, NaN};              %Searches for the right index of the Distance info for each particle
                index=cellfun(@(cell) isequaln(cell, searchcell), methodB);
                statsDistances = nearestParticleStats(infoDistance{index});
                thresholdDistance{i} = statsDistances(3) + statsDistances(4)*settings.maxDist{2};
            end  
        case 3      %Groups individually
            thresholdDistance=cell(infoGroups.number,1);
            for i=1:infoGroups.number
                AllparticleDistances=getInfoDistances(infoImages, 'all', NaN,false, false);    
                indeces=infoGroups.imgGroup==i;          %Find indeces of the images belonging to each group
                statsDistances=nearestParticleStats(AllparticleDistances(indeces));
                thresholdDistance{i}=statsDistances(3) + statsDistances(4)*settings.maxDist{2};
            end   
        case 4      %Particles and Groups individually
            thresholdDistance=cell(infoGroups.number,numel(methodA));
            for i=1:infoGroups.number
                for j=1:numel(methodA)
                    indeces=infoGroups.imgGroup==i;
                    searchcell={methodA{j}, NaN};              %Searches for the right index of the Distance info for each particle
                    index=cellfun(@(cell) isequaln(cell, searchcell), methodB);
                    statsDistances=nearestParticleStats(infoDistance{index}(indeces));
                    thresholdDistance{i,j}=statsDistances(3) + statsDistances(4)*settings.maxDist{2};
                end
            end      
    end       
else
    thresholdDistance=settings.maxDist{2};      %ThresholdDistance was given in nm by User
end
end

