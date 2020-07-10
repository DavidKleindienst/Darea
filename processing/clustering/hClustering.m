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


function [clusters] = hClustering(points, minIntraClusterDistance, minNumPointsPerCluster)
%% Groups points in clusters with hierarchical clustering. For each point it returns the index of the cluster it belongs to.

% points: (n,2) matrix with the coordinates of the points.
%
% minIntraClusterDistance: Minimum distance between clusters. The default metric used
%          to measure the distance between clusters is 'single', which is the minimum distance
%          between any pair of points from different clusters. When the distance between two clusters is smaller
%          than minIntraClusterDistance, they are merged.
% 
% minNumPointsPerCluster: The minimum number of points that a cluster must have. Clusters with less
%          points than this parameter will be omitted.

% clusters: (n,1) integer vector with the cluster each point belongs to. Outliers are set to 0.

%% Intially, all points are labeled as outliers.
clusters = zeros(size(points,1),1);

%% This function calculates the hierarchical clustering represented as an array.
link = linkage(points,'single','euclidean');
initialClusters = cluster(link,'cutoff',minIntraClusterDistance,'criterion','distance');

%% Now discards the outliers and reassigns cluster numbers. 
numInitialClusters = max(initialClusters);
% Index of the first definitive cluster.
defClusterIdx = 1;
% Treats each cluster
for initialClusterIdx=1:numInitialClusters,
    % If the cluster does not have the minimum number of points, it preserves the 0 value (outlier).
    elementsCluster = find(initialClusters==initialClusterIdx);
    if numel(elementsCluster)<minNumPointsPerCluster,
        continue
    end
    % Otherwise reasigns cluster numbers
    clusters(elementsCluster) = defClusterIdx;
    defClusterIdx = defClusterIdx + 1;
end
end

