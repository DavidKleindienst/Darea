function [centers,radii,teorRadii, numParticles] = readDotsFile(dotsFile,onlyParticlesWithin, infoI,scale)
%READDOTSFILE Summary of this function goes here
%   Detailed explanation goes here
if nargin<4
    onlyParticlesWithin=0;
end
dotsFileInfo=dir(dotsFile);
if isfile(dotsFile) && dotsFileInfo.bytes>0
    dots = csvread(dotsFile);
    numParticles = size(dots,1);
    centers=dots(:,1:2);
    radii=dots(:,3);
    teorRadii=dots(:,4);
    if onlyParticlesWithin
       %Remove particles outside area of interest
      toBeRemoved=[];
       for i=1:numParticles
           pxCenters=round(centers./scale);
           if infoI.discardedAreas(pxCenters(i,2),pxCenters(i,1))
               toBeRemoved=[toBeRemoved i];
           end
       end
       centers(toBeRemoved,:)=[];
       radii(toBeRemoved)=[];
       teorRadii(toBeRemoved)=[];
       numParticles=numel(radii);
    end
else
    numParticles = 0;
    centers = [];
    radii = [];
    teorRadii = [];      
end
end

