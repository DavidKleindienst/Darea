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
function simInfo=genSimulation(infoImages,radius,simtype, Options,methodA, hProgress)
%% Carries out a simulation of randomly redistributing the particles with radius=radius in the demarcated part of the image multiple (=simnumber many) times
% Returns a struct of the which has the same basic structure as infoImages, but with redistributed particles. The number of particles that are in the new struct will be simnumber*number of particles in original image.
% Not simulated particles (i.e. particles whichs radius is not the same as the given radius) will remain at the same position, but each of these particle will be in the output simnumber many times.

%   infoImages: cell array with the information relative to each image.
%
%   infoImages{}.id:                      Id of the image.
%   infoImages{}.route:                   Route to the files relative to the image.
%   infoImages{}.scale:                   Scale of the image (nanometers/pixel). It is obtained as calibration * 10 / magnification.
%   infoImages{}.area:                    Area of interest (squared micrometers).
%   infoImages{}.numParticles:            Number of particles.
%   infoImages{}.centers:                 Locations of the particles (nanometers).
%   infoImages{}.radii:                   Actual radii of the particles (nanometers).
%   infoImages{}.teorRadii:               Theorethical radii of the particles.
%   infoImages{}.discardedAreas           Truth values for each pixel they belong to the area of interest or not

%   radius: particles of this radius will be redistributed. If radius='all': all particles will be redistributed
%   fitNND: true or false. If true, particles will be destributed such that mean NND of the simulated particles within mean+-SEM of the NND of the original image

imgNr=numel(infoImages);
simInfo=cell(imgNr,1);
if strcmp(simtype, 'SimFit')
    %Use parallel for fitted simulations and serial otherwise. it's faster.
    poolsize=getCurrentPoolSize();
else
    poolsize=0;
end
%for i=1:imgNr
parfor (i=1:imgNr, poolsize)             %Run simulations in parallel to save time
    simInfo{i}=simulateImage(infoImages{i},radius,simtype, Options,methodA, hProgress);
end

