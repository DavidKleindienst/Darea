%% Deprecated

function RandomOnebyOne(Data1,Data2,pathname, settings)
%As a control for one by one stats, computes random simulations against random simulations.
%Data1 will be compared against Data2, so Data2 should be the set from which percentages of Original files were computed

%Simplification
Simnames=Data1.simnames;
methodA=Data1.methodA;
methodB=Data1.methodB;
Groups=Data1.Groups;
names=Data1.names;
Orig=Data1.Orig;

statfct=settings.statfct;
pval=settings.pval/2;

%Check that these variables are same for Data2
if isequal(Simnames, Data2.simnames) && isequal(methodA, Data2.methodA) && isequaln(methodB, Data2.methodB) && isequal(Groups.names, Data2.Groups.names) && isequal(names, Data2.names) && isequal(Orig.Images, Data2.Orig.Images)
    disttype={'distances', 'allDistances'};
    Grplabels=['All Groups'; Groups.names];
    nrsims=[Data1.nrsim, Data2.nrsim];
    nrImg=numel(Orig.Images);
    for mode=1:2
        if (mode==1 && settings.makeNND) || (mode==2 && settings.makeAllDist)
            Imwise=cell(1,nrImg);
            for img=1:nrImg
                Imwise{img}.group=Orig.Images{img}.group;
                Imwise{img}.route=Orig.Images{img}.route;
                for b=1:numel(methodB)
                    for s=1:numel(Simnames)
                        for a=1:numel(methodA)
                            current1=Data1.(Simnames{s})(1,a);
                            current1=current1{1};
                            current2=Data2.(Simnames{s})(1,a);
                            current2=current2{1};
                            Imwise{img}.(Simnames{s}){a}.D1{b}=NaN(1,nrsims(1));
                            Imwise{img}.(Simnames{s}){a}.D2{b}=NaN(1,nrsims(2));
                            for n=1:nrsims(1)
                                Imwise{img}.(Simnames{s}){a}.D1{b}(n)=statfct(current1.IndivDist{b}{n}{img}.(disttype{mode}));                        
                            end
                            for n=1:nrsims(2)
                                Imwise{img}.(Simnames{s}){a}.D2{b}(n)=statfct(current2.IndivDist{b}{n}{img}.(disttype{mode}));
                            end
                            Imwise{img}.(Simnames{s}){a}.Significance{b}=NaN(1,nrsims(1));
                            simulated=Imwise{img}.(Simnames{s}){a}.D2{b};
                            for n=1:nrsims(1)
                                sample=Imwise{img}.(Simnames{s}){a}.D1{b}(n);
                                [Imwise{img}.(Simnames{s}){a}.Significance{b}(n), ~, ~]=getSignificance(sample, simulated, pval);
                            end

                        end
                    end
                end
            end

            if mode==1
                filename=[pathname, 'NND_randvsrand.csv'];
            elseif mode==2
                filename=[pathname, 'AllDist_randvsrand.csv'];
            end

            file=fopen(filename, 'wt');
            header='Original;Simulation;Percent Significant';
            for n=1:nrsims(1)-1
                header=[header ';'];
            end
            header=[header '\n'];
            fprintf(file, header);
            for g=0:Groups.number
                if g>0
                    indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
                else
                    indeces=1:nrImg;
                end

                for s=1:numel(Simnames)
                    for a=1:numel(methodA)
                        for b=1:numel(methodB)
                            nextline=[Grplabels{g+1} '-' getName(Data1, methodB{b}) ';' Simnames{s} getName(Data1,methodA{a})];
                            for n=1:nrsims(1)
                                Sigs=NaN(1,numel(indeces));
                                for img=1:numel(indeces)
                                    Sigs(img)=Imwise{indeces(img)}.(Simnames{s}){a}.Significance{b}(n);
                                end
                                nextline=[nextline ';' num2str(100*numel(Sigs(Sigs==1))/(numel(indeces) - numel(Sigs(isnan(Sigs)))))];
                            end
                            nextline=[nextline '\n'];
                            fprintf(file, nextline);
                        end
                    end
                end
            end
            fclose(file);
        end
    end
    
    
else
    fprintf('The two datasets were not made under same conditions!\nCannot carry out comparison');
    return
    
    
end

