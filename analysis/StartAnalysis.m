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

function returnData=StartAnalysis(datFile, settings, hProgress, outpath,analysisName)
warning('off', 'MATLAB:mir_warning_maybe_uninitialized_temporary');
%% Performs the analyis
%Input parameters:
%datFile - path to and filename of the Image file
%settings - struct that contains all the settings defined by the user in analysisDialog
%hProgress - handle to text in the Dialog window which is used for giving details on progress
%            or giving error messages
%outpath - path to the output file
%
%Output:
%All Data will be collected in the struct Data
%which will be saved to the output file

Data.analysisName=analysisName;
% Distances analyzed. These will be used later for making figures
Data.distfields={'allDistances', 'distances', 'distanceFromEdge', 'distanceFromCenter', 'relativeDistanceFromCenter', 'squaredRelDistFromCenter'};
Data.isPairedField=[1,1,0,0,0,0];     %If distances are also between particle classes
groupnames=readGroups(datFile);
if settings.SimOptions.ReceptorParticleDistance(2)==-1
    settings.SimOptions.ReceptorParticleDistance(2)=settings.dilate;
if strcmp(settings.maxDist{1}, 'SD') && settings.ClusterOptions.Clustering>2
    %ClusteringDistance will be calculated based on Groups. so save which
    %groups!
    Data.GroupsForClusterDistance=settings.chosenGroups;
    
    Data.GroupNamesForClusterDistance=groupnames(settings.chosenGroups);
end
if numel(settings.simnames)==0
    %If no simulations should be run,
    %set nr of sim to 0
    settings.nrsim=0;
end

%Write some identifying parameters to Data
Data.simnames=settings.simnames;
minpointscluster=settings.minpointscluster;
Data.radii=settings.radii;
Data.names=settings.names;
Data.nrsim=settings.nrsim;
Data.settings=settings;
Data.allName=settings.allName;
Data.checksum=Simulink.getFileChecksum(datFile);

if (settings.doColocalization || settings.nrsim>10) && getCurrentPoolSize()==0
    try
    parpool();  %Start a parallel pool if it will likely save time
    end
end

% methodA: set of all types of particles that will be analysed
% methodB: set of all types of particle-particle distances that will be analysed; Example: {2.5, 5} -> Distance from 2.5 to 5; {5, NaN} -> Distance from 5 to 5
% mehtodC: set of all particle-particle distances between different particles
% Generate these sets based on settings
if settings.includeall
    methodA={'all'};        %particles are also analysed irrespective of size
    methodB={{'all', NaN}};
else
    methodA={};
    methodB={};
end
methodC={};
for i=1:numel(Data.radii) 
    methodA{end+1}=Data.radii(i);
    for j=1:numel(Data.radii)
        if j==i
            methodB{end+1}={Data.radii(i), NaN};
        else
            methodB{end+1}={Data.radii(i), Data.radii(j)};
        end
    end
    for j=i+1:numel(Data.radii)
        methodC{end+1}={Data.radii(i),Data.radii(j)};
    end
end

if numel(settings.SimOptions.partExcl)~=numel(methodA)
    partExcl=cell(1,numel(methodA));
    nrPart=min(numel(settings.SimOptions.partExcl),numel(partExcl));
    partExcl(1:nrPart)=settings.SimOptions.partExcl(1:nrPart);
    partExcl(cellfun(@isempty,partExcl))={'random'};
    settings.SimOptions.partExcl=partExcl;
end

Data.methodA=methodA;   %Save these sets to Data
Data.methodB=methodB;
Data.methodC=methodC;
%% Process Original Images
%Get all the info files 
Data.Orig.Images=getInfoImages(datFile, settings.dilate, settings.onlyParticlesWithin);
Data.Groups=getInfoGroups(datFile,settings.chosenGroups);
Data.nrImages=numel(Data.Orig.Images);
Data.Orig.PartCount=getInfoCounting(Data.Orig.Images, false);
for i=1:numel(methodB)  %compute all types of Distances 
    Data.Orig.Distance{i}=getInfoDistances(Data.Orig.Images,methodB{i}{1},methodB{i}{2},settings.limitEdgeIndex,false);
end


Data.thresholdDistance=computeClusteringThreshold(Data.Orig.Images,Data.Orig.Distance,Data.Groups,Data.methodA,Data.methodB,settings);     

if settings.doColocalization %Relatively expensive, computationally
for i=1:numel(methodC)  %compute Colocalization
    Data.Orig.Colocalization{i}=sendForColocalization(Data,Data.Orig.Images,methodC{i}{1},methodC{i}{2},Data.thresholdDistance,settings.keepColocIm);
end
end

for i=1:numel(methodA) %Perform clustering
    Data.Orig.Clustering{i}=sendForClustering(Data, Data.Orig.Images, i, Data.thresholdDistance,  minpointscluster);
