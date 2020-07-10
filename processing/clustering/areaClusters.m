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

function areas = areaClusters(points, clusters)
%% Gets the area of each cluster in 2D points. Calculates the convex hull and returns its area.

% points: (nx2) matrix with the points.
% cluster: (nx1) vector with the clusters.

% area: (numClusters, 1) vector with the area of each cluster.
% areaStats: (5x1 vector) with the statistic information of the areas:
%            [total mean standard max min]

% If there is no cluster, it does not return anything.
if(isempty(clusters))
    areas = [];
    return;
end

% Extracts the number of clusters.
numClusters = max(clusters);

% If all points are outliers, it does not return anything.
if numClusters==0
    areas = [];
else  % Otherwise, calculates the areas.
    areas = zeros(numClusters,1);
    for cluster=1:numClusters
        % Gets the points
        pointsCluster = points(clusters==cluster,:);
        if size(pointsCluster,1)>=3
            % Calculates the convex hull
            
            try
                ch = convhull(pointsCluster(:,1), pointsCluster(:,2));
            catch
                pointsCluster
                ch = convhull(pointsCluster(:,1), pointsCluster(:,2));
            end
            
            % Calculates the area
            areas(cluster) = polyarea(pointsCluster(ch,1), pointsCluster(ch,2));
            % Some cases, where the points are aligned, there can be problems.
            %minimumArea = pi* (2.5^2) * size(pointsCluster,1);
            %if areas(cluster)<minimumArea,
            %    areas(cluster) = minimumArea;
            %end
        else
            % If there are less than three points, the area is not valid.
            areas(cluster) = NaN;
        end
    end
end

end

