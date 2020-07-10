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

function [simImageInfo, receptors] = randomSimulation(infoImage,simImageInfo, area, radius, partnr, Options,vm, hm)
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
% partnr            number of particles in the image
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

if 1 %2-3 times faster, not tested extensively, has two-step
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
    
else
for j=1:partnr      %Old version, slow but proven; Also doesnt have two-step
    flag=1;
    if strcmp(radius,'all') || infoImage.teorRadii(j)==radius

        while flag
            a=random('unid',hm(2)-hm(1)+1);          %roll dice for each particle that has the desired radius to obtain random distribution
            b=random('unid',vm(2)-vm(1)+1);          %get a number within the two limits of the discarded area
            a=a+hm(1)-1;
            b=b+vm(1)-1;
            if area(b,a)==0 %if particle lands in relevant part of image, check distance to other particles
                a=a*infoImage.scale;
                b=b*infoImage.scale;
                if min(isnan(simImageInfo.centers))==1 | min(distToNearestPoint2Sets(simImageInfo.centers, [a,b], true))>=mindistance         %If distance is larger than the minimum distance or no other particle is yet present, save that particle
                    flag=0;
                    simImageInfo.centers(j,1)=a;
                    simImageInfo.centers(j,2)=b;
                end
            end
        end

    end
end
end

end

