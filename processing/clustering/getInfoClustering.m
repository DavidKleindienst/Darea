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
function infoClustering = getInfoClustering(infoImages, radii, maxDistance,  minPoints)
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
%   infoImages{}.teorRadii:               Theorethical radii of the particles.

%   radii:          Array with the theorethical radii of the dots considered for the clustering.
%   maxDistance:    Maximum intra cluster distance.
%   minPoints:      Minimum number of points on each cluster.

%   showProgress:                       If true, it shows progress by console.

%   infoClustering: Cell array of structs containing the results.
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

numImages = size(infoImages, 1);
infoClustering = cell(numImages,1);
for nImage=1:numImages
    infoClustering{nImage} = clusterImage(infoImages{nImage}, radii, maxDistance,  minPoints);
end

