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
function simImageInfo = simulateImage(infoImage,radius,simtype, Options,methodA, hProgress)
%% Carries out the simulation on one Image
%   For details, see genSimulation.m

simImageInfo=infoImage;

partnr=infoImage.numParticles;          %number of particles in the image

if Options.simOnDilation
    area=infoImage.discardedAreas;
else
    area=infoImage.demarcatedAreas;
end
exclZoneType=Options.partExcl{cellfun(@(x) isequal(x,radius), methodA)};

%% Set exclusion zones if wanted
if Options.exclZones; simImageInfo.exclusionZoneCenters=[]; end
if ~strcmp(simtype,'Permutation') && Options.exclZones && ~strcmp(exclZoneType,'random')
    %find smallest rectangle that contains demarcated area. Exclusion zones will be set within that.
    vdisc=min(area,[],2); hdisc=min(area);
    vm=[find(vdisc == min(vdisc(:)), 1 ), find(vdisc == min(vdisc(:)), 1, 'last' )];    %vertical (top and bottom) coordinates
    hm=[find(hdisc == min(hdisc(:)), 1 ), find(hdisc == min(hdisc(:)), 1, 'last' )];    %horizontal (left and right) coordinates
    %Define exclusion zones, centers are distributed randomly within area (overlap is possible)
    zoneCenters=NaN(round(Options.zoneNr{1}+Options.zoneNr{2}*infoImage.area),2);
    zoneCenters=doTheSimulation(zoneCenters,@(x)distributeDots(x,hm,vm),area,Options.zoneDistance, [],infoImage.scale);
    zoneCenters=round(zoneCenters./infoImage.scale); %convert to px
    zoneRadius=Options.zoneDiameter/2/infoImage.scale;
    area = getExclusionZones(area,zoneCenters,zoneRadius,exclZoneType);
    simImageInfo.exclusionZoneCenters=zoneCenters;
end

%find smallest rectangle that contains demarcated area. Simulations will than be carried out within that rectangle.
vdisc=min(area,[],2); hdisc=min(area);
vm=[find(vdisc == min(vdisc(:)), 1 ), find(vdisc == min(vdisc(:)), 1, 'last' )];    %vertical (top and bottom) coordinates
hm=[find(hdisc == min(hdisc(:)), 1 ), find(hdisc == min(hdisc(:)), 1, 'last' )];    %horizontal (left and right) coordinates

switch simtype
    case 'Permutation'
        % Make a permutation of the radii of particles
        % Numbers and position of particle stay the same, but each particle will get a random radius asigned,
        % such that the numbers of each radius stay the same.
        simImageInfo.teorRadii=simImageInfo.teorRadii(randperm(numel(simImageInfo.teorRadii)));
    case 'Sim'
        %random simulation
        simImageInfo=randomSimulation(infoImage, simImageInfo, area, radius, partnr, Options,vm,hm);
    case 'SimFit'
        simImageInfo=fittedSimulation(infoImage, simImageInfo, area, radius, partnr, Options, vm,hm, hProgress);
    otherwise
        fprintf('Unknown Simulation type %s', simtype);
end
%fprintf(['Image ' num2str(infoImage.id) ' finished\n']);
end