end
%Get interactions between Clusters (e.g Cluster to Cluster Distance)
Data.Orig.ClusterInteraction=getInfoClusterInteractionNew(Data.Orig.Images, Data.Orig.Clustering, settings.ClusterOptions);

if numel(Data.simnames)>0
%Perform Simulations and compute distances and clustering
totalsimulations=numel(methodA)*Data.nrsim; %total number of simulations that will be performed
for i=1:numel(methodA) %For all particle sizes that will be simulated
    for j=1:Data.nrsim %For each individual simulation to be performed
        thisissimulation=(i-1)*Data.nrsim+j-1;  
        percentDone=round((thisissimulation/totalsimulations)*100);
        set(hProgress, 'String', sprintf('Performing simulations. %d %% finished.',percentDone)); %Show Progress
        drawnow();
        for s=1:numel(Data.simnames) %For each type of simulation to be performed
 
            Data.(Data.simnames{s}){i}.Images{j}=genSimulation(Data.Orig.Images,methodA{i},Data.simnames{s}, settings.SimOptions,Data.methodA, hProgress);
            for k=1:numel(methodB)  %Get Distances and Colocalization
                Data.(Data.simnames{s}){i}.IndivDist{k}{j}=getInfoDistances(Data.(Data.simnames{s}){i}.Images{j},methodB{k}{1},methodB{k}{2},settings.limitEdgeIndex,false);
            end
            if settings.doColocalization
                for k=1:numel(methodC)
                    Data.(Data.simnames{s}){i}.IndivColoc{k}{j}=sendForColocalization(Data,Data.(Data.simnames{s}){i}.Images{j},methodC{k}{1},methodC{k}{2},Data.thresholdDistance, settings.keepSimColocIm);
                end
            end
            for k=1:numel(methodA)  %Get Clusterings
                Data.(Data.simnames{s}){i}.IndivClust{k}{j}=sendForClustering(Data,Data.(Data.simnames{s}){i}.Images{j},k,Data.thresholdDistance, minpointscluster);
            end
            IndivClusterings=cell(1,numel(Data.(Data.simnames{s}){i}.IndivClust));    %Make an array of the clusterings so they can be used for computing cluster interactions
            for c=1:numel(Data.(Data.simnames{s}){i}.IndivClust)
                IndivClusterings{c}=Data.(Data.simnames{s}){i}.IndivClust{c}{j};
            end
            %Compute cluster interactions
            Data.(Data.simnames{s}){i}.IndivClustInteraction{j}=getInfoClusterInteractionNew(Data.(Data.simnames{s}){i}.Images{j}, IndivClusterings, settings.ClusterOptions);
            %Remove Discarded Area and boundary because it is redundant and would increase file size massively
            for img=1:numel(Data.(Data.simnames{s}){i}.Images{j}) 
                Data.(Data.simnames{s}){i}.Images{j}{img}=rmfield(Data.(Data.simnames{s}){i}.Images{j}{img}, 'discardedAreas');
                Data.(Data.simnames{s}){i}.Images{j}{img}=rmfield(Data.(Data.simnames{s}){i}.Images{j}{img}, 'boundary');
                Data.(Data.simnames{s}){i}.Images{j}{img}=rmfield(Data.(Data.simnames{s}){i}.Images{j}{img}, 'demarcatedAreas');
            end
        end
    end
    for s=1:numel(Data.simnames)    %Pool Distances and Clusterinteractions over all simulations of same type
        for k=1:numel(methodB)
            Data.([Data.simnames{s} '_cond']){i}.Distance{k}=condenseDistances(Data.Orig.Images, Data.(Data.simnames{s}){i}.IndivDist{k},Data.distfields);
        end
        Data.([Data.simnames{s} '_cond']){i}.ClusterInteraction=condenseClusterInteractions(Data.Orig.Images, Data.(Data.simnames{s}){i}.IndivClustInteraction);
    end
end
%Remove unneccessary fields from individual simulations to save space, unless user wants to keep them.
if ~settings.SimOptions.indivsave
    for s=1:numel(Data.simnames)
        Data=rmfield(Data, Data.simnames{s});
    end
end
end
set(hProgress, 'String', 'Saving Results');
drawnow();
if nargout>0
    %If needed, preserve Data for returning before serialization
    returnData=Data;
end
try %May fail if not enough free RAM exists.
    Data=hlp_serialize(Data);       %Serialization needs smaller filesize and allows faster saving and loading
    %% Serialization algorithm (C) 2012 by Christian Kothe
    %% License can be found at 3rdParty/serialization/license.txt
    save(outpath, 'Data', '-v7.3');
catch %If not enough RAM, save without serialization
    save(outpath, '-struct', 'Data', '-v7.3');
end

end
