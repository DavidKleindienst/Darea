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


function distances = distToNearestPoint(points)
%% Calculates the distance of each point to the nearest point other than itself.

% Assumes that all points are different 0 distances are considered as error.

% points: (n,2) matrix with the coordinates of the points.
% distances: (n,1) vector with the distances

% If there is only one point, it returns NaN
if size(points,1) <=1
    distances = NaN;
    return
end

% The dist function works considers each column as a point, so we apply the traspose
allDistances = dist(points');

% Sets the diagonal and equivalent points (distance from the point p to itself) to NaN.
allDistances(allDistances==0) = NaN;

% Obtains the distance to the closest point.
distances = min(allDistances);

% Returns a row vector;
distances = distances';

end

