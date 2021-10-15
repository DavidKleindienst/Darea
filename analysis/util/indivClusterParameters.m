function indivClusterParameters(Data,indeces,fileName)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if isfield(Data.Orig.ClusterInteraction{1}, 'NumberOfClusters')
    properties1d= {'ParticlesPerCluster', 'ClusterArea', ...
                    'DensityWithinCluster', 'NNDbetweenSameSizeClusters',  ...
                    'distanceFromCenter', 'distanceFromEdge', 'normalizedDistanceFromCenter'};
    numberfield='NumberOfClusters';
    thresholdfield='maxDistance';
    properties2d={'Overlap_with_','NND_to_'};
else
    %For compatibility with files made by previous software version
    properties1d={'particles','area','density','intraDistance','distanceFromEdge'};
    numberfield='number';
    thresholdfield='thresholdDist';
    properties2d={'overlap','interDistance'};
end
excludedfield='excludedClusters';

for a=1:numel(Data.methodA)
    for s=0:numel(Data.simnames)
        for part=1:numel(Data.methodA) %Simulated particles
            if s==0 %Original
                if part>1
                    %No simulated particles in Original -> only run once
                    continue;
                end
                Clust=Data.Orig.ClusterInteraction;
                fid=fopen([fileName '_' getName(Data,Data.methodA{a}) '.csv'],'w');
            else
                Clust=Data.([Data.simnames{s} '_cond']){part}.ClusterInteraction;
                fid=fopen([fileName '_' getName(Data,Data.methodA{a}) '_' Data.simnames{s} getName(Data,Data.methodA{part}) '.csv'],'w');
            end
            for i=0:numel(indeces)
                if i==0
                    img=0;
                    nrClust=0;
                else
                    img=indeces(i);
                    nrClust=sum(Clust{img}.(numberfield){a});
                end
                for c=0:nrClust
                    if i==0   %Printing headers
                        fprintf(fid, 'Image Id;ClusterId;%s;%s;%s',numberfield,thresholdfield,excludedfield);
                    elseif c==0
                        fprintf(fid,'\n%g;mean;%g;%g;%g', Clust{img}.id, mean(Clust{img}.(numberfield){a}),...
                                mean(Clust{img}.(thresholdfield){a}),mean(Clust{img}.(excludedfield){a}));
                    else 
                        fprintf(fid,'\n;%g;;;', c);
                    end

                    for p=1:numel(properties1d)

                        if img==0
                            fprintf(fid,';%s', properties1d{p});
                        elseif c==0
                            fprintf(fid,';%g', mean(Clust{img}.(properties1d{p}){a}));
                        else
                            fprintf(fid,';%g', Clust{img}.(properties1d{p}){a}(c));
                        end
                    end

                    for p=1:numel(properties2d)

                        for aa=1:numel(Data.methodA)
                            %Second particle (e.g. 5->10)
                            if aa==a; continue; end     %5->5 distance not captured here
                            if img==0
                                fprintf(fid,';%s', [properties2d{p} getName(Data,Data.methodA{aa}) '_Cluster']);
                            elseif c==0
                                fprintf(fid,';%g', mean(Clust{img}.(properties2d{p}){a,aa}));
                            else 
                                fprintf(fid,';%g', Clust{img}.(properties2d{p}){a,aa}(c));
                            end
                        end
                        
                    end
                end    
            end
            fclose(fid);
        end
    end
end

end
