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
function infoDistClusters = getInfoDistToNearestCluster2Groups(infoImages, infoClusters_1, infoClusters_2, showProgress)
%% Carries out a clustering process on each image, among the particles with the given radii.

%   infoImages: cell array with the information relative to each image.
%
%   infoImages{}.id:                      Id of the image.
%   infoImages{}.route:                   Route to the files relative to the image.
%   infoImages{}.scale:                   Scale of the image (nanometers/pixel). It is obtained as calibration * 10 / magnification.
%   infoImages{}.area:                    Area of interest (squared nanometers).
%   infoImages{}.numParticles:            Number of particles.
%   infoImages{}.centers:                 Locations of the particles (nanometers).
%   infoImages{}.radii:                   Actual radii of the particles (nanometers).
%   infoImages{}.teorRadii:               Teorethical radii of the particles.


%   infoClusters_X: Struct containing the results of the clustering.
%
%       infoClusters_X.id:                          Id of the image.
%
%       infoClusters_X.radius:                      Considered radii
%       infoClusters_X.maxDistance:                 Maximum intra cluster distance.
%       infoClusters_X.minPoints:                   Minimum number of points on each cluster.
%       
%       infoClusters_X.clusters:                    Vector of integers containing the cluster each particle belongs to:
%                                                        0) Outlier. The particle is not included in a cluster or is out of range.                                                      of range.
%                                                        n) Number of cluster.
%       infoClusters_X.numClusters:                 Number of clusters detected.
%       infoClusters_X.numPointsCluster:            Vector of integers containing the number of particles included in each cluster.
%       infoClusters_X.distPointsCluster:           Matrix of integers containing the number of particles with each one of the radii considered.
%
%       infoClusters_X.areaCluster:                 Vector of doubles containing the area of each cluster.
%       infoClusters_X.densityCluster:              Vector of doubles containing the density (particles/squared nanometer) of each cluster.
%       infoClusters_X.ripleysL:                    Vector of doubles containing the value of stabilized Ripley's k (l) for each cluster.
 
%   showProgress:                       If true, it shows progress by console.

%   infoDistClusters: Struct contaning the information of the distance between clusters.
%
%       infoDistClusters.id:                        Id of the image.
%       infoDistClusters.radius1:                   Radius of the points considered for the first set of clusters.
%       infoDistClusters.numClusters1:              Number of clusters in the first group.
%       infoDistClusters.radius2:                   Radius of the points considered for the second set of clusters.
%       infoDistClusters.numClusters2:              Number of clusters in the second group.
%       infoDistClusters.distances:                 For each cluster in the first set there is a distance.

numImages = size(infoImages, 1);
infoDistClusters = cell(numImages,1);

if showProgress 
        fprintf('Computing distances between clusters. \n');
        fprintf('\t Clusters of particles with radius %.2f.\n', infoClusters_1{1}.radii);
        fprintf('\t Distance to the nearest cluster of particles with radius %.2f.\n\n', infoClusters_2{1}.radii);
end

for nImage=1:numImages
    infoDistClusters{nImage} = distToNearestCluster2Groups(infoImages{nImage}, infoClusters_1{nImage}, infoClusters_2{nImage});
end

