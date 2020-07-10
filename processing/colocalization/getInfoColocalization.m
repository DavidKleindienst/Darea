function infoColocalization = getInfoColocalization(infoI,radius,radius2,fwhm,keepIms)
%UNTITLED2 Summary of this function goes here
%   fwhm: full width at half max of the fitted gaussian
%           Typically this is the clustering distance

%   infoColocalization: cell array with the information relative to each image.
%
%       
%       infoColocalization{}.radius:            Radius of Particle 1
%       infoColocalization{}.radius2:           Radius of Particle 2
%       infoColocalization{}.coloc_of_P1:       Colocalization index relative to P1
%       infoColocalization{}.coloc_of_P2:       Colocalization index relative to P2
%       infoColocalization{}.colocalization:    Colocalization index relative to both Particles
%       The following are only stored if keepIm is true:
%       infoColocalization{}.gaussP1:           Gauss fitting for P1
%       infoColocalization{}.gaussP2:           Gauss fitting for P2
%       infoColocalization{}.colocalizationImage:   Kind of heatmap of colocalization

if strcmp(radius, 'all') || isnan(radius2)
    infoColocalization=NaN; %Not possible to do colocalization in this case
    return
end
if numel(fwhm)==1
    fwhm=[fwhm, fwhm];
end
sigma=fwhm./2.355;
numImages = size(infoI, 1);
infoColocalization = cell(numImages,1);
parfor (nImage=1:numImages, getCurrentPoolSize())
    infoColocalization{nImage} = imageColocalization(infoI{nImage},radius,radius2,sigma,keepIms);
end
end

