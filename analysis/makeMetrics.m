function makeMetrics(Data,outpath,settings,dist_names)
%% Computes following parameters:
% Area of the Area of interest (AoI)
% Number and Density of Particles in AoI
% Correlations between particle numbers of different radii
% Correlation between particle numbers and size of AoI
% Input parameters:
% Data - struct containing all the Data. This is made by performAnalysis
% outp - path to output folder
% settings - User defined settings as made by FiguresDialog, which also calls this function. 
% dist_names - Cell array with names for each distance type

%Some simplification
radi=Data.methodA;

Groups=Data.Groups;
Images=Data.Orig.Images;
Distance=Data.Orig.Distance;
nrImg=numel(Images);
nrGrp=Groups.number;
grpNames=Groups.names;


safeMkdir(outpath)

header='Group;Particlename;Mean number;Std Number;SEM Number;Mean Area;Std Area;SEM Area;Mean Density;Std Density;SEM Density;NrImages\n';
filename=fullfile(outpath, 'Metrics.csv');
safeMkdir(fullfile(outpath, 'ClusterParameters'));
file=fopen(filename,'wt');
fprintf(file,header);
for g=0:nrGrp   %Go through all Groups (g=0 means pool all groups)
    if g>0
        indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
        grpname=grpNames{g};
    else        %g=0 - all images
        indeces=1:nrImg;
        grpname='All Groups';
    end
    
    
    area=zeros(1,numel(indeces));
    particles=zeros(numel(radi),numel(indeces));
    for i=1:numel(indeces)                  %Read out Area and
        area(i)=Images{indeces(i)}.area;
        for r=1:numel(radi)                 %number of particles
            if strcmp(radi{r},'all')
                particles(r,i)=numel(Images{indeces(i)}.teorRadii);
            else
                particles(r,i)=numel(Images{indeces(i)}.teorRadii(Images{indeces(i)}.teorRadii==radi{r}));
            end
        end
    end
    if settings.StatisticsOptions.makeIndiv
        indivDir=fullfile(outpath,'individual_Metrics');
        safeMkdir(indivDir);
        fileName=fullfile(indivDir, [grpname '.csv']);
        fid=fopen(fileName,'w');
        %Write header.
        fprintf(fid,'Image Id;Area');
        for r=1:numel(radi)
            fprintf(fid,';%s;%s', getName(Data,radi{r}), ['Density' getName(Data,radi{r})]);        %Write particle names
        end
        fprintf(fid,'\n');
        %Write values for each image
        for i=1:numel(indeces)
            fprintf(fid,'%i;%g',Images{indeces(i)}.id, area(i));                  %Write areas
            for r=1:numel(radi)
                fprintf(fid,';%i;%g', particles(r,i),particles(r,i)/(area(i)));
            end
            if i<numel(indeces)
                fprintf(fid,'\n');
            end
        end
        fclose(fid);
        %Individual values for center and edge distances
        for b=1:numel(Data.methodB)
            indivDir=fullfile(outpath,'individual_Distances');
            safeMkdir(indivDir);
            fileName=fullfile(indivDir, [grpname '-' getName(Data,Data.methodB{b}) '.csv']);
            indivDistances(Data,Distance,fileName,dist_names,indeces,b);

            %Also for simulations
            for s=1:numel(Data.simnames)
                for a=1:numel(Data.methodA)
                    fileName=fullfile(indivDir, [Data.simnames{s} '_' getName(Data,Data.methodA{a}) '-' grpname '-' getName(Data,Data.methodB{b}) '.csv']);
                    SimDist=Data.([Data.simnames{s} '_cond']){a}.Distance;
                    indivDistances(Data,SimDist,fileName,dist_names,indeces,b);
                end
            end
        end
        %For cluster parameters
        indivDir=fullfile(outpath,'individual_ClusterParameters');
        safeMkdir(indivDir);
        indivClusterParameters(Data,indeces,fullfile(indivDir, grpname));
        
    end
        
    if settings.StatisticsOptions.makeCorrel
        mkdir(fullfile(outpath,'plots'));
        %Make a scatter plot for particle nr vs particle nr
        if numel(radi)>1
           %Needs to get adapted for more than 2 radii!!!
        fig=figure('visible','off');
        ax=axes;
        scatter(ax,particles(1,:),particles(2,:));     
        xlabel(ax,getName(Data,radi{1}));
        ylabel(ax,getName(Data,radi{2}));
        title(ax,grpname);
        savePlot(fig,fullfile(outpath,'plots', ['Correl_' grpname]), settings.figformat);
        close(fig);
        end
        for r=1:numel(radi)
            %Scatter plot for particle nr vs area
            fig=figure('visible','off');
            ax=axes;
            scatter(ax,area, particles(r,:));         
            xlabel('Area');
            ylabel(ax,getName(Data,radi{r}));
            title(ax,grpname)
            savePlot(fig,fullfile(outpath,'plots', ['SizeCorell_' getName(Data,radi{r}) '_' grpname]), settings.figformat);
            close(fig);
        end
    end
    for r=1:numel(radi)
        %define Nr as particle number and Dens as density, and write to file
        Nr=particles(r,:);
        Dens=Nr./area;    %to scale at particles per square micron
        fprintf(file, '%s;%s;%f;%f;%f;%f;%f;%f;%f;%f;%f;%d\n',grpname, getName(Data,radi{r}), mean(Nr), std(Nr), sem(Nr), mean(area), std(area), sem(area), mean(Dens), std(Dens), sem(Dens), numel(indeces));
    end
end
end

