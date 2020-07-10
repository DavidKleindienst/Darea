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
function ProduceCumProb(Data, outp, settings)
%% Produces cumulative probability plots from the Data
%Data are pooled over all images and simulations of the same type
%input parameters:
%Data - struct containing the Data produced by performAnalysis()
%outp - path to output folder
%settings - user defined parameters specifying a lot of things (for example appearance of the plot)

fig=figure;
set(fig, 'CloseRequestFcn', '','visible','off');      %Do not allow user to close the figure window
ax=axes;

%Simplification
simtypes=Data.simnames;
Groups=Data.Groups;
Orig=Data.Orig;
methodA=Data.methodA;
methodB=Data.methodB;
nrImg=numel(Orig.Images);
nrGrp=Groups.number;
grpNames=Groups.names;
unwantedGroupTraces=settings.CumProbOptions.unwantedGroupTraces;
unwantedNNDTraces=settings.CumProbOptions.unwantedNNDTraces;
unwantedClusterTraces=settings.CumProbOptions.unwantedClusterTraces;
unwantedSimulationTraces=settings.CumProbOptions.unwantedSimulationTraces;

allGroupsname=settings.allGroupsname;

fields=settings.ClusterNames(:,1);
fieldname=settings.ClusterNames(:,2);
outpath=fullfile(outp, 'Orig');
mkdir(outpath);

set(groot, 'defaultAxesColorOrder', settings.CumProbOptions.colorscheme);   %Set colorscheme

