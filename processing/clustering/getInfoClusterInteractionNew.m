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
%
function infoClI=getInfoClusterInteractionNew(infoI, infoC, Options)
warning('off', 'MATLAB:mir_warning_maybe_uninitialized_temporary');
%%Generates infoClusterInteraction which includes the following
% infoClI{}.id:               Image id
% infoClI{}.radius{i}:          Radius of particles of cluster i
% infoClI{}.number{i}:          Number of Cluster i
% infoClI{}.particles{i}:       Number of Particles in each Cluster i
% infoClI{}.area{i}:            Area of each Cluster i
% infoClI{}.density{i}:         Density of Particles in each Cluster i
% infoClI{}.NNDbetweenSameSizeClusters{i}:        Distance from each Cluster to nearest Cluster of same type
% infoClI{}.NND_to_{i}:       Distance from each Cluster1 to nearest Cluster of other type
% infoClI{}.Overlap_with_{i}:       Percent of area of each Cluster that is overlapped by Cluster of other type
% infoClI{}..excludedClusters:  Number of clusters that were excluded because all three particles lay in one line.


%   infoImages: cell array with the information relative to each image.
%
%   infoImages{}.id:                      Id of the image.
%   infoImages{}.route:                   Route to the files relative to the image.
%   infoImages{}.scale:                   Scale of the image (nanometers/pixel). It is obtained as calibration * 10 / magnification.
%   infoImages{}.area:                    Area of interest (squared nanometers).
%   infoImages{}.numParticles:            Number of particles.
%   infoImages{}.centers:                 Locations of the particles (nanometers).
%   infoImages{}.radii:                   Actual radii of the particles (nanometers).
%   infoImages{}.teorRadii:               Theorethical radii of the particles.

%   radii:          Array with the theorethical radii of the dots considered for the clustering.
%   maxDistance:    Maximum intra cluster distance.
%   minPoints:      Minimum number of points on each cluster.

%   showProgress:                       If true, it shows progress by console.

%   infoClustering: Cell array of structs containing information on the cluster
%
%       infoClustering.{}.id:                          Id of the image.
%
%       infoClustering.{}.radius:                      Considered radii
%       infoClustering.{}.maxDistance:                 Maximum intra cluster distance.
%       infoClustering.{}.minPoints:                   Minimum number of points on each cluster.
%
%       infoClusterImg.clusters:                       Vector of integers containing the cluster each particle belongs to:
%                                                        0) Outlier. The particle is not included in a cluster or is out of range.                                                      of range.
%                                                        n) Number of cluster.
%
%       infoClustering.{}.numClusters:                 Number of clusters detected.
%       infoClustering.{}.numPointsCluster:            Vector of integers containing the number of particles included in each cluster.

%       infoClustering.{}.distPointsCluster:              Matrix of integers containing the number of particles with each one of the radii considered.
%
%       infoClustering.{}.areaCluster:                 Vector of doubles containing the area of each cluster.
%       infoClustering.{}.densityCluster:              Vector of doubles containing the density (particles/squared nanometer) of each cluster.
%       infoClustering.{}.ripleysL:                    Vector of doubles containing the value of stabilized Ripley's k (l) for each cluster.
%       infoClustering.{}.nearestCluster:              Vector of doubles containing the distance to the nearest cluster.
%       infoClustering{}.excludedClusters:             Number of clusters that were excluded because all three particles lay in one line.

inputNr=numel(infoC);

imgNr=numel(infoI);
infoClI = cell(imgNr,1);
warning('off', 'MATLAB:mir_warning_maybe_uninitialized_temporary')      %Turn off specific warning that will appear

for i=1:imgNr
    for c=1:inputNr
        %Copy already known values
        
        fields={'radius', 'NumberOfClusters', 'ParticlesPerCluster', 'ClusterArea', ...
                'DensityWithinCluster', 'excludedClusters', 'maxDistance', 'distanceFromEdge', ...
                'distanceFromCenter', 'normalizedDistanceFromCenter'};
        infoClI{i}.id=infoI{i}.id;
        for f=1:numel(fields)
            infoClI{i}.(fields{f}){c}=infoC{c}{i}.(fields{f})';
        end
        

        %% Get Distances to other Cluster
        numClusters = infoC{c}{i}.NumberOfClusters;
        
        %%Calculate Intragroup distance between Clusters
        if numClusters>1
            infoClI{i}.NNDbetweenSameSizeClusters{c}=zeros(numClusters,1)';
            for nC1=1:numClusters              
                pClust1=infoI{i}.centers(infoC{c}{i}.clusters==nC1,:);
                distances=[];
                for nC2=1:numClusters
                    if nC2~=nC1
                        pClust2=infoI{i}.centers(infoC{c}{i}.clusters==nC2,:);
                        distances=[distances, dist2Clusters(pClust1,pClust2, Options)];
                    end
                end


                infoClI{i}.NNDbetweenSameSizeClusters{c}(nC1)=min(distances);
            end
        else
            infoClI{i}.NNDbetweenSameSizeClusters{c} = NaN;
        end
        
        %% Compute intergroup distances and overlap
        %If only one clustergroup is being computed, write NaN for them
        
        
        % If there is no clusters in any cluster, write NaN for distance from this clustergroup.
        
        for d=1:inputNr
            if d~=c
            numClusters_2=infoC{d}{i}.NumberOfClusters;
                if numClusters==0
                    infoClI{i}.NND_to_{c,d}=NaN;
                    infoClI{i}.Overlap_with_{c,d}=NaN;
                elseif numClusters_2==0    
                    infoClI{i}.NND_to_{c,d}=NaN(numClusters,1)';
                    infoClI{i}.Overlap_with_{c,d}=NaN(numClusters,1)';
                else
                    % Otherwise, it stores a value for each cluster.
                    infoClI{i}.NND_to_{c,d} = zeros(numClusters,1)';
                    infoClI{i}.Overlap_with_{c,d} = zeros(numClusters,1)';

                    %% Calculates the distances and Overlap.

                    for nC1=1:numClusters                  %Calculate distance from 1 to 2
                        pClust1=infoI{i}.centers(infoC{c}{i}.clusters==nC1,:);
                        distances=[];
                        for nC2=1:numClusters_2
                            pClust2 = infoI{i}.centers(infoC{d}{i}.clusters==nC2,:);
                            distances=[distances, dist2Clusters(pClust1,pClust2, Options)];
                        end
                        try 
                            infoClI{i}.Overlap_with_{c,d}(nC1)=areaPercentOverlap(pClust1,pClust2);
                        catch
                            pClust1
                            pClust2
                            infoClI{i}.Overlap_with_{c,d}(nC2)=areaPercentOverlap(pClust2,pClust1);
                        end
                        try
                            infoClI{i}.NND_to_{c,d}(nC1)=min(distances);
                        catch
                            distances
                            infoClI{i}.NND_to_
                        end
                            
                    end
                end
            end     
        end
    end
end



end