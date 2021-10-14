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

function infoClusterImg = clusterImage(infoImage, radii, maxDistance,  minPoints)
%% Carries out a hierarchical clustering over the points of an image. It accepts a range of radii to select points.

%   infoImage:     Struct containing the information relative to each image.
%
%       infoImage.route:                   Route to the files relative to the image.
%       infoImage.scale:                   Scale of the image (nanometers/pixel). It is obtained as calibration * 10 / magnification.
%       infoImage.area:                    Area of interest (squared nanometers).
%       infoImage.numParticles:            Number of particles.
%       infoImage.centers:                 Locations of the particles (nanometers).
%       infoImage.radii:                   Actual radii of the particles (nanometers).
%       infoImage.teorRadii:               Teorethical radii of the particles.
%
%   radii:          Array with the teorethical radii of the dots considered for the clustering.
%   maxDistance:    Maximum intra cluster distance.
%   minPoints:      Minimum number of points on each cluster.

%   infoClusterImg: Struct containing the results.
%
%       infoClusterImg.id:                          Id of the image.
%
%       infoClusterImg.radius:                      Considered radii
%       infoClusterImg.thresholdDistance:                 Maximum intra cluster distance.
%       infoClusterImg.minPoints:                   Minimum number of points on each cluster.
%       
%       infoClusterImg.clusters:                    Vector of integers containing the cluster each particle belongs to:
%                                                        0) Outlier. The particle is not included in a cluster or is out of range.                                                      of range.
%                                                        n) Number of cluster.
%       infoClusterImg.NumberOfClusters:                 Number of clusters detected.
%       infoClusterImg.ParticlesPerCluster:            Vector of integers containing the number of particles included in each cluster.
%       infoClusterImg.distPointsCluster:           Matrix of integers containing the number of particles with each one of the radii considered.
%
%       infoClusterImg.ClusterArea:                 Vector of doubles containing the area of each cluster.
%       infoClusterImg.DensityWithinCluster:              Vector of doubles containing the density (particles/squared nanometer) of each cluster.
%       infoClusterImg.ripleysL:                    Vector of doubles containing the value of stabilized Ripley's k (l) for each cluster.
%       infoClusterImg.nearestCluster:              Vector of doubles containing the distance to the nearest cluster.
%       infoClusterImg.excludedClusters:            Number of clusters excluded because all three particles lay on one line

%% Image
infoClusterImg.id = infoImage.id;

%% Details of the algorithm.
infoClusterImg.maxDistance = maxDistance;
infoClusterImg.minPoints = minPoints;
infoClusterImg.radius = radii;
infoClusterImg.excludedClusters=0;

if strcmp(radii,'all')
    radii=unique(infoImage.teorRadii);
end

%% Extracts the particles
% Selects those points with the given radii.
consideredPointsIdx = find(ismember(infoImage.teorRadii,radii));
% Points considered
consideredPoints = infoImage.centers(consideredPointsIdx,:);
% Number of points
numPoints = size(consideredPoints,1);

 

%% Carries out hierarchical clustering
% Only carries out the clustering if there is points enough
if (numPoints>=minPoints)
    infoClusterImg.clusters = hClustering(consideredPoints, maxDistance, minPoints);
    infoClusterImg.NumberOfClusters = max(infoClusterImg.clusters);
else
    infoClusterImg.NumberOfClusters = 0;
    infoClusterImg.clusters = zeros(numPoints,1);
end

%% If a cluster consists of 3 particles that are on one line, it is not considered as cluster

if infoClusterImg.NumberOfClusters>=1
    ClusterToBeRemoved=[];
    for nCluster=1:infoClusterImg.NumberOfClusters
        points=consideredPoints(infoClusterImg.clusters==nCluster,:);
        if checkColinearity(points)
            ClusterToBeRemoved=[ClusterToBeRemoved,nCluster];   %Ignore Cluster if all points lie on one line. (Would throw error because such cluster have no area)
        end
        
    end
    if numel(ClusterToBeRemoved)>=1
        infoClusterImg.excludedClusters=numel(ClusterToBeRemoved);

        for i=1:numel(ClusterToBeRemoved)
            r=numel(ClusterToBeRemoved)+1-i;    %Get an index that goes through the Clusters, starting with the highest number
            
            %Set the Clusterindex of the removed cluster to 0
            infoClusterImg.clusters(infoClusterImg.clusters==ClusterToBeRemoved(r))=0;
            %Substract 1 from the clusterindex of all higher cluster such that there are no missing numbers
            infoClusterImg.clusters(infoClusterImg.clusters>ClusterToBeRemoved(r))=infoClusterImg.clusters(infoClusterImg.clusters>ClusterToBeRemoved(r))-1;

        end
        
        infoClusterImg.NumberOfClusters=infoClusterImg.NumberOfClusters-numel(ClusterToBeRemoved);
        %Reduce number of Clusters accordingly
            
    end
    
end



%% Number of particles of each cluster.
if infoClusterImg.NumberOfClusters >=1
    % Stores the data from each individual cluster.
	infoClusterImg.ParticlesPerCluster = zeros(infoClusterImg.NumberOfClusters,1);
    for nCluster=1:infoClusterImg.NumberOfClusters
        % Number of points per cluster
        infoClusterImg.ParticlesPerCluster(nCluster) = numel(find(infoClusterImg.clusters==nCluster));
    end
