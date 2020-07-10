%% 
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

function overlap=areaOverlap(points1,points2)
%% Computes the area of the overlap of two polygons

if size(points1,1)<3 || size(points2,1)<3
    overlap=NaN;            %If either of the polygons has fewer than 3 points, return NaN
else
    overlap_points=polygonIntersection(points1,points2); %Get the points outlining the area of overlap
    overlap_points=unique(overlap_points,'rows');
    if size(overlap_points,1)<3     %If it's less than 3 points, return 0
        overlap=0;
    else                            %Otherwise compute area of the area of overlap
        [k1,d1]=getLine(overlap_points(1:2,:));
        [k2,d2]=getLine(overlap_points(2:3,:));
        if size(overlap_points,1)==3 && nearEnough(k1,k2) && nearEnough(d1,d2)      %If overlap is a line,
            overlap=0;                                                              %overlapping area=0
        else    
            cho=convhull(overlap_points(:,1), overlap_points(:,2));

            overlap=polyarea(overlap_points(cho,1), overlap_points(cho,2));
        end
    end   
end