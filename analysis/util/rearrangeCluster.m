function Cluster = rearrangeCluster(Data,ClusterInteraction,simname,grpname,indeces,fields,i)
%% Rearrange Cluster parameters into a struct that makes it easy to compute statistics from

%Some identifying infromation
Cluster.groupname=grpname;
Cluster.simulation=simname;
Cluster.particlename=getName(Data,Data.methodA{i});
Cluster.name=[Cluster.simulation '-' Cluster.groupname '-' Cluster.particlename];

for f=1:numel(fields)   % For all cluster parameters
    if numel(ClusterInteraction{indeces(1)}.(fields{f}))==numel(Data.methodA) %Everything except for overlap and InterclusterDistance
        variable=[];
        for ind=1:numel(indeces)
            variable=[variable, ClusterInteraction{indeces(ind)}.(fields{f}){i}];
        end
        Cluster.(fields{f})=variable;
        try
            [~, L]=lillietest(variable);
        catch
            L=NaN;      %Not enough observations
        end
        Cluster.([fields{f} '_lil'])=L;
    else %Overlap and NND_to different size cluster
        for j=1:numel(Data.methodA)
            if j~=i
                variable=[];
                for ind=1:numel(indeces)
                    variable=[variable, ClusterInteraction{indeces(ind)}.(fields{f}){i,j}];
                end
                fieldname=[fields{f} getName(Data,Data.methodA{j}) '_Cluster'];
                Cluster.(fieldname)=variable;
                try
                    [~, L]=lillietest(variable);
                catch
                    L=NaN;      %Not enough observations
                end
                Cluster.([fieldname '_lil'])=L;
            end
        end
    end
end
end

