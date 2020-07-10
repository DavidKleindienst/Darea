%
% Copyright (C) 2015 Javier C??zar (*), David Kleindienst (#), Luis de la Ossa (*), Jes??s Mart??nez (*) and Rafael Luj??n (+).
%
%   (*) Intelligent Systems and Data Mining research group - I3A -Computing Systems Department
%       University of Castilla-La Mancha - Albacete - Spain
%
%   (#) Institute of Science and Technology (IST) Austria - Klosterneuburg - Austria
%
%   (+) Celular Neurobiology Lab - Faculty of Medicine
%       University of Castilla-La Mancha - Albacete - Spain
%
%  Contact: Luis de la Ossa: luis.delaossa@uclm.es
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


function MakeStatistics(Data,outpath,settings,dist_names)
%% Computes Statistics according to the settings
%outp: path to output folder
%settings: Settings set by makeFigures.m
% dist_names - Cell array with names for each distance type

%Simplification
simtypes=Data.simnames;
Groups=Data.Groups;
Orig=Data.Orig;
methodA=Data.methodA;
methodB=Data.methodB;

clustdir=fullfile(outpath, 'ClusterParameters');
distdir=fullfile(outpath, 'Distances');
safeMkdir(outpath);
safeMkdir(clustdir);
safeMkdir(distdir);



nrImg=numel(Orig.Images);
nrGrp=Groups.number;
grpNames=Groups.names;

fields=settings.ClusterNames(:,1);


nonDataFields={'groupname', 'simulation', 'particlename', 'name'};   %Fields that don't contain data, but are used for identification
%% Rearrange Data first to make it easier to process later
Cluster=cell(1,(numel(methodA)*(nrGrp+1))*(numel(simtypes)*numel(methodA)+1));
NNDs=cell(1,(numel(methodA)*(nrGrp+1))*(numel(simtypes)*numel(methodA)+1));
%% Original
for g=0:nrGrp               % For all groups
    if g>0
        indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
        grpname=grpNames{g};
    else
        indeces=1:nrImg;
        grpname=settings.allGroupsname;
    end
    if settings.StatisticsOptions.makeCluster
        for i=1:numel(methodA)      %For all particle sizes
            Cluster{g*numel(methodA)+i}=rearrangeCluster(Data,Orig.ClusterInteraction,settings.Origname,grpname,indeces,fields,i);
        end
    end
    if settings.StatisticsOptions.makeNND || settings.StatisticsOptions.makeAllDist || settings.StatisticsOptions.makeDistEdge
        for i=1:numel(methodB)
            NNDs{g*numel(methodB)+i}=rearrangeDistances(Data,Orig.Distance,settings.Origname,grpname,indeces,i);
        end
    end
end
cind=numel(methodA)*(nrGrp+1)+1;
nind=numel(methodB)*(nrGrp+1)+1;
%% Simulation
for sim=1:numel(simtypes) %For all types of simulations
    for sims=1:numel(methodA)   %For all particles being simulated
        current=Data.([simtypes{sim} '_cond']){sims};
        for g=0:nrGrp               % For all groups
            if g>0
                indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
                grpname=grpNames{g};
            else
                indeces=1:nrImg;
                grpname=settings.allGroupsname;
            end
            if settings.StatisticsOptions.makeCluster
                for i=1:numel(methodA) %For all particle sizes
                    Cluster{cind}=rearrangeCluster(Data,current.ClusterInteraction,[settings.SimNames{sim} getName(Data,methodA{sims})],grpname,indeces,fields,i);
                    cind=cind+1;
                end
            end
            if settings.StatisticsOptions.makeNND || settings.StatisticsOptions.makeAllDist || settings.StatisticsOptions.makeDistEdge
                for i=1:numel(methodB)
                    NNDs{nind}=rearrangeDistances(Data,current.Distance,[settings.SimNames{sim} getName(Data,methodA{sims})], grpname,indeces,i);
                    nind=nind+1;
                end
            end
        end
    end
end

fields=fieldnames(Cluster{1}); %Redefine fields, because new fields have probably been added
for i=2:numel(Cluster)
    fields=union(fields, fieldnames(Cluster{i}));        %Make sure we're not missing any fieldnames
end
fields=fields(~endsWith(fields,'_lil')); %Remove fieldnames containing lillietest results

header_descript='Name;mean;STD;SEM;Median;N\n';
header_analyt='Name1;Name2;Lilliefors1;Lilliefors2;t-test;U-test;Kolmogorov-Smirnov;N1;N2\n';

%% Now Generate the Statistics
if settings.StatisticsOptions.makeCluster
for f=1:numel(fields)
    if ~ismember(fields{f}, nonDataFields)
    if settings.StatisticsOptions.makeDescriptive
    %% Generate Descriptive Statistics
        filename=fullfile(clustdir, [fields{f} '_descriptiveStats.csv']);
        file = fopen(filename,'w');
        fprintf(file, header_descript);
        for i=1:numel(Cluster)
            if isfield(Cluster{i}, fields{f})
                variable=Cluster{i}.(fields{f});
                variable(isnan(variable))=[];
                fprintf(file, '%s;%g;%g;%g;%g;%i\n', Cluster{i}.name, mean(variable), std(variable), sem(variable), median(variable),length(variable));
            end
        end
        fclose(file);
    end
    if settings.StatisticsOptions.makeAnalytics
    %% Generate analytical statistics
        filename=fullfile(clustdir, [fields{f} '_analyticStats.csv']);
        file = fopen(filename,'w');
        fprintf(file, header_analyt);
        for i=1:numel(Cluster) %For all pairs of clusters (loop 1)
            if isfield(Cluster{i}, fields{f})
                for j=i+1:numel(Cluster) %For all pairs of clusters (loop 2)
                    if isfield(Cluster{j}, fields{f})
                        Cluster1=Cluster{i}.(fields{f});
                        L1=Cluster{i}.([fields{f} '_lil']);
                        Cluster1(isnan(Cluster1))=[];
                        Cluster2=Cluster{j}.(fields{f});
                        L2=Cluster{j}.([fields{f} '_lil']);
                        Cluster2(isnan(Cluster2))=[];

                        if numel(Cluster1)>3 && numel(Cluster2)>3
                            %get p-values for a couple of statistical tests
                            [~,T]=ttest2(Cluster1, Cluster2);   %T-Test
                            U=ranksum(Cluster1, Cluster2);      %Mann-Whitney U-Test
                            [~,KS]=kstest2(Cluster1, Cluster2); %Kolmogorov-Smirnov Test
                            fprintf(file, '%s;%s;%g;%g;%g;%g;%g;%i;%i\n', Cluster{i}.name, Cluster{j}.name, L1, L2, T, U, KS, numel(Cluster1),numel(Cluster2));
                        else
                            fprintf(file, '%s;%s;%g;%g;%g;%g;%g;%i;%i\n', Cluster{i}.name, Cluster{j}.name, NaN, NaN, NaN, NaN, NaN, numel(Cluster1), numel(Cluster2));
                        end
                    end
                end
            end
        end
        fclose(file);
    end
    end
end
end


%% Statistics for NNDs
for mode=1:numel(Data.distfields)
        distfield=Data.distfields{mode};
        
        if settings.StatisticsOptions.makeDescriptive
        %% Generate Descriptive statistics
            filename=fullfile(distdir, [dist_names{mode} '_descriptiveStats.csv']);
            file = fopen(filename,'w');
            fprintf(file, header_descript);
            for i=1:numel(NNDs)
                if (Data.isPairedField(mode) || isnan(NNDs{i}.methB{2}))
                    distances=NNDs{i}.(distfield);
                    distances(isnan(distances))=[];
                    fprintf(file, '%s;%g;%g;%g;%g;%g\n', NNDs{i}.name, mean(distances), std(distances), sem(distances), median(distances),length(distances));
                end
            end
            fclose(file);
        end
        if settings.StatisticsOptions.makeAnalytics
        %% Generate Analytic Statistics
            filename=fullfile(distdir, [dist_names{mode} '_analyticStats.csv']);
            file = fopen(filename,'w');
            fprintf(file, header_analyt);
            for i=1:numel(NNDs)
                for j=i+1:numel(NNDs)
                    if  (Data.isPairedField(mode) || (isnan(NNDs{i}.methB{2}) && isnan(NNDs{j}.methB{2})))
                        distances1=NNDs{i}.(distfield);
                        L1=NNDs{i}.([distfield '_lil']);
                        distances1(isnan(distances1))=[];
                        distances2=NNDs{j}.(distfield);
                        L2=NNDs{j}.([distfield '_lil']);
                        distances2(isnan(distances2))=[];
                        N1=numel(distances1);
                        N2=numel(distances2);
                        if numel(distances1)>3 && numel(distances2)>3
                            [~,T]=ttest2(distances1, distances2);
                            U=ranksum(distances1, distances2);
                            [~,KS]=kstest2(distances1, distances2);
                            fprintf(file, '%s;%s;%g;%g;%g;%g;%g;%i;%i\n', NNDs{i}.name, NNDs{j}.name, L1, L2, T, U, KS,N1,N2);
                        else
                            fprintf(file, '%s;%s;%g;%g;%g;%g;%g;%i;%i\n', NNDs{i}.name, NNDs{j}.name, NaN, NaN, NaN, NaN, NaN,N1,N2);
                        end
                    end
                end
            end
            fclose(file);
        end
    %end
end

%% Run One by One and population mean Analysis when appropriate
if ~isempty(Data.simnames) %If simulations were made
if settings.StatisticsOptions.make1by1 && isfield(Data, simtypes{1})       %2nd question checks whether individual simulations have been saved
    if settings.StatisticsOptions.makeNND || settings.StatisticsOptions.makeAllDist || settings.StatisticsOptions.makeDistEdge
        oneByOneStats(Data, settings, distdir,dist_names);
    end
    if settings.StatisticsOptions.makeCluster
        oneByOneCluster(Data,settings,clustdir);
    end
end
if settings.StatisticsOptions.ImageWisePopMeans && isfield(Data, simtypes{1}) %2nd question checks whether individual simulations have been saved
    if settings.StatisticsOptions.makeNND || settings.StatisticsOptions.makeAllDist || settings.StatisticsOptions.makeDistEdge
        StatPopMeans(Data, settings, distdir,dist_names);
    end
    if settings.StatisticsOptions.makeCluster
        StatPopMeansCluster(Data,settings,clustdir);
    end
end
end
end