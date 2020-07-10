function infoDistances = nearestParticleImage(infoImage, radius, radius2)
%% For each particle in the image with radius, returns the distance to the nearest particle radius2.

%   infoImage:     Struct containing the information relative to each image.
%
%       infoImage.route:                    Route to the files relative to the image.
%       infoImage.scale:                    Scale of the image (nanometers/pixel). It is obtained as calibration * 10 / magnification.
%       infoImage.area:                     Area of interest (squared nanometers).
%       infoImage.numParticles:             Number of particles.
%       infoImage.centers:                  Locations of the particles (nanometers).
%       infoImage.radii:                    Actual radii of the particles (nanometers).
%       infoImage.teorRadii:                Teorethical radii of the particles.
%

%       radius:                             Radius of the considered particles. If 'all' then all particles are considered.
%       radius2:                            If radius2 is given, then NND from particle with radius to nearest particle with radius2 is computed.
%                                           If radius2 is NaN, then radius2=radius

%   infoDistances:  Struct containing the results related to distances.
%
%   infoDistances.radius:                   Considered radius.
%   infoDistances.distances:                Vector with infoImage.numParticle elements. Each one is the distance to the nearest particle.
%   infoDistances.stats:                    Stats: Maximum, minimum, average, standard deviation, sum, and elements considered (distinct to NaN)
%   infoDistances.allDistances:             Contains all distances from each particle to each other particle
%   infoDistances.allDistStats:             Contains the statistics for the allDistances
 

infoDistances.radius = radius;
infoDistances.radius2=radius2;

%% Compares all the particles if radius is all
if strcmp(radius,'all')
    infoDistances=getallDistances(infoDistances,infoImage.centers,infoImage.boundary);
    
else
    % Extracts the locations of the points with the given radius.
    consideredParticles = infoImage.centers(infoImage.teorRadii==radius,:);
    if isnan(radius2)
        infoDistances=getallDistances(infoDistances,consideredParticles,infoImage.boundary);
    else
        comparedParticles=infoImage.centers(infoImage.teorRadii==radius2,:);
        infoDistances.distances = distToNearestPoint2Sets(consideredParticles,comparedParticles);
        infoDistances.allDistances=allDistances2Sets(consideredParticles, comparedParticles);
        infoDistances.distanceFromEdge=NaN;     %Fill in NaN, because this is only defined for particles of a given radius
        infoDistances.distanceFromCenter=NaN;
        infoDistances.relativeDistanceFromCenter=NaN;

    end
end
infoDistances.stats = sixStats(infoDistances.distances);
infoDistances.allDistStats=sixStats(infoDistances.allDistances);
    
    function info=getallDistances(info,centers,boundary)
        info.distances = distToNearestPoint(centers);   %NND
        info.allDistances=allDistances(centers);        %All Distances
        info.distanceFromEdge=distanceFromEdge(centers,boundary);     
        info.distanceFromCenter=distanceFromCenter(centers,boundary);
        info.relativeDistanceFromCenter=info.distanceFromCenter./(info.distanceFromEdge+info.distanceFromCenter);
    end
end

