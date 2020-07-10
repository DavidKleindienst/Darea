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


function h=drawRectFromPoints( points, LineStyle, LineWidth, Color, axes )

%% Given a set of 2D points, draws a rectangle which surrounds them.

% It first finds the segment between the two points separated by a 
% greater distance. Then calculates the rectangle containing all the
% points such that the major side is parallel to this segment. 

% *------X---------------------*
% |                            |
% X----------------------------X
% |    X                       | 
% *----------------------X-----*  

% points: (n,2) matrix with the coordinates of the n points.
% lineStyle: Type of line, example: 'w--'
% lineWidth: Width of the line.
% Color: Color of the line.
if nargin <5
    axes=gca;
end
rect = minRectFromPoints(points);

% Draws the rectangle
h=drawRect(rect, LineStyle, LineWidth, Color, axes);

end