%% Make cumulative probability plots comparing groups
for mode=1:2    %1 - NND; 2 - All Distances
if (mode==1 && settings.CumProbOptions.makeNND) || (mode==2 && settings.CumProbOptions.makeAllDist)
    if mode==1
        folder='CumProbNND/';
        distfield='distances';
    else
        folder='CumProbAllDistances/';
        distfield='allDistances';
    end
    mkdir(fullfile(outpath, folder));
    for m=1:numel(methodB)          
        cpl={};         %Cell array for plot handles
        holdpoint=0;        %holdpoint=0 because groups start being counted from 0, used for determining when hold on command needs to be done
        Grplabels=[allGroupsname; grpNames]';
        to_be_removed=[];
        for g=0:nrGrp       %For all groups <-- This is the distinction between different traces of same figure
            if g>0
                indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
            else        %g==0 -> all groups together
                indeces=1:nrImg;
            end

            distances=[];
            for ind=1:numel(indeces)    %For all images belonging to the respective group
                %add the distances
                distances=[distances, Orig.Distance{m}{indeces(ind)}.(distfield)'];
            end
            distances(isnan(distances))=[];
            if isempty(distances) || ismember(Grplabels(g+1), unwantedGroupTraces) %If this group is not plotted (because no data or unwanted)
                holdpoint=holdpoint+1;          %increase holdpoint by one, to make the hold on command one group later
                to_be_removed=[to_be_removed, g+1];     %and flag for removal
            else
                
                cpl{end+1}=cdfplot_ax(ax,distances);
            end
            if g==holdpoint         %Hold on command should come after the first plotted trace, 
                hold on             %since some traces are not ploted, the holdpoint is needed to determine when.
            end
        end
        hold off
        %change appearance (coloring, linewidth, ... according to user set parameters)
        changeAppearance(ax, settings.CumProbOptions);
        changeCumProbAppearance(cpl, settings.CumProbOptions);
        Grplabels(to_be_removed)=[];        %Remove groups flagged for removal
        %Title, legend, x and y axis labels & saving
        title(ax, getName(Data, methodB{m}));
        legend(ax, Grplabels, 'Location', 'southeast', 'Box', settings.CumProbOptions.LegendBox, 'LineWidth', settings.CumProbOptions.LegendLineWidth, 'LineWidth', settings.CumProbOptions.LegendLineWidth);
        ylabel(ax, settings.CumProbOptions.ylabeling);
        xlabel(ax, settings.CumProbOptions.xlabeling);
        savePlot(fig, fullfile(outpath, folder, getName(Data, methodB{m})), settings.figformat);
    end
%% Make cumulative probability plots comparing different types of distances
    Grplabels=[allGroupsname; grpNames]';

    for g=0:nrGrp     %For all groups    
        Namelabels=cell(1,numel(methodB));
        if g>0
            indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
        else        %g==0  - sum of all groups
            indeces=1:nrImg;
        end
        holdpoint=1; %holdpoint=0 because distances start being counted from 1, used for determining when hold on command needs to be done
        to_be_removed=[];
        cpl={};     %Cell array that will be filled with cumulative prob. plot handle
        for m=1:numel(methodB)      %For all types of distances  <-- This is the distinction between different traces of same figure
            Namelabels{m}=getName(Data, methodB{m});

            distances=[];
            for ind=1:numel(indeces)  %For all images belonging to the respective group
                %add the distances
                distances=[distances, Orig.Distance{m}{indeces(ind)}.(distfield)'];
            end
            distances(isnan(distances))=[];
            if isempty(distances) || ismember(Namelabels{m}, unwantedNNDTraces)     %If this group is not plotted (because no data or unwanted)
                holdpoint=holdpoint+1;               %increase holdpoint by one, to make the hold on command one group later
                to_be_removed=[to_be_removed, m];       %and flag for removal 
            else
                %
                cpl{end+1}=cdfplot_ax(ax,distances);  %Make plot
            end

            if m==holdpoint         %Hold on command should come after the first plotted trace, 
                hold on             %since some traces are not ploted, the holdpoint is needed to determine when.
            end
        end
    hold off
    %change appearance (coloring, linewidth, ... according to user set parameters)
    changeAppearance(ax, settings.CumProbOptions)
    changeCumProbAppearance(cpl, settings.CumProbOptions);
    Namelabels(to_be_removed)=[];       %Remove Distances flagged for removal
    %Title, legend, x and y axis labels & saving
    title(ax, Grplabels{g+1});
    legend(ax, Namelabels, 'Location', 'southeast', 'Box', settings.CumProbOptions.LegendBox, 'LineWidth', settings.CumProbOptions.LegendLineWidth);
    ylabel(ax, settings.CumProbOptions.ylabeling);
    xlabel(ax, settings.CumProbOptions.xlabeling);
    savePlot(fig, fullfile(outpath, folder, Grplabels{g+1}), settings.figformat);
    end
end
end

%% Cumulative probability plots for cluster parameters comparing groups
if settings.CumProbOptions.makeCluster
    mkdir(fullfile(outpath, 'CumProbCluster'));
    for i=1:numel(methodA)          %For all particle sizes
        for f=1:numel(fields)       %For all particle parameters
            if numel(Orig.ClusterInteraction{1}.(fields{f}))==numel(methodA)        %Cluster parameters that only depend on one particle size
                holdpoint=0;
                Grplabels=[allGroupsname; grpNames]';
                to_be_removed=[];
                cpl={};
                for g=0:nrGrp       %for all groups <-- This is the distinction between different traces of same figure
                    if g>0
                        indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
                    else        %g=0 - sum over all groups
                        indeces=1:nrImg;
                    end

                    variable=[];
                    for ind=1:numel(indeces)        %For all images belonging to the respective group
                        %add the cluster parameters
                        variable=[variable, Orig.ClusterInteraction{indeces(ind)}.(fields{f}){i}];
                    end

                    variable(isnan(variable))=[];
                    if isempty(variable) || ismember(Grplabels{g+1}, unwantedGroupTraces)
                        holdpoint=holdpoint+1;
                        to_be_removed=[to_be_removed, g+1];
                    else
                        %plot
                        
                        cpl{end+1}=cdfplot_ax(ax,variable);
                    end
                    if g==holdpoint         %Set hold on after the first trace is plotted
                        hold on
                    end
                end

                hold off
                %Change Figure appearance based on user settings
                changeAppearance(ax, settings.CumProbOptions)
                changeCumProbAppearance(cpl, settings.CumProbOptions);
                Grplabels(to_be_removed)=[];
                %Title, legend, axis labels, saving
                title(ax, getName(Data,methodA{i}));
                legend(ax, Grplabels, 'Location', 'southeast', 'Box', settings.CumProbOptions.LegendBox, 'LineWidth', settings.CumProbOptions.LegendLineWidth);
                ylabel(ax, settings.CumProbOptions.ylabeling);
                xlabel(ax, fieldname{f});
                savePlot(fig, fullfile(outpath, 'CumProbCluster', [getName(Data,methodA{i}) '-' fieldname{f}]), settings.figformat);
            else
                for j=1:numel(methodA)      %Cluster paramaters depending on two particle sizes
                    if i~=j
                        holdpoint=0;
                        Grplabels=[allGroupsname; grpNames]';
                        to_be_removed=[];
                        cpl={};
                        for g=0:nrGrp       %For all groups   <-- This is the distinction between different traces of same figure
                            if g>0
                                indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
                            else            %g=0 - all images
                                indeces=1:nrImg;
                            end
                            variable=[];
                            for ind=1:numel(indeces)    %for all images belonging to the group
                                %add the cluster parameters
                                variable=[variable, Orig.ClusterInteraction{indeces(ind)}.(fields{f}){i,j}];
                            end
                            variable(isnan(variable))=[];
                            if isempty(variable) || ismember(Grplabels{g+1}, unwantedGroupTraces)
                                holdpoint=holdpoint+1;
                                to_be_removed=[to_be_removed, g+1];
                            else
                                
                                cpl{end+1}=cdfplot_ax(ax,variable);
                            end
                            if g==holdpoint         %set hold on after first trace is plotted
                                hold on
                            end 
                        end
                        hold off
                        %change figure appearance based on user settings
                        changeAppearance(ax, settings.CumProbOptions)
                        changeCumProbAppearance(cpl, settings.CumProbOptions);
                        Grplabels(to_be_removed)=[];
                        %Title, axis labels, legend, saving
                        title(ax, getName(Data,methodA{i}));
                        legend(ax, Grplabels, 'Location', 'southeast', 'Box', settings.CumProbOptions.LegendBox, 'LineWidth', settings.CumProbOptions.LegendLineWidth);
                        ylabel(ax, settings.CumProbOptions.ylabeling);
                        xlabel(ax, fieldname{f});
                        savePlot(fig, fullfile(outpath, 'CumProbCluster', [getName(Data,methodA{i}) '-' fieldname{f} '_' getName(Data,methodA{j})]), settings.figformat);
                    end
                end
            end
        end
    end


%% Cumulative probability plots for cluster paramters comparing particle sizes
    Grplabels=[allGroupsname; grpNames]';
    for f=1:numel(fields)       %for all cluster parameters
        for g=0:nrGrp          %for all groups
            if g>0
                indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
            else        %group=0 - all images
                indeces=1:nrImg;
            end
            if numel(Orig.ClusterInteraction{indeces(1)}.(fields{f}))==numel(methodA)       %Cluster parameters depending only on one particlesize
                Namelabels=cell(1,numel(methodA));
                holdpoint=1;
                to_be_removed=[];
                cpl={};     %Cell array for cumulative prob. plot handles
                for i=1:numel(methodA)      %For all particle sizes  <-- This is the distinction between different traces of same figure
                    Namelabels{i}=getName(Data, methodA{i});
                    variable=[];
                    for ind=1:numel(indeces)        %For all images belonging to the group
                        %add cluster parameters
                        variable=[variable, Orig.ClusterInteraction{indeces(ind)}.(fields{f}){i}];
                    end
                    variable(isnan(variable))=[];
                    if isempty(variable) || ismember(Namelabels{i}, unwantedClusterTraces)            %%If the variable is empty or the trace is not wanted by user, don't plot it and remove it from the labels
                        holdpoint=holdpoint+1;
                        to_be_removed=[to_be_removed, i];
                    else
                                %plot trace
                        cpl{end+1}=cdfplot_ax(ax,variable);
                    end
                    if i==holdpoint         %if first plotted trace of that figure
                        hold on
                    end
                end
                hold off
                %change figure appearance
                changeAppearance(ax, settings.CumProbOptions)
                changeCumProbAppearance(cpl, settings.CumProbOptions);
                %Labels, Legend and saving
                Namelabels(to_be_removed)=[];
                title(ax, Grplabels{g+1});
                legend(ax, Namelabels, 'Location', 'southeast', 'Box', settings.CumProbOptions.LegendBox, 'LineWidth', settings.CumProbOptions.LegendLineWidth);
                ylabel(ax, settings.CumProbOptions.ylabeling);
                xlabel(ax, fieldname{f});
                savePlot(fig, fullfile(outpath, 'CumProbCluster', [Grplabels{g+1} ' - ' fieldname{f}]), settings.figformat);
            else
                for j=1:numel(methodA)      %Cluster parameters depending on two particles sizes
                    Namelabels=cell(1,numel(methodA));
                    if j==1         %because i!=j (i will be compared to holdpoint)
                        holdpoint=2;
                    else
                        holdpoint=1;
                    end
                    to_be_removed=[];
                    cpl={};         %Cell array for plot handles
                    for i=1:numel(methodA)      %For all particle sizes  <-- This is the distinction between different traces of same figure
                        if i~=j
                            Namelabels{i}=getName(Data, methodA{i});
                            variable=[];
                            for ind=1:numel(indeces)        %For all images of that group
                                %add cluster parameters
                                variable=[variable, Orig.ClusterInteraction{indeces(ind)}.(fields{f}){i,j}];
                            end
                            variable(isnan(variable))=[];
                            if isempty(variable) || ismember(Namelabels{i}, unwantedClusterTraces)            %%If the variable is empty, don't plot it and remove it from the labels
                                holdpoint=holdpoint+1;
                                if holdpoint==j
                                    holdpoint=holdpoint+1;
                                end
                                to_be_removed=[to_be_removed, i];
                            else        
                                %plot
                                
                                cpl{end+1}=cdfplot_ax(ax,variable);
                            end

                            if i==holdpoint         %If it was first trace, set hold on
                                hold on
                            end
                        end
                    end
                    hold off
                    %Change Figure appearance according to user settings
                    changeAppearance(ax, settings.CumProbOptions);
                    changeCumProbAppearance(cpl, settings.CumProbOptions);
                    %Labels, legend, saving
                    Namelabels(to_be_removed)=[];       %remove unwanted cells
                    Namelabels=Namelabels(~cellfun('isempty', Namelabels));     %Remove cells that remained empty because i~=j
                    title(ax, Grplabels{g+1});
                    legend(ax, Namelabels, 'Location', 'southeast', 'Box', settings.CumProbOptions.LegendBox, 'LineWidth', settings.CumProbOptions.LegendLineWidth);
                    ylabel(ax, settings.CumProbOptions.ylabeling);
                    xlabel(ax, fieldname{f});

                    savePlot(fig, fullfile(outpath, 'CumProbCluster', [Grplabels{g+1} ' - ' fieldname{f} '_' getName(Data,methodA{j})]), settings.figformat);    

                end
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Repeat everything for the simulations %%    
    
for sim=1:numel(simtypes)       %For all types of simulations
    for sims=1:numel(methodA)   %For all simulated particles sizes
        current=Data.([simtypes{sim} '_cond']){sims};   %Simplification
        outpath=fullfile(outp, [settings.SimNames{sim} '-' getName(Data, methodA{sims})]);
        mkdir(outpath);
        
%% Make cumulative probability plots comparing groups for Distances
        for mode=1:2        %1 - NND, 2 - All Distances
        if (mode==1 && settings.CumProbOptions.makeNND) || (mode==2 && settings.CumProbOptions.makeAllDist)
            if mode==1
                folder='CumProbNND/';
                distfield='distances';
            else
                distfield='allDistances';
                folder='CumProbAllDist/';
            end
            
            mkdir(fullfile(outpath, folder));
            for m=1:numel(methodB)          %Cumulative probability plots comparing groups
                holdpoint=0;        
                Grplabels=[allGroupsname; grpNames]';
                to_be_removed=[];
                cpl={};         %plot handles
                for g=0:nrGrp       %For all groups
                    if g>0
                        indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
                    else        %g=0 - all images
                        indeces=1:nrImg;
                    end
                    
                    distances=[];
                    for ind=1:numel(indeces)        %For all images belonging to the group
                        %Add the distances
                        distances=[distances, current.Distance{m}{indeces(ind)}.(distfield)'];
                    end
                    distances(isnan(distances))=[];
                    if isempty(distances) || ismember(Grplabels{g+1}, unwantedGroupTraces)            %%If the variable is empty or unwanted, don't plot it and remove it from the labels
                        holdpoint=holdpoint+1;
                        to_be_removed=[to_be_removed, g+1];
                    else
                        %plot
                        
                        cpl{end+1}=cdfplot_ax(ax,distances);
                    end

                    if g==holdpoint         %After first trace, hold on
                        hold on
                    end
                end
                Grplabels(to_be_removed)=[];
                hold off
                %Change figure appearance based on user settings
                changeAppearance(ax, settings.CumProbOptions)
                changeCumProbAppearance(cpl, settings.CumProbOptions);
                %Labels and saving
                title(ax, getName(Data, methodB{m}));
                legend(ax, Grplabels, 'Location', 'southeast', 'Box', settings.CumProbOptions.LegendBox, 'LineWidth', settings.CumProbOptions.LegendLineWidth);
                ylabel(ax, settings.CumProbOptions.ylabeling);
                xlabel(ax, settings.CumProbOptions.xlabeling);
                savePlot(fig, fullfile(outpath, folder, getName(Data, methodB{m})), settings.figformat);
            end
        %% Make cumulative probability plots comparing distances between different particles
            Grplabels=[allGroupsname; grpNames]';
            for g=0:nrGrp          %For all groups
                Namelabels=cell(1,numel(methodB));
                if g>0
                    indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
                else    %g=0 - All images
                    indeces=1:nrImg;
                end
                holdpoint=1;
                to_be_removed=[];
                cpl={};     %plot handles
                for m=1:numel(methodB)      %for all types of distances
                    Namelabels{m}=getName(Data, methodB{m});

                    distances=[];
                    for ind=1:numel(indeces)        %For all images belonging to the group
                        distances=[distances, current.Distance{m}{indeces(ind)}.(distfield)'];
                    end
                    distances(isnan(distances))=[];
                    if isempty(distances) || ismember(Namelabels{m}, unwantedNNDTraces)            %%If the variable is empty or unwanted, don't plot it and remove it from the labels
                        holdpoint=holdpoint+1;
                        to_be_removed=[to_be_removed, m];
                    else
                        %plot
                        
                        cpl{end+1}=cdfplot_ax(ax,distances);
                    end
                    if m==holdpoint         %After first plotted trace, hold on
                        hold on
                    end
                end
            hold off
            %Change appearance according to user settings
            changeAppearance(ax, settings.CumProbOptions)
            changeCumProbAppearance(cpl, settings.CumProbOptions);
            %Labels & Saving
            Namelabels(to_be_removed)=[];
            title(ax, Grplabels{g+1});
            legend(ax, Namelabels, 'Location', 'southeast', 'Box', settings.CumProbOptions.LegendBox, 'LineWidth', settings.CumProbOptions.LegendLineWidth);
            ylabel(ax, settings.CumProbOptions.ylabeling);
            xlabel(ax, settings.CumProbOptions.xlabeling);
            savePlot(fig, fullfile(outpath, folder, Grplabels{g+1}), settings.figformat);
            end
        end
        end

    %% Cumulative probability plots for cluster parameters comparing groups

        if settings.CumProbOptions.makeCluster
            mkdir(fullfile(outpath, 'CumProbCluster'));
            for i=1:numel(methodA)          %For all particle sizes
                for f=1:numel(fields)       %For all cluster parameters
                    if numel(current.ClusterInteraction{1}.(fields{f}))==numel(methodA)     %Cluster parameters depending on one particle size
                        cpl={};     %handles for plots
                        holdpoint=0;
                        Grplabels=[allGroupsname; grpNames]';
                        to_be_removed=[];
                        for g=0:nrGrp       %For all groups <- This is the distinction between traces
                            if g>0
                                indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
                            else
                                indeces=1:nrImg;
                            end

                            variable=[];
                            for ind=1:numel(indeces)    %For all images belonging to group
                                %Add cluster parameters
                                variable=[variable, current.ClusterInteraction{indeces(ind)}.(fields{f}){i}];
                            end

                            variable(isnan(variable))=[];
                            if isempty(variable) || ismember(Grplabels{g+1}, unwantedGroupTraces)           %%If the variable is empty or unwanted, don't plot it and remove it from the labels
                                holdpoint=holdpoint+1;
                                to_be_removed=[to_be_removed, g+1];
                            else
                                %plot
                                
                                cpl{end+1}=cdfplot_ax(ax,variable);
                            end

                            if g==holdpoint %After first plotted trace, hold on
                                hold on
                            end
                        end

                        hold off
                        %Change figure style according to user settings
                        changeAppearance(ax, settings.CumProbOptions)
                        changeCumProbAppearance(cpl, settings.CumProbOptions);
                        Grplabels(to_be_removed)=[];
                        %Label & Save
                        title(ax, getName(Data, methodA{i}));
                        legend(ax, Grplabels, 'Location', 'southeast', 'Box', settings.CumProbOptions.LegendBox, 'LineWidth', settings.CumProbOptions.LegendLineWidth);
                        ylabel(ax, settings.CumProbOptions.ylabeling);
                        xlabel(ax, fieldname{f});
                        savePlot(fig, fullfile(outpath, 'CumProbCluster', [getName(Data, methodA{i}) '-' fieldname{f}]), settings.figformat);
                    else        %Cluster parameters depend on two particle sizes
                        for j=1:numel(methodA)
                            if i~=j
                                holdpoint=0;
                                Grplabels=[allGroupsname; grpNames]';
                                to_be_removed=[];
                                cpl={};
                                for g=0:nrGrp       %For all groups  <- this is the distinction between traces of same image
                                    if g>0
                                        indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
                                    else        %g=0 - all images
                                        indeces=1:nrImg;
                                    end

                                    variable=[];
                                    for ind=1:numel(indeces)        %For all images belonging to the group
                                        %Add cluster parameters
                                        variable=[variable, current.ClusterInteraction{indeces(ind)}.(fields{f}){i,j}];
                                    end
                                    variable(isnan(variable))=[];
                                    if isempty(variable) || ismember(Grplabels{g+1}, unwantedGroupTraces)    %%If the variable is empty or unwanted, don't plot it and remove it from the labels
                                        holdpoint=holdpoint+1;
                                        to_be_removed=[to_be_removed, g+1];
                                    else
                                        %plot
                                        
                                        cpl{end+1}=cdfplot_ax(ax,variable);
                                    end

                                    if g==holdpoint         %Set hold on after first plotted trace
                                        hold on
                                    end
                                end

                                hold off
                                %Change figure style according to user settings
                                changeAppearance(ax, settings.CumProbOptions)
                                changeCumProbAppearance(cpl, settings.CumProbOptions);
                                Grplabels(to_be_removed)=[];
                                %Label & Save
                                title(ax, getName(Data,methodA{i}));
                                legend(ax, Grplabels, 'Location', 'southeast', 'Box', settings.CumProbOptions.LegendBox, 'LineWidth', settings.CumProbOptions.LegendLineWidth);
                                ylabel(ax, settings.CumProbOptions.ylabeling);
                                xlabel(ax, fieldname{f});
                                savePlot(fig, fullfile(outpath, 'CumProbCluster', [getName(Data, methodA{i}) '-' fieldname{f} '_' getName(Data,methodA{j})]), settings.figformat);
                            end
                        end
                    end
                end
            end


        %% Cumulative probability plots for clusters comparing particles
            Grplabels=[allGroupsname; grpNames]';
            for f=1:numel(fields)
                for g=0:nrGrp          %For all groups

                    if g>0
                        indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
                    else        %g=0 - all images
                        indeces=1:nrImg;
                    end
                    if numel(current.ClusterInteraction{indeces(1)}.(fields{f}))==numel(methodA)    %Cluster parameter depends on one kind of particles
                        Namelabels=cell(1,numel(methodA));
                        holdpoint=1;
                        to_be_removed=[];
                        cpl={};     %Cumulative prob. plot handles
                        for i=1:numel(methodA)      %for all particle sizes <- this is the distinction between traces of same image
                            Namelabels{i}=getName(Data,methodA{i});

                            variable=[];
                            for ind=1:numel(indeces)        %For all images belonging to the group
                                %Add the cluster parameter
                                variable=[variable, current.ClusterInteraction{indeces(ind)}.(fields{f}){i}];
                            end

                            variable(isnan(variable))=[];
                            if isempty(variable) || ismember(Namelabels{i}, unwantedClusterTraces)            %%If the variable is empty, don't plot it and remove it from the labels
                                holdpoint=holdpoint+1;
                                to_be_removed=[to_be_removed i];
                            else
                                %plot
                                
                                cpl{end+1}=cdfplot_ax(ax,variable);
                            end
                            if i==holdpoint
                                hold on         %hold on after first plotted trace
                            end
                        end
                        hold off
                        %change figure appeareance according to user settings
                        changeAppearance(ax, settings.CumProbOptions)
                        changeCumProbAppearance(cpl, settings.CumProbOptions);
                        Namelabels(to_be_removed)=[];
                        %Label and save
                        title(ax, Grplabels{g+1});
                        legend(ax, Namelabels, 'Location', 'southeast', 'Box', settings.CumProbOptions.LegendBox, 'LineWidth', settings.CumProbOptions.LegendLineWidth);
                        ylabel(ax, settings.CumProbOptions.ylabeling);
                        xlabel(ax, fieldname{f});
                        savePlot(fig, fullfile(outpath, 'CumProbCluster', [Grplabels{g+1} ' - ' fieldname{f}]), settings.figformat);
                    else        %Cluster parameter depends on two kinds of particles
                        for j=1:numel(methodA)
                                Namelabels=cell(1,numel(methodA));
                                if j==1
                                    holdpoint=2;        %because i!=j, so i could never be 1
                                else
                                    holdpoint=1;
                                end
                                to_be_removed=[];
                                cpl={};  %holds plot handles
                                for i=1:numel(methodA)
                                    if i~=j
                                        Namelabels{i}=getName(Data,methodA{i});

                                        variable=[];
                                        for ind=1:numel(indeces)
                                            variable=[variable, current.ClusterInteraction{indeces(ind)}.(fields{f}){i,j}];
                                        end
                                        variable(isnan(variable))=[];

                                        if isempty(variable) || ismember(Namelabels{i}, unwantedClusterTraces)            %%If the variable is empty, don't plot it and remove it from the labels
                                            holdpoint=holdpoint+1;
                                            if holdpoint==j
                                                holdpoint=holdpoint+1;
                                            end
                                            to_be_removed=[to_be_removed i];
                                        else
                                            
                                            cpl{end+1}=cdfplot_ax(ax,variable);
                                        end
                                        if i==holdpoint
                                            hold on
                                        end
                                    end
                                end
                                hold off
                                %Change Appearance according to user settings
                                changeAppearance(ax, settings.CumProbOptions)
                                changeCumProbAppearance(cpl, settings.CumProbOptions);
                                Namelabels(to_be_removed)=[];
                                Namelabels=Namelabels(~cellfun('isempty', Namelabels));     %Remove cells that remained empty because i~=j
                                %Label and save
                                title(ax, Grplabels{g+1});
                                legend(ax, Namelabels, 'Location', 'southeast', 'Box', settings.CumProbOptions.LegendBox, 'LineWidth', settings.CumProbOptions.LegendLineWidth);
                                ylabel(ax, settings.CumProbOptions.ylabeling);
                                xlabel(ax, fieldname{f});
                                savePlot(fig, fullfile(outpath, 'CumProbCluster', [Grplabels{g+1} ' - ' fieldname{f} '_' getName(Data,methodA{j})]), settings.figformat);
                        end
                    end
                end
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Compare real with simulated Distances
Grplabels=[allGroupsname; grpNames]';

for mode=1:2    %1 - NND; 2 - All Distances
if (mode==1 && settings.CumProbOptions.makeNND) || (mode==2 && settings.CumProbOptions.makeAllDist)
    for sims=1:numel(methodA)       %For all simulated particle sizes 
        if mode==1
            outpath=[outp 'CmpRealSimNND' getName(Data,methodA{sims}) '/'];
            distfield='distances';
        else
            outpath=[outp 'CmpRealSimAllDist' getName(Data,methodA{sims}) '/'];
            distfield='allDistances';
        end
        mkdir(outpath)
        for g=0:nrGrp          %For all groups
            Namelabels=cell(1,numel(methodB));
            if g>0
                indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
            else        %g=0 - all Images
                indeces=1:nrImg;
            end
            for m=1:numel(methodB)      %For all types of distances (A->A, A->B, B->A, ...)
                llabels={settings.Origname settings.SimNames{1:end}};
                to_be_removed=[];
                flag=0;
                cpl={};         %holds plot handles
                Namelabels{m}=getName(Data, methodB{m});
                distances=[];
                for ind=1:numel(indeces)        %For all images of that group
                    %add distances
                    distances=[distances, Orig.Distance{m}{indeces(ind)}.(distfield)'];
                end
                distances(isnan(distances))=[];
                if isempty(distances) || ismember(llabels{1}, unwantedSimulationTraces)            %%If the variable is empty or unwanted, don't plot it and remove it from the labels
                    flag=1;     %Flags that Original Data was not plotted, hold on needs to be set after first simulation
                    to_be_removed=[to_be_removed, 1];
                else
                    %plot and hold on
                    
                    cpl{end+1}=cdfplot_ax(ax,distances);
                    hold on
                end
                for sim=1:numel(simtypes)       %For all types of simulation
                    current=Data.([simtypes{sim} '_cond']){sims};
                    distances=[];
                    for ind=1:numel(indeces)    %For all images belonging to group
                        %add distances
                        distances=[distances, current.Distance{m}{indeces(ind)}.(distfield)'];
                    end
                    distances(isnan(distances))=[];
                    if isempty(distances) || ismember(llabels{sim+1}, unwantedSimulationTraces)
                        flag=flag+1;
                        to_be_removed=[to_be_removed, sim+1];
                    else
                        %plot and set hold on if it was first plotted trace
                        
                        cpl{end+1}=cdfplot_ax(ax,distances);
                        if sim==flag
                            hold on
                        end
                    end
                end
                llabels(to_be_removed)=[];
                hold off
                %change figure style based on user settings
                changeAppearance(ax, settings.CumProbOptions)
                changeCumProbAppearance(cpl, settings.CumProbOptions);
                %Label and save
                title(ax, [Grplabels{g+1} ' - ' getName(Data, methodB{m})]);
                legend(ax, llabels, 'Location', 'southeast', 'Box', settings.CumProbOptions.LegendBox, 'LineWidth', settings.CumProbOptions.LegendLineWidth);
                ylabel(ax, settings.CumProbOptions.ylabeling);
                xlabel(ax, settings.CumProbOptions.xlabeling);
                savePlot(fig, fullfile(outpath, [Grplabels{g+1} '-' getName(Data, methodB{m})]), settings.figformat);

            end
        end
    end
end
end



%% Compare real with simulated for Cluster parameters
if settings.CumProbOptions.makeCluster
    Grplabels=[allGroupsname; grpNames]';

    for sims=1:numel(methodA)       %For all simulated particle sizes
        outpath=[outp 'CmpRealSim' getName(Data,methodA{sims}) 'Cluster/'];
        mkdir(outpath)
        for f=1:numel(fields)
            for g=0:nrGrp          %For all groups
                if g>0
                    indeces=find(Groups.imgGroup==g);       %Get indeces of images that belong to given group
                else        %g=0 - all images
                    indeces=1:nrImg;
                end
                if numel(Orig.ClusterInteraction{indeces(1)}.(fields{f}))==numel(methodA)   %If cluster parameter depends on one type of particle
                    for i=1:numel(methodA)  %for all particle sizes
                        llabels={settings.Origname settings.SimNames{1:end}};
                        to_be_removed=[];
                        cpl={};         %Holds plot handles
                        flag=0;
                        variable=[];

                        for ind=1:numel(indeces)        %For all images belonging to the group
                            %add cluster parameters
                            variable=[variable, Orig.ClusterInteraction{indeces(ind)}.(fields{f}){i}];
                        end

                        variable(isnan(variable))=[];
                        if isempty(variable) || ismember(llabels{1}, unwantedSimulationTraces)            %%If the variable is empty, don't plot it and remove it from the labels
                            flag=1;
                            to_be_removed=[to_be_removed, 1];
                        else
                            %plot and hold on
                            
                            cpl{end+1}=cdfplot_ax(ax,variable);
                            hold on
                        end
                        for sim=1:numel(simtypes)       %For all types of simulations
                            variable=[];
                            current=Data.([simtypes{sim} '_cond']){sims};
                            for ind=1:numel(indeces)        %For all images belonging to the group
                                %Add cluster parameters
                                variable=[variable, current.ClusterInteraction{indeces(ind)}.(fields{f}){i}];
                            end
                            variable(isnan(variable))=[];
                            if isempty(variable) || ismember(llabels{sim+1}, unwantedSimulationTraces)
                                flag=flag+1;
                                to_be_removed=[to_be_removed, sim+1];
                            else
                                %plot and set hold on if it was first plotted trace
                                
                                cpl{end+1}=cdfplot_ax(ax,variable);
                                if sim==flag
                                    hold on
                                end
                            end
                        end
                        llabels(to_be_removed)=[];
                        hold off
                        %change figure appearance according to user settings
                        changeAppearance(ax, settings.CumProbOptions)
                        changeCumProbAppearance(cpl, settings.CumProbOptions);
                        %Label and save
                        title(ax, [Grplabels{g+1} ' - ' getName(Data, methodA{i}) ' - ' fieldname{f}]);
                        legend(ax, llabels, 'Location', 'southeast', 'Box', settings.CumProbOptions.LegendBox, 'LineWidth', settings.CumProbOptions.LegendLineWidth);
                        ylabel(ax, settings.CumProbOptions.ylabeling);
                        xlabel(ax, fieldname{f});
                        savePlot(fig, fullfile(outpath, [Grplabels{g+1} '-' getName(Data, methodA{i}) '-' fieldname{f}]), settings.figformat);
                    end

                else        %Cluster parameter depends on two types of particles
                    for j=1:numel(methodA)
                        for i=1:numel(methodA)      %For all A->B, B->A, .. but not A->A or B->B
                            if i~=j
                                llabels={settings.Origname settings.SimNames{1:end}};
                                current=Data.([simtypes{sim} '_cond']){sims};
                                to_be_removed=[];
                                flag=0;
                                cpl={};     %holds plot handles
                                variable=[];
                                for ind=1:numel(indeces)        %For all images of this group
                                    %Add variables
                                    variable=[variable, current.ClusterInteraction{indeces(ind)}.(fields{f}){i,j}];
                                end
                                variable(isnan(variable))=[];
                                if isempty(variable) || ismember(llabels{1}, unwantedSimulationTraces)            %%If the variable is empty, don't plot it and remove it from the labels
                                    flag=1;
                                    to_be_removed=[to_be_removed, 1];
                                else
                                    %plot and hold on
                                    
                                    cpl{end+1}=cdfplot_ax(ax,variable);
                                    hold on
                                end
                                for sim=1:numel(simtypes)       %For all types of simulations
                                    current=Data.([simtypes{sim} '_cond']){sims};
                                    variable=[];
                                    for ind=1:numel(indeces)        %For all images belonging to this group
                                        %Add cluster parameters
                                        variable=[variable, current.ClusterInteraction{indeces(ind)}.(fields{f}){i,j}];
                                    end
                                    variable(isnan(variable))=[];
                                    if isempty(variable) || ismember(llabels{sim+1}, unwantedSimulationTraces)
                                        flag=flag+1;
                                        to_be_removed=[to_be_removed, sim+1];
                                    else
                                        %plot and hold on if it was first trace
                                        
                                        cpl{end+1}=cdfplot_ax(ax,variable);
                                        if sim==flag
                                            hold on
                                        end
                                    end
                                end

                                llabels(to_be_removed)=[];
                                hold off
                                %Change appearance according to user settings
                                changeAppearance(ax, settings.CumProbOptions);
                                changeCumProbAppearance(cpl, settings.CumProbOptions);
                                %Label and Save
                                title(ax, [Grplabels{g+1} ' - ' getName(Data,methodA{i}) ' - ' fieldname{f}]);
                                legend(ax, llabels, 'Location', 'southeast', 'Box', settings.CumProbOptions.LegendBox, 'LineWidth', settings.CumProbOptions.LegendLineWidth);
                                ylabel(ax, settings.CumProbOptions.ylabeling);
                                xlabel(ax, fieldname{f});
                                savePlot(fig, fullfile(outpath, [Grplabels{g+1} '-' getName(Data,methodA{i}) '-' fieldname{f} '_' getName(Data, methodA{j})]), settings.figformat); 
                            end
                        end
                    end
                end
            end
        end
    end
end

set(groot, 'defaultAxesColorOrder', 'factory');    %Reset colorscheme to factory preset   
delete(fig);
end