else
    % If there is no cluster, it is better to use NaN
	infoClusterImg.ParticlesPerCluster=NaN;
end
    
 
%% Areas (Convex Hull)

if infoClusterImg.NumberOfClusters>=1
    try
        areaClusterImg = areaClusters(consideredPoints, infoClusterImg.clusters);
    catch
        infoImage.route
        areaClusterImg = areaClusters(consideredPoints, infoClusterImg.clusters);
    end
	% Stores the data from each individual cluster.
	infoClusterImg.ClusterArea = zeros(infoClusterImg.NumberOfClusters,1);
    for nCluster=1:infoClusterImg.NumberOfClusters
        % Area  per cluster
        infoClusterImg.ClusterArea(nCluster) = areaClusterImg(nCluster)/10^6;
    end
else
    % If there is no cluster, it is better to use NaN
    infoClusterImg.ClusterArea=NaN;
end

%% Distance from edge and center
if infoClusterImg.NumberOfClusters>=1
    infoClusterImg.distanceFromEdge=zeros(infoClusterImg.NumberOfClusters,1);
    infoClusterImg.distanceFromCenter=zeros(infoClusterImg.NumberOfClusters,1);
    for nCluster=1:infoClusterImg.NumberOfClusters
        %Compute center of gravity
        particles = consideredPoints(infoClusterImg.clusters==nCluster,:);
        ch=convhull(particles(:,1), particles(:,2));
        sortedx=particles(ch,1);
        sortedy=particles(ch,2);
        Ar=0.5*sum(sortedx(1:end-1).*sortedy(2:end)-sortedx(2:end).*sortedy(1:end-1));
        Massx=(1/(6*Ar))*sum((sortedx(1:end-1)+sortedx(2:end)).*(sortedx(1:end-1).*sortedy(2:end)-sortedx(2:end).*sortedy(1:end-1)));
        Massy=(1/(6*Ar))*sum((sortedy(1:end-1)+sortedy(2:end)).*(sortedx(1:end-1).*sortedy(2:end)-sortedx(2:end).*sortedy(1:end-1)));
        %Get Distance from edge and center
        infoClusterImg.distanceFromEdge(nCluster)=distanceFromEdge([Massx,Massy],infoImage.boundary);
        infoClusterImg.distanceFromCenter(nCluster)=distanceFromCenter([Massx,Massy],infoImage.boundary);
    end
 
    infoClusterImg.normalizedDistanceFromCenter=infoClusterImg.distanceFromCenter ./ ...
                                    (infoClusterImg.distanceFromCenter + infoClusterImg.distanceFromEdge);
                                
    if infoImage.id==185
        adfasdf=12;
        
    end
else
    infoClusterImg.distanceFromEdge=NaN;
    infoClusterImg.distanceFromCenter=NaN;
    infoClusterImg.normalizedDistanceFromCenter=NaN;
end
    
%% Density of each cluster
if infoClusterImg.NumberOfClusters>=1
    infoClusterImg.DensityWithinCluster=infoClusterImg.ParticlesPerCluster./infoClusterImg.ClusterArea;
else
	% If there is no cluster, it is better to use NaN
	infoClusterImg.DensityWithinCluster=NaN;
end
   
%% Ripley's
if infoClusterImg.NumberOfClusters>=1
    infoClusterImg.ripleysL = zeros(infoClusterImg.NumberOfClusters,1);
    for nCluster=1:infoClusterImg.NumberOfClusters
        pointsCluster = consideredPoints(infoClusterImg.clusters==nCluster,:);
        [~, l] = ripleysK(pointsCluster,  maxDistance, infoClusterImg.ClusterArea(nCluster));
        infoClusterImg.ripleysL(nCluster) = l;
    end
% If there is no cluster,
else
    infoClusterImg.ripleysL = NaN;
end


%% Nearest  cluster
if infoClusterImg.NumberOfClusters>=1
    infoClusterImg.nearestCluster = zeros(infoClusterImg.NumberOfClusters,1);
    for nCluster=1:infoClusterImg.NumberOfClusters
        pointsCluster = consideredPoints(infoClusterImg.clusters==nCluster,:);
        pointsOtherClusters = consideredPoints(infoClusterImg.clusters>0 & infoClusterImg.clusters~=nCluster,:);
        infoClusterImg.nearestCluster(nCluster) = min(distToNearestPoint2Sets(pointsCluster, pointsOtherClusters));
    end
% If there is no cluster,
else
    infoClusterImg.nearestCluster = NaN;
end

%% Includes the discarded points in the information of the clusters.
auxClusters = infoClusterImg.clusters;
infoClusterImg.clusters = zeros(infoImage.numParticles, 1);
infoClusterImg.clusters(consideredPointsIdx) = auxClusters; 

%% For each cluster, calculates the distribution of particles with each considered radii.
numConsideredRadii = numel(radii);
if infoClusterImg.NumberOfClusters>=1
    infoClusterImg.distPointsCluster = zeros(infoClusterImg.NumberOfClusters, numConsideredRadii);
    for nCluster=1:infoClusterImg.NumberOfClusters
        for nRadius=1:numConsideredRadii
            infoClusterImg.distPointsCluster(nCluster,nRadius)=sum(infoClusterImg.clusters==nCluster & infoImage.teorRadii==radii(nRadius));
        end
    end
else
    infoClusterImg.distPointsCluster = NaN;
end
end
