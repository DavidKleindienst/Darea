%% Deprecated

function [] = RandomOnebyOneCluster(Data1,Data2,pathname, settings)
%RANDOMONEBYONECLUSTER Summary of this function goes here
%   Detailed explanation goes here



%Simplification
Simnames=Data1.simnames;
methodA=Data1.methodA;
methodB=Data1.methodB;
Groups=Data1.Groups;
names=Data1.names;
Orig=Data1.Orig;
field=fields(Orig.ClusterInteraction{1}); 

statfct=settings.statfct;
pval=settings.pval/2;

%Check that these variables are same for Data2
if isequal(Simnames, Data2.simnames) && isequal(methodA, Data2.methodA) && isequaln(methodB, Data2.methodB) && isequal(Groups.names, Data2.Groups.names) && isequal(names, Data2.names) && isequal(Orig.Images, Data2.Orig.Images) && isequal(field, fields(Data2.Orig.ClusterInteraction{1}))
    Grplabels=['All Groups'; Groups.names];
    field=field(3:end);
    for f=1:numel(field)
        nrsims=[Data1.nrsim, Data2.nrsim];

        nrImg=numel(Orig.Images);
        Imwise=cell(1,nrImg);
        if numel(Orig.ClusterInteraction{1}.(field{f}))==numel(methodA)
            for img=1:nrImg
                Imwise{img}.group=Orig.Images{img}.group;
                Imwise{img}.route=Orig.Images{img}.route;
                for a=1:numel(methodA)
                    for s=1:numel(Simnames)
                        for sim=1:numel(methodA)
                            current1=Data1.(Simnames{s}){sim};
                            current2=Data2.(Simnames{s}){sim};
                            Imwise{img}.(Simnames{s}){sim}.D1{a}=NaN(1,nrsims(1));
                            Imwise{img}.(Simnames{s}){sim}.D2{a}=NaN(1,nrsims(2));
                            for n=1:nrsims(1)
                                Imwise{img}.(Simnames{s}){sim}.D1{a}(n)=statfct(current1.IndivClustInteraction{n}{img}.(field{f}){a});                        
                            end
                            for n=1:nrsims(2)
                                Imwise{img}.(Simnames{s}){sim}.D2{a}(n)=statfct(current2.IndivClustInteraction{n}{img}.(field{f}){a});
                            end
                            Imwise{img}.(Simnames{s}){sim}.Significance{a}=NaN(1,nrsims(1));
                            simulated=Imwise{img}.(Simnames{s}){sim}.D2{a};
                            for n=1:nrsims(1)
                                sample=Imwise{img}.(Simnames{s}){sim}.D1{a}(n);
                                [Imwise{img}.(Simnames{s}){sim}.Significance{a}(n), ~, ~]=getSignificance(sample, simulated, pval);
                            end
                        end
                    end
                end
            end
        else
            for a=1:numel(methodA)
                for b=1:numel(methodA)
                    if a~=b
                         for img=1:nrImg
                            Imwise{img}.group=Orig.Images{img}.group;
                            Imwise{img}.route=Orig.Images{img}.route;
                            for s=1:numel(Simnames)
                                for sim=1:numel(methodA)
                                    current1=Data1.(Simnames{s}){sim};
                                    current2=Data2.(Simnames{s}){sim};
                                    Imwise{img}.(Simnames{s}){sim}.D1{a,b}=NaN(1,nrsims(1));
                                    Imwise{img}.(Simnames{s}){sim}.D2{a,b}=NaN(1,nrsims(2));
                                    for n=1:nrsims(1)
                                        Imwise{img}.(Simnames{s}){sim}.D1{a,b}(n)=statfct(current1.IndivClustInteraction{n}{img}.(field{f}){a,b});                        
                                    end
                                    for n=1:nrsims(2)
                                        Imwise{img}.(Simnames{s}){sim}.D2{a,b}(n)=statfct(current2.IndivClustInteraction{n}{img}.(field{f}){a,b});
                                    end
                                    Imwise{img}.(Simnames{s}){sim}.Significance{a,b}=NaN(1,nrsims(1));
                                    simulated=Imwise{img}.(Simnames{s}){sim}.D2{a,b};
                                    for n=1:nrsims(1)
                                        sample=Imwise{img}.(Simnames{s}){sim}.D1{a,b}(n);
                                        [Imwise{img}.(Simnames{s}){sim}.Significance{a,b}(n), ~, ~]=getSignificance(sample, simulated, pval);
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        filename=[pathname, field{f}, '_randvsrand.csv'];
        file=fopen(filename, 'wt');
        header='Original;Simulation;Percent Significant';
        for n=1:nrsims(1)-1
            header=[header ';'];
        end
        header=[header '\n'];
        fprintf(file, header);
        if numel(Orig.ClusterInteraction{1}.(field{f}))==numel(methodA)
            for g=0:Groups.number
                if g>0
                    indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
                else
                    indeces=1:nrImg;
                end
                for s=1:numel(Simnames)
                    for sims=1:numel(methodA)
                        for a=1:numel(methodA)
                            nextline=[Grplabels{g+1} '-' getName(Data1, methodA{a}) ';' Simnames{s} getName(Data1,methodA{sims})];
                            for n=1:nrsims(1)
                                Sigs=NaN(1,numel(indeces));
                                for img=1:numel(indeces)
                                    Sigs(img)=Imwise{indeces(img)}.(Simnames{s}){sims}.Significance{a}(n);
                                end
                                nextline=[nextline ';' num2str(100*numel(Sigs(Sigs==1))/(numel(indeces) - numel(Sigs(isnan(Sigs)))))];
                            end
                            nextline=[nextline '\n'];
                            fprintf(file, nextline);
                        end
                    end
                end
            end
        else
            for a=1:numel(methodA)
                for b=1:numel(methodA)
                    if a~=b
                        for g=0:Groups.number
                            if g>0
                                indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
                            else
                                indeces=1:nrImg;
                            end
                            for s=1:numel(Simnames)
                                for sims=1:numel(methodA)
                                    nextline=[Grplabels{g+1} '-' getName(Data1, methodA{a}) '->' getName(Data1, methodA{b}) ';' Simnames{s} getName(Data1,methodA{sims})];
                                    for n=1:nrsims(1)
                                        Sigs=NaN(1,numel(indeces));
                                        for img=1:numel(indeces)
                                            Sigs(img)=Imwise{indeces(img)}.(Simnames{s}){sims}.Significance{a,b}(n);
                                        end
                                        nextline=[nextline ';' num2str(100*numel(Sigs(Sigs==1))/(numel(indeces) - numel(Sigs(isnan(Sigs)))))];
                                    end
                                    nextline=[nextline '\n'];
                                    fprintf(file, nextline);
                                    
                                end
                            end
                        end                        
                    end
                end
            end
        end
        fclose(file);
    end
    
    
else
    fprintf('The two datasets were not made under same conditions!\nCannot carry out comparison');
    return
end








end

