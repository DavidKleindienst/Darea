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



function [discardedAreas, image] = getBaseImages(imageName, imageSelName, dilatePx,defaultSelIsBackground)
%% This function gets the useful part of the original image and a mask with the regions that must be processed.
% Discards the provided mask (if no mask is provided (i.e. imageSelName doesn't exist) no image selection will be discarded
% Also deletes huge (greater than 200 pixels) dark shades.


% imageName: Name of the image. 
% imageSelName: Name of the image where the discarded areas are white.

% image: Image without textual information from the microscope.
% discardedAreas: logical matrix with the same size of image. Pixels equal
%                 to true are discarded.

%% Reads the images
if nargout>1
    image = imread(imageName);
end
if nargin<3
    dilatePx=0;
end
if nargin<4
    defaultSelIsBackground=0;
end

if nargin>1 && exist(imageSelName,'file')==2
    imageSel = imread(imageSelName);
    discardedAreas=zeros(size(imageSel));
    if ~isa(imageSel, 'uint16')
        fprintf('Image is not 16bit, please convert images to 16 bit');
        return
    end
    %% Identifies the discarded areas (initially white) and sets to 0
    discardedAreas(imageSel==65535)=1;
    discardedAreas = bwareaopen(discardedAreas,20);
    discardedAreas = imopen(discardedAreas, strel('diamond',2));
    
    if dilatePx
       se=strel('diamond', dilatePx);
       %using imerode, since demarcated area has value 0, this will dilate it.
       discardedAreas=imerode(discardedAreas,se);
    end

else
    if nargout<=1
        %Image has not been read, but is needed now
        image = imread(imageName);
    end
    if defaultSelIsBackground
        discardedAreas=ones(size(image));
    else
        discardedAreas=zeros(size(image));
    end
end

end

