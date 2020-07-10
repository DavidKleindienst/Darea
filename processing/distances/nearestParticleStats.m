function infoDistancesStats = nearestParticleStats(infoDistances)
%% Calculates some statistics of distances to the nearest particle for all particles in the images.

%   infoDistances:  Struct containing the results related to distances for each image.
%
%       infoDistances{}.radius:                   Considered radius.
%       infoDistances{}.distances:                Vector with infoImage.numParticle elements. Each one is the distance to the nearest particle.
%       infoDistances{}.stats:                    Stats: Maximum, minimum, average, standard deviation, sum, and elements considered (distinct to NaN)


%  infoDistancesStats: Maximum, minimum, average, standard deviation, sum, and elements considered (distinct to NaN)

numImages = size(infoDistances, 1);

numParticles = 0;
for nImage=1:numImages
    numParticles = numParticles + size(infoDistances{nImage}.distances,1);
end

distances = zeros(numParticles,1);

nParticle=0;
for nImage=1:numImages
    for nParticleImage=1:size(infoDistances{nImage}.distances,1)
        nParticle = nParticle + 1;
        distances(nParticle) = infoDistances{nImage}.distances(nParticleImage);
    end
end
infoDistancesStats = sixStats(distances);
end