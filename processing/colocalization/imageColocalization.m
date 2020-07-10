function infoColoc = imageColocalization(infoImage,radius,radius2,sigma,keepIms)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%       infoImage.route:                    Route to the files relative to the image.
%       infoImage.scale:                    Scale of the image (nanometers/pixel). It is obtained as calibration * 10 / magnification.
%       infoImage.area:                     Area of interest (squared nanometers).
%       infoImage.numParticles:             Number of particles.
%       infoImage.centers:                  Locations of the particles (nanometers).
%       infoImage.radii:                    Actual radii of the particles (nanometers).
%       infoImage.teorRadii:                Teorethical radii of the particles.
infoColoc.radius1=radius;
infoColoc.radius2=radius2;
particles1=round(infoImage.centers(infoImage.teorRadii==radius,:)./infoImage.scale);
particles2=round(infoImage.centers(infoImage.teorRadii==radius2,:)./infoImage.scale);
sigma=sigma./infoImage.scale;
imSize=size(infoImage.discardedAreas);
gauss1=getGaussImage(particles1, sigma(1), imSize);
gauss2=getGaussImage(particles2, sigma(2), imSize);

coloc=sqrt(gauss1.*gauss2);
auc=sum(coloc,'all');
infoColoc.coloc_of_P1=auc/sum(gauss1,'all');
infoColoc.coloc_of_P2=auc/sum(gauss2,'all');
infoColoc.colocalization=auc/sum(max(gauss1,gauss2),'all');
if keepIms
    infoColoc.gaussP1=gauss1;
    infoColoc.gaussP2=gauss2;
    infoColoc.colocalizationImage=coloc;
end
end

