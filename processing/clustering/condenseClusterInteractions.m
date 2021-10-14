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

function info=condenseClusterInteractions(infoI, infoCI)
%% Condenses many structs (obtained by simulations) of the type info-ClusterInteraction into one
% infoClI{}.id:               Image id
% infoClI{}.radius1:          Radius of particles of cluster1
% infoClI{}.radius2:          Radius of particles of cluster2
% infoClI{}.number1:          Number of Cluster1
% infoClI{}.number2:          Number of Cluster2
% infoClI{}.particles1:       Number of Particles in each Cluster1
% infoClI{}.particles2:       Number of Particles in each Cluster2
% infoClI{}.area1:            Area of each Cluster1
% infoClI{}.area2:            Area of each Cluster2
% infoClI{}.density1:         Density of Particles in each Cluster1
% infoClI{}.density2:         Density of Particles in each Cluster2
% infoClI{}.distance1_1:        Distance from each Cluster1 to nearest Cluster1
% infoClI{}.distance2_2:        Distance from each Cluster2 to nearest Cluster2
% infoClI{}.distance1_2:      Distance from each Cluster1 to nearest Cluster2
% infoClI{}.distance2_1:      Distance from each Cluster2 to nearest Cluster1
% infoClI{}.overlap1_2:       Percent of area of each Cluster1 that is overlapped by a Cluster2
% infoClI{}.overlap2_1:       Percent of area of each Cluster2 that is overlapped by a Cluster1
% infoClustering{}.excludedClusters:             Number of clusters that were excluded because all three particles lay in one line.


numImg=size(infoI,1);
nrClusterings=numel(infoCI{1}{1}.radius);       %Number of different sizes of particles
info=infoCI{1};    %Keep the first clustering info; condense all others into that later.
properties1d= {'NumberOfClusters', 'ParticlesPerCluster', 'ClusterArea', ...
                'DensityWithinCluster', 'excludedClusters', 'NNDbetweenSameSizeClusters', 'distanceFromEdge', ...
                'distanceFromCenter', 'normalizedDistanceFromCenter', 'maxDistance'};
properties2d={'Overlap_with_','NND_to_'};
for s=2:numel(infoCI)
    for img=1:numImg
        radiusConstantCheck=zeros(nrClusterings);
        for c=1:nrClusterings  
            radiusConstantCheck(c)=any(infoCI{s}{img}.radius{c}~=info{img}.radius{c});
        end
        % Confirm that nothing substantial changed between the different clustering to be fused (like a new particle size with different radius appearing)
        if any(radiusConstantCheck)
            fprintf('A problem occured when condensing clusters, radii are not the same in every image');
            return     
        end
        
        for i=1:nrClusterings
            %% For all properties that are a single number or a 1-D array, make an array that having all the numbers of the different clustrings
            for p=1:numel(properties1d)
                prop=properties1d{p};
                info{img}.(prop){i}=[info{img}.(prop){i}, infoCI{s}{img}.(prop){i}];
            end
            %% For 2-D arrays, add them to the array
            if nrClusterings>1
            for c=1:nrClusterings
                for p=1:numel(properties2d)
                    prop=properties2d{p};
                    info{img}.(prop){i,c}=[info{img}.(prop){i,c}, infoCI{s}{img}.(prop){i,c}];
                end  
            end
            end
        end
    end
end