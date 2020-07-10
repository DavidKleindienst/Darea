%
% Copyright (C) 2015 Javier Cózar (*), Luis de la Ossa (*), Jesús Martínez (*) and Rafael Luján (+).
%
%   (*) Intelligent Systems and Data Mining research group - I3A -Computing Systems Department
%       University of Castilla-La Mancha - Albacete - Spain
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

function [k , l] = ripleysK(points, t, area)
%% Returns the Ripley's K function and the stabilized value for a set of points given an area and radius. 

% points:   (n,2) matrix with the coordinates of the points.
% t:        The search radius (parameter of the function).
% area:     Area containing the points (parameter of the function).

% k:        Ripley's k.
% l:        Stabilized Ripley's k.


%% Gets the number of points.
nPoints = size(points,1);

%% Calculates the distances of each pair of points.
distances = dist(points');
distances = distances(distances~=0);

%% Calculates  the summatory.
summatory = sum(distances<t);

%% Calculates the functions.
k = area/nPoints * summatory / nPoints;
l = sqrt(k/pi)-t;