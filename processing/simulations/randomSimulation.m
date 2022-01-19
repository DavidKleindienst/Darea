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

function [simImageInfo, receptors] = randomSimulation(infoImage,simImageInfo, area, radius, Options,vm, hm)
%% Computes a random simulation of the Image
% All particles of the given radius will be redistributed in the area of interest, with each pixel having 
% the same probability of being chosen as center of a particle
% No two particles can be closer to each other than the mindistance.
%
% If multiple not connected areas of interest exist in the image, only the global particlenumber will be held
% constant, i.e. during the simulation particles may jump from one area of interest to the other.
%
% Input parameters:
% infoImage         infocellarray of the image
% simImageInfo      infocellarray of the image that will be modified
% radius            radius of the particle which shall be simulated
% mindistance       minimum distance between two particles
if nargout > 1 && ~Options.twoStep
    receptors=NaN;
end

mindistance=Options.mindistance;
minLength=Options.ReceptorParticleDistance(1);
maxLength=Options.ReceptorParticleDistance(2);
%clear particles that will be simulated
if strcmp(radius,'all')
    simImageInfo.centers(:,:)=NaN;
else
    simImageInfo.centers(infoImage.teorRadii==radius,:)=NaN;
end

centers=simImageInfo.centers;
centers(~isnan(centers))=[];
centers=reshape(centers,[],2);
if Options.twoStep
    receptors=doTheSimulation(centers,@(x)distributeDots(x,hm,vm),area,Options.minReceptorDistance, [],infoImage.scale);
    simfct=@(x)simulateParticlesNearReceptor(x,receptors,minLength,maxLength);
    centers=doTheSimulation(centers,simfct,0,mindistance, simImageInfo.centers);
else
    centers=doTheSimulation(centers,@(x)distributeDots(x,hm,vm), area, mindistance,simImageInfo.centers,infoImage.scale);
end
simImageInfo.centers(isnan(simImageInfo.centers))=centers;
    


end

