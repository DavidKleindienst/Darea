%
% Copyright (C) 2015 Javier C??zar (*), David Kleindienst (#), Luis de la Ossa (*), Jes??s Mart??nez (*) and Rafael Luj??n (+).
%
%   (*) Intelligent Systems and Data Mining research group - I3A -Computing Systems Department
%       University of Castilla-La Mancha - Albacete - Spain
%
%   (#) Institute of Science and Technology (IST) Austria
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
function infoImages = getInfoImages(datFile, dilate, onlyParticlesWithin)
%% Gets the basic information necessary to process the images. It must be listed in the file 'folder/datFile'. 
% Input arguments:
% datFile: Full path to the projects .dat file (see Menu/importImages)

% Output arguments
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
%   infoImages{}.discardedAreas           Truth values for each pixel they belong to the area of interest or not



if nargin <2
    dilate=false;
end
if nargin <3
    onlyParticlesWithin=false;
end
%% Reads data from the configuration file
[routes, scales, selAngles]=readConfig(datFile);
numImages=numel(routes);
isSerEM=any(~isnan(selAngles));
if ~isSerEM
    %Necessary to avoid failing of parfor
    selAngles=NaN(1,numImages);
end
%% Creates the structure containing the information.
infoImages = cell(numImages,1);

folder=fileparts(datFile);
%% Processes each image.

parfor (imgIndex=1:numImages, getCurrentPoolSize())
    route=fullfile(folder,routes{imgIndex});
    scale=scales(imgIndex);

    %% Gets useful information.
    imageSelName = [route '_mod.tif'];
    if isSerEM
        imageName=route;
        discardedAreas = getBaseImages(imageName, imageSelName,selAngles(imgIndex));
    else
        imageName = [route '.tif'];
        discardedAreas = getBaseImages(imageName, imageSelName);
    end
    
    
    if dilate && sum(discardedAreas,'all')>0
        se=strel('diamond', round(dilate/scale));
        %using imerode, since demarcated area has value 0, this will dilate it.
        dil_discardedAreas=imerode(discardedAreas,se);
    end
    % area is calculated without dilation
    pixelsDiscarded = numel(find(discardedAreas==true));
    pixelsConsidered = numel(discardedAreas)-pixelsDiscarded;
    % Calculates the considered area (in squared micrometers)
    area = pixelsConsidered .* (scale^2)*1e-6;  
    %squaring of scale is neccessary because we are calculating a square area
    %Also convert from nm2 to µm2 

     %% Stores the data.
    infoImages{imgIndex}.id = imgIndex;
    infoImages{imgIndex}.route = route;
    infoImages{imgIndex}.scale = scale;
    infoImages{imgIndex}.area = area;
    %store both dilated and undilated demarcation
    infoImages{imgIndex}.demarcatedAreas=discardedAreas;
    if dilate && sum(discardedAreas,'all')>0
        infoImages{imgIndex}.discardedAreas=dil_discardedAreas;
    else
        %No dilation was performed; store undilated area again
        infoImages{imgIndex}.discardedAreas=discardedAreas;
    end
    
    %Get boundary of demarcated area
    infoImages{imgIndex}.boundary=getBoundary(discardedAreas,scale,true,imgIndex,imageName);
    %Get Information about particles
    dotsFile=[route 'dots.csv'];
    
    [centers, radii, teorRadii, numParticles]=readDotsFile(dotsFile,onlyParticlesWithin, infoImages{imgIndex},scale);

    infoImages{imgIndex}.numParticles = numParticles;
    infoImages{imgIndex}.centers = centers;
    infoImages{imgIndex}.radii = radii;
    infoImages{imgIndex}.teorRadii = teorRadii;      

   
end



end
