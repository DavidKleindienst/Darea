function indivClusterParameters(Data,indeces,fileName)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

properties1d={'number','particles','area','density','intraDistance','excludedClusters','thresholdDist','distanceFromEdge'};
properties2d={'overlap','interDistance'};
for s=0:numel(Data.simnames)
    for part=1:numel(Data.methodA) %Simulated particles
        if s==0 %Original
            if part>1
                %No simulated particles in Original -> only run once
                continue;
            end
            Clust=Data.Orig.ClusterInteraction;
            fid=fopen([fileName '.csv'],'w');
        else
            Clust=Data.([Data.simnames{s} '_cond']){part}.ClusterInteraction;
            fid=fopen([fileName '_' Data.simnames{s} '.csv'],'w');
        end
        for i=0:numel(indeces)
            if i==0   %Printing headers
                img=0;
                fprintf(fid, 'Image Id');
            else
                img=indeces(i);
                fprintf(fid,'\n%g', Clust{img}.id);
            end

            for p=1:numel(properties1d)
                for a=1:numel(Data.methodA)
                    if img==0
                        fprintf(fid,';%s', [properties1d{p} '_' getName(Data,Data.methodA{a})]);
                    else
                        fprintf(fid,';%g', mean(Clust{img}.(properties1d{p}){a}));
                    end
                end
            end

            for p=1:numel(properties2d)
                for a=1:numel(Data.methodA)
                    
                    for aa=1:numel(Data.methodA)
                        if aa==a; continue; end
                        if img==0
                            fprintf(fid,';%s', [properties2d{p} '_' getName(Data,Data.methodA{a}) ' to ' getName(Data,Data.methodA{aa})]);
                        else
                            fprintf(fid,';%g', mean(Clust{img}.(properties2d{p}){a,aa}));
                        end
                    end
                end
            end
        end
    end
end

end
