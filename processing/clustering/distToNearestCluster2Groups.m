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
function infoDistClustersImg = distToNearestCluster2Groups(infoImage, infoClustersImg_1, infoClustersImg_2)
%% Given two sets of clusters calculates, for each cluster in the first set, the distance to the nearest cluster in the second set. 
%
% Both clusters must refer to the same image. 

%   infoImage:     Struct containing the information relative to each image.
%
%       infoImage.id:                      Id of the image.
%       infoImage.route:                   Route to the files relative to the image.
%       infoImage.scale:                   Scale of the image (nanometers/pixel). It is obtained as calibration * 10 / magnification.
%       infoImage.area:                    Area of interest (squared nanometers).
%       infoImage.numParticles:            Number of particles.
%       infoImage.centers:                 Locations of the particles (nanometers).
%       infoImage.radii:                   Actual radii of the particles (nanometers).
%       infoImage.teorRadii:               Teorethical radii of the particles.
%

%   infoClustersImg_X: Struct containing the results of the clustering.
%
%       infoClustersImg_X.id:                          Id of the image.
%
%       infoClustersImg_X.radius:                      Considered radii
%       infoClustersImg_X.maxDistance:                 Maximum intra cluster distance.
%       infoClustersImg_X.minPoints:                   Minimum number of points on each cluster.
%       
%       infoClustersImg_X.clusters:                    Vector of integers containing the cluster each particle belongs to:
%                                                        0) Outlier. The particle is not included in a cluster or is out of range.                                                      of range.
%                                                        n) Number of cluster.
%       infoClustersImg_X.numClusters:                 Number of clusters detected.
%       infoClustersImg_X.numPointsCluster:            Vector of integers containing the number of particles included in each cluster.
%       infoClustersImg_X.distPointsCluster:           Matrix of integers containing the number of particles with each one of the radii considered.
%
%       infoClustersImg_X.areaCluster:                 Vector of doubles containing the area of each cluster.
%       infoClustersImg_X.densityCluster:              Vector of doubles containing the density (particles/squared nanometer) of each cluster.
%       infoClustersImg_X.ripleysL:                    Vector of doubles containing the value of stabilized Ripley's k (l) for each cluster.
 
%   infoDistClusterImg: Struct contaning the information of the distance between clusters.
%
%       infoDistClusterImg.id:                        Id of the image.
%       infoDistClusterImg.radius1:                   Radius of the points considered for the first set of clusters.
%       infoDistClusterImg.numClusters1:              Number of clusters in the first group.
%       infoDistClusterImg.radius2:                   Radius of the points considered for the second set of clusters.
%       infoDistClusterImg.numClusters2:              Number of clusters in the second group.
%       infoDistClusterImg.distances:                 For each cluster in the first set there is a distance.


%% First of all checks if both sets of clusters belong to the same image.
if  infoImage.id~=infoClustersImg_1.id || infoImage.id~=infoClustersImg_2.id,
    fprintf('The clusters do not belong to the same image');
    return
end

%% Copies the identification of the parameters.
infoDistClustersImg.id = infoImage.id;
infoDistClustersImg.radius1 = infoClustersImg_1.radii;
infoDistClustersImg.numClusters1 = infoClustersImg_1.numClusters;
infoDistClustersImg.radius2 = infoClustersImg_2.radii;
infoDistClustersImg.numClusters2 = infoClustersImg_2.numClusters;

%% Extracts the number of clusters
numClusters_1 = infoClustersImg_1.numClusters;
numClusters_2 = infoClustersImg_2.numClusters;

% If there is no clusters in the first image, returns NaN
if numClusters_1==0,
    infoDistClustersImg.distances = NaN;
    return
end

% Otherwise, it stores a value for each cluster.
infoDistClustersImg.distances = zeros(numClusters_1,1);

% If there is no clusters in the second set, it sets the value to NaN.
if numClusters_2==0,
    for nCluster=1:numClusters_1
        infoDistClustersImg.distances(nCluster)=NaN;
    end
    return
end

%% Calculates the distances.
pointsClusters2 = infoImage.centers(infoClustersImg_2.clusters>0,:);
for nCluster=1:numClusters_1
    pointsClusters1 = infoImage.centers(infoClustersImg_1.clusters==nCluster,:);
    allDistances = distToNearestPoint2Sets(pointsClusters1, pointsClusters2);
    infoDistClustersImg.distances(nCluster) = min(allDistances);
end

