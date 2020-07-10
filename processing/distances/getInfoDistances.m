function infoDistances = getInfoDistances(infoImages, radius, radius2, limitEdgeIndex, showProgress)
%% For each image, counts the number of particle of each radii. First it checks the number of 
% different theoretical radii used, and then counts the number of particles
% of each radii for each image.

%   infoImages: cell array with the information relative to each image.
%
%       infoImages{}.id:                      Id of the image.
%       infoImages{}.route:                   Route to the files relative to the image.
%       infoImages{}.scale:                   Scale of the image (nanometers/pixel). It is obtained as calibration * 10 / magnification.
%       infoImages{}.area:                    Area of interest (squared nanometers).
%       infoImages{}.numParticles:            Number of particles.
%       infoImages{}.centers:                 Locations of the particles (nanometers).
%       infoImages{}.radii:                   Actual radii of the particles (nanometers).
%       infoImages{}.teorRadii:               Theorethical radii of the particles.
%       infoImages{}.discardedAreas           Truth values for each pixel they belong to the area of interest or not


%   radius:                             Radius of the considered particles. If 'all' then all particles are considered.

%   showProgress:                       If true, it shows progress by console.

%   infoDistances:  Struct containing the results related to distances for each image.
%
%       infoDistances{}.radius:                   Considered radius.
%       infoDistances{}.distances:                Vector with infoImage.numParticle elements. Each one is the distance to the nearest particle.
%       infoDistances{}.stats:                    Stats: Maximum, minimum, average, standard deviation, sum, and elements considered (distinct to NaN)
%       infoDistances{}.allDistances:             Contains all distances from each particle to each other particle
%       infoDistances{}.allDistStats:             Contains the statistics for the allDistances


numImages = size(infoImages, 1);
infoDistances = cell(numImages,1);

if showProgress
    if strcmpi(radius,'all')  
        fprintf('Computing distances to nearest particle.\n');
    else
        fprintf('Computing distances to nearest particle with radius = %.2f.\n', radius);
    end
end

for nImage=1:numImages
    infoDistances{nImage} = nearestParticleImage(infoImages{nImage}, radius,radius2);
    if limitEdgeIndex %Find a good setting!!
        infoDistances{nImage}.relativeDistanceFromCenter(infoDistances{nImage}.relativeDistanceFromCenter>1)=1;
    end
    infoDistances{nImage}.squaredRelDistFromCenter=infoDistances{nImage}.relativeDistanceFromCenter.^2;
end


