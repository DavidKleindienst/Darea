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
function Clustering=sendForClustering(Data, Images,  i, thresholdDistance,  minpointscluster)
% Chooses the correct thresholddistance for each particle size and group depending on settings.
% Then sends the Data on to the Clustering function

if ~iscell(thresholdDistance)   %Groups and Particles together
    Clustering=getInfoClustering(Images, Data.methodA{i}, thresholdDistance,  minpointscluster);
elseif size(thresholdDistance,1)>1 && size(thresholdDistance,2)>1   %Groups and Particles individual
    Clustering=cell(size(Images));
    for g=1:Data.Groups.number
        indeces=find(Data.Groups.imgGroup==g);
        Clustering(indeces)=getInfoClustering(Images(indeces), Data.methodA{i}, thresholdDistance{g,i},  minpointscluster);
    end
elseif size(thresholdDistance,1)>1  %Groups individual
    Clustering=cell(size(Images));
    for g=1:Data.Groups.number
        indeces=find(Data.Groups.imgGroup==g);
        Clustering(indeces)=getInfoClustering(Images(indeces), Data.methodA{i}, thresholdDistance{g},  minpointscluster);
    end
elseif size(thresholdDistance,2)>1  %Particles individual
    Clustering=getInfoClustering(Images, Data.methodA{i}, thresholdDistance{i},  minpointscluster);
else        %Happens if someone choses groupwise, but there's only one group; or particlewise but there's only one particle
    Clustering=getInfoClustering(Images, Data.methodA{i}, thresholdDistance{1},  minpointscluster);
end
end