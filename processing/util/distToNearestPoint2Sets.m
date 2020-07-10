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


function distances = distToNearestPoint2Sets(set1, set2, varargin)
%% For each point in set1, returns the distance to the nearest point in set2.

% Assumes that all points are different.
% Distances of 0 are considered as error.

% set1: (n,2) matrix of points.
% set2: (m,2) matrix of points.
% Include a third argument set to True to allow distances of zero. Default False.

% distance: Distance among the closest pair of points such that one is in
%           set1 and the other in set2.

% If some of the sets is empty, returns the maximum distance.
if nargin>2
    allowZero=varargin{1};      %If a third input argument is given, use it to allow zero distances or not
else
    allowZero=false;            %Otherwise, don't allow distances of zero
end
   
    


if size(set1,1)==0
    distances=NaN;
    return
end

if size(set2,1)==0
    distances = zeros(size(set1,1),1);
    for nPoint=1:size(set1,1)
        distances(nPoint) = NaN;
    end
    return
end

allDistances = pdist2(set1,set2);

% Set distances of 0 to NaN, if similar points are not allowed.
if allowZero == false
    allDistances(allDistances==0) = NaN;
end
% If the size of set2 is 1, allDistances has only a column
if size(set2,1)==1
    distances = allDistances;
else
    % The distance is the minimum for each column.
    distances = min(allDistances,[],2);
 
end

