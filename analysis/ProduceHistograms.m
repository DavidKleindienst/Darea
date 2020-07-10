
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

function ProduceHistograms(Data, outp, settings)
%% Makes histograms of the Data
%Input parameters:
%Data - struct containing all the Data, made by performAnalysis()
%outp - path to output folder
%settings - settings defined by user (made in FiguresDialog, which will eventually also call this function)
fig=figure;
set(fig, 'CloseRequestFcn', '', 'visible', 'off');        %Don't allow user to close figure winow
ax=axes;

%Simplification
simtypes=Data.simnames;
Orig=Data.Orig;
Groups=Data.Groups;
methodA=Data.methodA;
methodB=Data.methodB;

nrImg=numel(Orig.Images);
nrGrp=Groups.number;
grpNames=Groups.names;

fields=settings.ClusterNames(:,1);
fieldnames=settings.ClusterNames(:,2);
mkdir(fullfile(outp, 'Histograms'));
outpath=fullfile(outp, 'Histograms', settings.Origname);
mkdir(outpath);



%% Make Distance Histograms for all groups and distances
for mode=1:2        %1 - NNDs; 2 - All Distances
if (mode==1 && settings.HistoOptions.makeNND) || (mode==2 && settings.HistoOptions.makeAllDist)
    if mode==1
        folder='histNNDs';
        distfield='distances';
    else
        folder='histAllDistances';
        distfield='allDistances';
    end    
    mkdir(fullfile(outpath, folder));
    for g=0:nrGrp               % Loop through all groups
        if g>0
            indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
            grpname=grpNames{g};
        else            %g=0 - all images
            indeces=1:nrImg;
            grpname=settings.allGroupsname;
        end
        for m=1:numel(methodB)      %For all types of distances (A->B, A->A, B->A, ...)
            distances=[];
            for ind=1:numel(indeces)    %for all images belonging to the group
                distances=[distances, Orig.Distance{m}{indeces(ind)}.(distfield)'];
            end
            distances(isnan(distances))=[];     %Delete NaN values if they exist
            %plot histogram
            
            h=histogram(ax,distances);
            changeAppearance(ax, settings.HistoOptions);
            changeHistoAppearance(h, settings.HistoOptions);
            %Put labels and save
            xlabel(ax,settings.HistoOptions.xlabeling);
            ylabel(ax,settings.HistoOptions.ylabeling);
            name=[grpname ' - ' getName(Data,methodB{m})];
            title(ax,name);
            savePlot(fig,fullfile(outpath, folder, name), settings.figformat);
        end

    end
end
end

%% Make Histograms for cluster  parameters for all groups and particles
if settings.HistoOptions.makeCluster
    mkdir(fullfile(outpath, 'histCluster'));
    for f=1:numel(fields)           %for all cluster parameters
        for g=0:nrGrp               % For all groups
            if g>0
                indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
                grpname=grpNames{g};
            else            %g=0 - all images
                indeces=1:nrImg;        
                grpname=settings.allGroupsname;
            end
            for i=1:numel(methodA)      %For all particle sizes
                if numel(Orig.ClusterInteraction{indeces(1)}.(fields{f}))==numel(methodA)       %Cluster parameter depends on one type of particle
                    variable=[];
                    for ind=1:numel(indeces)        %For all images that belong to the group
                        %add cluster parameters
                        variable=[variable, Orig.ClusterInteraction{indeces(ind)}.(fields{f}){i}];
                    end
                    variable(isnan(variable))=[];
                    %Plot and change style according to user settings
                    
                    h=histogram(ax, variable);
                    changeAppearance(ax, settings.HistoOptions);
                    changeHistoAppearance(h, settings.HistoOptions);
                    if strcmp(settings.HistoOptions.Orientation, 'vertical')
                        xlabel(ax,fieldnames{f});
                        ylabel(ax,settings.HistoOptions.ylabeling);
                    else
                        xlabel(ax,settings.HistoOptions.xlabeling);
                        ylabel(ax,fieldnames{f});
                    end
                    name=[grpname ' - ' getName(Data,methodA{i})];
                    title(ax,name);
                    savePlot(fig,fullfile(outpath, 'histCluster', [name ' - ' fieldnames{f}]), settings.figformat);
                else            %Cluster parameter depends on two types of particles
                    for j=1:numel(methodA)
                        if i~=j
                            variable=[];
                            for ind=1:numel(indeces)        %for all images belonging to the group
                                %add cluster parameters
                                variable=[variable, Orig.ClusterInteraction{indeces(ind)}.(fields{f}){i,j}];
                            end
                            variable(isnan(variable))=[];
                            %Plot and style figure according to user settings.
                            
                            h=histogram(ax, variable);
                            changeAppearance(ax, settings.HistoOptions);
                            changeHistoAppearance(h, settings.HistoOptions);
                            if strcmp(settings.HistoOptions.Orientation, 'vertical')
                                xlabel(ax,fieldnames{f});
                                ylabel(ax,settings.HistoOptions.ylabeling);
                            else
                                xlabel(ax,settings.HistoOptions.xlabeling);
                                ylabel(ax,fieldnames{f});
                            end
                            name=[grpname ' - ' getName(Data,methodA{i})];
                            title(ax,name);
                            savePlot(fig,fullfile(outpath, 'histCluster', [name ' - ' fieldnames{f} '_' getName(Data,methodA{j})]), settings.figformat);
                        end
                    end
                end
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Repeat everything for the simulations %%    
    
for sim=1:numel(simtypes)      %For all types of simulation
    for sims=1:numel(methodA)   %For all simulated particles
        outpath=fullfile(outp, [settings.SimNames{sim} '-' getName(Data, methodA{sims})]);
        mkdir(outpath);
        current=Data.([simtypes{sim} '_cond']){sims};       %Simulation for which histograms are made in that loop
        for mode=1:2        %1 - NND; 2 - All Distances
            if (mode==1 && settings.HistoOptions.makeNND) || (mode==2 && settings.HistoOptions.makeAllDist)
                if mode==1
                    folder='histNNDs';
                    distfield='distances';
                else
                    folder='histAllDistances';
                    distfield='allDistances';
                end
                mkdir(fullfile(outpath,folder));
                for g=0:nrGrp               % Loop through all groups
                    if g>0
                        indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
                        grpname=grpNames{g};
                    else                %g=0 - all images
                        indeces=1:nrImg;
                        grpname=settings.allGroupsname;

                    end
                    for m=1:numel(methodB)      %For all types of Distances (A->A, A->B, B->A, ...)
                        distances=[];
                        for ind=1:numel(indeces)        %For all images belonging to group
                            %Add distances
                            distances=[distances, current.Distance{m}{indeces(ind)}.(distfield)'];
                        end
                        distances(isnan(distances))=[];     %Delete NaN values
                        %Make plot and save
                        
                        h=histogram(ax, distances);
                        changeAppearance(ax, settings.HistoOptions);       
                        changeHistoAppearance(h, settings.HistoOptions);
                        xlabel(ax,settings.HistoOptions.xlabeling);
                        ylabel(ax,settings.HistoOptions.ylabeling);

                        name=[grpname ' - ' getName(Data,methodB{m})];
                        title(ax,name);
                        savePlot(fig,fullfile(outpath, folder, name), settings.figformat);
                    end
                end
            end
        end
    


    %% Make Histograms for cluster parameters for all groups 
        if settings.HistoOptions.makeCluster
            mkdir(fullfile(outpath, 'histCluster'));
            for f=1:numel(fields)       %For all cluster parameters
                for g=0:nrGrp               % Loop through all groups
                    if g>0
                        indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
                        grpname=grpNames{g};
                    else            %g=0 - all images
                        indeces=1:nrImg;
                        grpname=settings.allGroupsname;
                    end
                    if numel(current.ClusterInteraction{1}.(fields{f}))==numel(methodA)     %Cluster parameter depends on one type of particle
                        for i=1:numel(methodA)      %for all particle sizes
                            variable=[];
                            for ind=1:numel(indeces)        %for all images belonging to group
                                %add cluster parameters
                                variable=[variable, current.ClusterInteraction{indeces(ind)}.(fields{f}){i}];
                            end
                        end
                        variable(isnan(variable))=[];       %Delete NaN values (if they exist)
                        %Plot and save
                        
                        h=histogram(ax, variable);
                        changeAppearance(ax, settings.HistoOptions);       
                        changeHistoAppearance(h, settings.HistoOptions);
                        if strcmp(settings.HistoOptions.Orientation, 'vertical')
                            xlabel(ax,fieldnames{f});
                            ylabel(ax,settings.HistoOptions.ylabeling);
                        else
                            xlabel(ax,settings.HistoOptions.xlabeling);
                            ylabel(ax,fieldnames{f});
                        end
                        name=[grpname ' - ' getName(Data, methodA{i})];
                        title(ax,name);
                        savePlot(fig,fullfile(outpath, 'histCluster', [name ' - ' fieldnames{f}]), settings.figformat);
                    else            %Cluster parameter depends on two types of particles
                        for j=1:numel(methodA) 
                            for i=1:numel(methodA)      %For all interactions between two particle types 
                                if i~=j                 %(A->B, B->A, but not A->A)
                                    variable=[];
                                    for ind=1:numel(indeces)    %For all images belonging to group
                                        %add cluster parameters
                                        variable=[variable, current.ClusterInteraction{indeces(ind)}.(fields{f}){i,j}];
                                    end
                                    variable(isnan(variable))=[];       %Remove NaN values if they exist
                                    %Plot and save
                                    
                                    h=histogram(ax, variable);
                                    changeAppearance(ax, settings.HistoOptions);       
                                    changeHistoAppearance(h, settings.HistoOptions);
                                     if strcmp(settings.HistoOptions.Orientation, 'vertical')
                                        xlabel(ax,fieldnames{f});
                                        ylabel(ax,settings.HistoOptions.ylabeling);
                                    else
                                        xlabel(ax,settings.HistoOptions.xlabeling);
                                        ylabel(ax,fieldnames{f});
                                    end
                                    name=[grpname ' - ' getName(Data, methodA{i})];
                                    title(ax,name);
                                    savePlot(fig,fullfile(outpath, 'histCluster', [name ' - ' fieldnames{f} '_' getName(Data,methodA{j})]), settings.figformat);
                                end
                            end
                        end
                    end
                end   
            end
        end
    end
end
    
delete(fig);   %Close figure window
    
end